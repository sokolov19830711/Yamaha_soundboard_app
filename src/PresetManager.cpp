#include "PresetManager.h"

#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>
#include <QFileDialog>
#include <QStandardPaths>
#include <QByteArray>

#include <QDebug>

PresetManager::PresetManager(const QSharedPointer<SettingsManager> &settings, MidiPortsManager &portsManager, JsonConfigManager &jsonConfigManager, QObject *parent)
  : QObject{parent},
    _settings(settings),
    _portsManager(portsManager),
    _jsonConfigManager(jsonConfigManager)
{
  if (settings->value("lastProjectFile").toString() != "")
  {
    loadProject(settings->value("lastProjectFile").toString());
  }

  _mixRequestCommandTemplate = QString("F0 43 3n 3E 19 01 00 49 00 00 cc cc F7").split(" ");
  _mixChangeCommandTemplate = QString("F0 43 1n 3E 19 01 00 49 00 00 cc cc dd dd dd dd dd F7").split(" ");

  _channelNameShortCommandTemplate1 = QString("F0 43 3n 3E 19 01 01 1D 00 00 cc cc F7").split(" ");
  _channelNameShortCommandTemplate2 = QString("F0 43 3n 3E 19 01 01 1D 00 01 cc cc F7").split(" ");

  _mixNameShortCommandTemplate1 = QString("F0 43 3n 3E 19 01 01 27 00 00 cc cc F7").split(" ");
  _mixNameShortCommandTemplate2 = QString("F0 43 3n 3E 19 01 01 27 00 01 cc cc F7").split(" ");

  connect(&_progressCounter, &CommandSendingProgressCounter::positionChanged, this, &PresetManager::progressChanged);
}

PresetManager::~PresetManager()
{
  if (_hasChanges)
  saveProject();
}

QString PresetManager::projectFileName()
{
  return _projectFileName;
}

void PresetManager::createProject(QString projectName, int channelsCount)
{
  _project.clear();
  _project["projectName"] = projectName;
  _projectFileName = saveProjectDialog();

  //--- Creating channels
  QVariantList channelList;
  for (int i = 0; i < channelsCount; i++)
  {
    QString channelName = "Channel " + QString::number(i + 1);

    QVariantMap channel;
    channel["channelName"] = channelName;
    channel["channel"] = i;
    channel["presetInUse"] = "<None>";
    channel["nameFromConsole"] = getChannelNameFromConsole(i);
    channelList.push_back(channel);
  }

  _project["channels"] = channelList;

  //--- Creating mixes

  QVariantList mixList;
  for (int i = 1; i < MAX_MIXES_COUNT + 1; i++)
  {
    QVariantMap currentMix;

    currentMix["mixName"] = "Mix " + QString::number(i);
    currentMix["params"] = QVariantList {3 * i, 3 * i + 1, 3 * i + 2};
    currentMix["index"] = i;
    currentMix["presetInUse"] = "<None>";
    currentMix["nameFromConsole"] = getMixNameFromConsole(i - 1);
    mixList.push_back(currentMix);
  }

  _project["mixes"] = mixList;

//  emit mixListChanged();

  if (!_projectFileName.isEmpty())
  {
    saveProject();
    emit projectLoaded(_projectFileName);
  }
}

void PresetManager::updateChannelPreset(QString presetName, QString presetDesc, QVariantList commands)
{
  QVariantList presets = _project["channelPresets"].toList();
  QString presetUuid;
  int counter  = 0;
  int index = -1;
  for (auto & preset : presets)
  {
    if (preset.toMap().value("presetName") == presetName)
    {
      index = counter;
      presetUuid = preset.toMap().value("presetName").toString();
      break;
    }
    counter++;
  }

  QVariantMap newPreset;
  newPreset["presetName"] = presetName;
  newPreset["presetDesc"] = presetDesc;
  newPreset["commands"] = commands;

  if (index >= 0)
  {
    newPreset["uuid"] = presetUuid;
    presets.replace(index, newPreset);
  }
  else
  {
    newPreset["uuid"] = QUuid::createUuid().toString();
    presets.push_back(newPreset);
  }

  _project["channelPresets"] = presets;
  saveProject();

  emit presetListChanged();
}

void PresetManager::updateChannelPresetInfo(QString presetName, QString newPresetName, QString presetDesc)
{
  auto presets = _project["channelPresets"].toList();
  int index = -1;
  for (int i = 0; i < presets.size(); i++)
  {
    auto preset = presets.at(i);
    if (preset.toMap()["presetName"] == presetName)
    {
      index = i;
      break;
    }
  }

  if (index == -1)
    return;

  auto preset = presets.at(index).toMap();
  preset["presetName"] = newPresetName;
  preset["presetDesc"] = presetDesc;

  presets.replace(index, preset);
  _project["channelPresets"] = presets;
  saveProject();
  emit presetListChanged();
}

QStringList PresetManager::getChannelPresetNamesList() const
{
  QStringList names;
  for (auto & preset : _project["channelPresets"].toList())
  {
    auto mapPreset = preset.toMap();
    names.push_back(mapPreset["presetName"].toString());
  }

  return names;
}

QStringList PresetManager::getChannelPresetDescList() const
{
  QStringList descriptions;
  for (auto & preset : _project["channelPresets"].toList())
  {
    auto mapPreset = preset.toMap();
    descriptions.push_back(mapPreset["presetDesc"].toString());
  }

  return descriptions;
}

QVariantMap PresetManager::getPreset(QString presetName) const
{
  for (auto & preset : _project["channelPresets"].toList())
  {
    auto mapPreset = preset.toMap();
    if (mapPreset["presetName"].toString() == presetName)
      return mapPreset;
  }

  return QVariantMap();
}

QVariantList PresetManager::getPresetCommands(QString presetName) const
{
  auto preset = getPreset(presetName);
  return preset["commands"].toList();
}

void PresetManager::applyPresetToChannel(QString presetName, int channel)
{
  emit channelPresetSendingStarted();

  auto commandlist = getPreset(presetName).value("commands").toList();
  _progressCounter.set(commandlist.size());
   for (auto & command : commandlist)
   {
     MidiCommand cmd(command.toString().split(" "));
     cmd.setConsoleChannel(channel);
     cmd.setMidiChannel(_settings->value("midiChannel").toInt());

     _portsManager.sendCommand(cmd, 30);
     _progressCounter.count();
   }

   emit channelPresetSendingFinished();
}

QStringList PresetManager::getChannelNamesList() const
{
  QStringList names;
  for (auto & channel : _project["channels"].toList())
  {
    auto mapChannel = channel.toMap();
      names.push_back(mapChannel["channelName"].toString());
  }

  return names;
}

QVariantList PresetManager::getChannelList() const
{
  return _project["channels"].toList();
}

int PresetManager::getFreeChannel() const
{
  auto channelsList = _project["channels"].toList();

  for (int i = 1; i < MAX_CHANNELS_COUNT; i++)
  {
    bool channelOccupied = false;
    for (auto & channel : channelsList)
    {
      if (channel.toMap()["channel"].toInt() == i)
      {
        channelOccupied = true;
        break;
      }
    }

    if (!channelOccupied)
      return i;
  }

  return -1;
}

bool PresetManager::isChannelOccupied(int channel) const
{
  auto channelsList = _project["channels"].toList();

  for (auto & channel : channelsList)
  {
    if (channel.toMap()["channel"].toInt() == channel)
      return true;
  }

  return false;
}

QVariantMap PresetManager::getChannel(QString channelName) const
{
  auto channelsList = _project["channels"].toList();
  for (auto & channel : channelsList)
  {
    if (channel.toMap()["channelName"] == channelName)
    {
      return channel.toMap();
    }
  }

  return QVariantMap();
}

void PresetManager::assignPreset(QString channelName, QString presetName)
{
  auto channelsList = _project["channels"].toList();

  QVariantMap currentChannel;
  int index = -1;
  int counter = 0;
  int channel = -1;
  for (auto & ch : channelsList)
  {
    if (ch.toMap()["channelName"] == channelName)
    {
      currentChannel = ch.toMap();
      currentChannel["presetInUse"] = presetName;
      channel = currentChannel["channel"].toInt();
      index = counter;
      break;
    }

    counter++;
  }

  channelsList.replace(index, currentChannel);
  _project["channels"] = channelsList;
  saveProject();
  emit channelListChanged();

  applyPresetToChannel(presetName, channel);
}

void PresetManager::updateChannel(QString oldChannelName, QString newChannelName, QString presetName, int channel)
{
  auto channelsList = _project["channels"].toList();

  QVariantMap currentChannel;
  int index = -1;
  int counter = 0;
  for (auto & ch : channelsList)
  {
    if (ch.toMap()["channelName"] == oldChannelName)
    {
      currentChannel = ch.toMap();
      currentChannel["channelName"] = newChannelName;
      currentChannel["presetInUse"] = presetName;
      currentChannel["channel"] = channel;
      index = counter;
      break;
    }

    counter++;
  }

  if (index != -1)
  {
    channelsList.replace(index, currentChannel);
  }

  else
  {
    currentChannel["channelName"] = newChannelName;
    currentChannel["presetInUse"] = presetName;
    currentChannel["channel"] = channel;
    channelsList.push_back(currentChannel);
  }

  _project["channels"] = channelsList;
  saveProject();
  emit channelListChanged();
}

void PresetManager::removeChannel(QString channelName)
{
  auto channelsList = _project["channels"].toList();

  int index = -1;
  int counter = 0;
  for (auto & channel : channelsList)
  {
    if (channel.toMap()["channelName"] == channelName)
    {
      index = counter;
      break;
    }
    counter++;
  }

  if (index != -1)
  {
    channelsList.removeAt(index);
    _project["channels"] = channelsList;
    saveProject();
    emit channelListChanged();
  }
}

QVariantMap PresetManager::getMix(QString mixName) const
{
  for (auto & mix : _project["mixes"].toList())
  {
    if (mix.toMap()["mixName"] == mixName)
    {
      return mix.toMap();
    }
  }

  return QVariantMap();
}

QStringList PresetManager::getMixNamesList() const
{
  QStringList names;
  for (auto & mix : _project["mixes"].toList())
  {
    auto mapMix = mix.toMap();
      names.push_back(mapMix["mixName"].toString());
  }

  return names;
}

void PresetManager::updateMix(QString oldMixName, QString newMixName, QString presetName)
{
  auto mixList = _project["mixes"].toList();

  QVariantMap currentMix;
  int index = -1;
  int counter = 0;
  for (auto & mix : mixList)
  {
    if (mix.toMap()["mixName"] == oldMixName)
    {
      currentMix = mix.toMap();
      currentMix["mixName"] = newMixName;
      currentMix["presetInUse"] = presetName;
      index = counter;
      break;
    }

    counter++;
  }

  if (index != -1)
  {
    mixList.replace(index, currentMix);
  }

  else
  {
    currentMix["mixName"] = newMixName;
    currentMix["presetInUse"] = presetName;
    mixList.push_back(currentMix);
  }

  _project["mixes"] = mixList;
  saveProject();
  emit mixListChanged();
}

QVariantList PresetManager::getMixList() const
{
  return _project["mixes"].toList();
}

QStringList PresetManager::getMixPresetNamesList() const
{
  QStringList names;
  for (auto & preset : _project["mixPresets"].toList())
  {
    auto mapPreset = preset.toMap();
    names.push_back(mapPreset["presetName"].toString());
  }

  return names;
}

void PresetManager::loadMixPreset(QString mixPresetName, QString mixPresetDesc, QString mixName)
{
  auto mixPresets = _project["mixPresets"].toList();
  for (auto & preset : mixPresets)
  {
    if (preset.toMap()["presetName"] == mixPresetName)
      return;
  }

  emit mixPresetLoadingStarted();

  int totalCommandCount = 0;

  auto params = getMix(mixName)["params"].toList();
  totalCommandCount += params.size() * INPUTS_COUNT;
  _progressCounter.set(totalCommandCount);

  //--- kInputToMix commands
  QStringList inputToMixCommands;
  for (auto & param : params)
  {
    for (int i = 0; i < INPUTS_COUNT; i++)
    {
      QString p = QString::number(param.toInt(), 16).toUpper();
      if (p.size() < 2)
        p = p.prepend("0");

      MidiCommand request(_mixRequestCommandTemplate);

      request.setMidiChannel(_settings->value("midiChannel").toInt());
      request.setConsoleChannel(i);
      request.setByte(9, p);

      auto data = _portsManager.getDataForRequest(request);

      MidiCommand changeCommand(_mixChangeCommandTemplate);
      changeCommand.setMidiChannel(_settings->value("midiChannel").toInt());
      changeCommand.setConsoleChannel(i);
      changeCommand.setData(data);
      changeCommand.setByte(9, p);

      inputToMixCommands << changeCommand.getCommand().join(" ");
      _progressCounter.count();
    }
  }

  QVariantMap newMixPreset;
  newMixPreset["presetName"] = mixPresetName;
  newMixPreset["description"] = mixPresetDesc;
  newMixPreset["mix"] = mixName;
  newMixPreset["inputToMixCommands"] = inputToMixCommands;
  newMixPreset["uuid"] = QUuid::createUuid().toString();

  mixPresets.push_back(newMixPreset);
  _project["mixPresets"] = mixPresets;
  saveProject();

  emit mixPresetLoadingFinished();
  emit mixPresetListChanged();
}

void PresetManager::updateMixPresetInfo(QString presetName, QString newPresetName, QString presetDesc)
{
  auto presets = _project["mixPresets"].toList();
  int index = -1;
  for (int i = 0; i < presets.size(); i++)
  {
    auto preset = presets.at(i);
    if (preset.toMap()["presetName"] == presetName)
    {
      index = i;
      break;
    }
  }

  if (index == -1)
    return;

  auto preset = presets.at(index).toMap();
  preset["presetName"] = newPresetName;
  preset["description"] = presetDesc;

  presets.replace(index, preset);
  _project["mixPresets"] = presets;
  saveProject();
  emit mixPresetListChanged();
}

void PresetManager::assignMixPreset(QString mixName, QString presetName)
{
  auto mixList = _project["mixes"].toList();

  QVariantMap currentMix;
  int index = -1;
  int counter = 0;
  for (auto & mix : mixList)
  {
    if (mix.toMap()["mixName"] == mixName)
    {
      currentMix = mix.toMap();
      currentMix["presetInUse"] = presetName;
      index = counter;
      break;
    }

    counter++;
  }

  mixList.replace(index, currentMix);
  _project["mixes"] = mixList;
  saveProject();
  emit mixListChanged();

  applyMixPreset(presetName, mixName);
}

void PresetManager::applyMixPreset(QString mixPresetName, QString mixName)
{
  QVariantMap currentPreset;
  auto presets = _project["mixPresets"].toList();

  for (auto & preset : presets)
  {
    if (preset.toMap()["presetName"].toString() == mixPresetName)
    {
      currentPreset = preset.toMap();
      break;
    }
  }

  if (currentPreset.isEmpty())
    return;

  emit mixPresetSendingStarted();

  int totalCommandCount = 0;

  //--- InputToMix commands
  auto commandList = currentPreset["inputToMixCommands"].toList();

  totalCommandCount += commandList.size();
  _progressCounter.set(totalCommandCount);


  auto currentParams = getMix(mixName)["params"].toList();
  auto oldParams = getMix(currentPreset["mix"].toString())["params"].toList();
  for (auto & command : commandList)
  {
    MidiCommand cmd(command.toString().split(" "));
    cmd.setMidiChannel(_settings->value("midiChannel").toInt());
    int indexOfParam = oldParams.indexOf(cmd.getByte(9).toInt());
    QString paramByte = QString::number(currentParams.at(indexOfParam).toInt(), 16);
    if (paramByte.size() < 2)
      paramByte.prepend("0");

    cmd.setByte(9, paramByte);

    _portsManager.sendCommand(cmd.getCommand(), 30);
    _progressCounter.count();
  }

  emit mixPresetSendingFinished();
}

QVariantList PresetManager::getMixPresets() const
{
  return _project["mixPresets"].toList();
}

QVariantMap PresetManager::getMixPreset(QString presetName) const
{
  for (auto & preset : _project["mixPresets"].toList())
  {
    if (preset.toMap()["presetName"] == presetName)
      return preset.toMap();
  }

  return QVariantMap();
}

QStringList PresetManager::getMixNames() const
{
  QStringList names;

  for (auto & mix : _project["mixes"].toList())
  {
    names << mix.toMap()["mixName"].toString();
  }

  return names;
}

QString PresetManager::loadFileDialog()
{
  QString lastOpenedDir = _settings->value("lastOpenedDirectory").toString();
  lastOpenedDir = lastOpenedDir == "" ? QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) : lastOpenedDir;

  QString fileName = QFileDialog::getOpenFileName(nullptr, tr("Select SBCA project file"), lastOpenedDir, tr("SBCA files (*.sbca)"));

  if(fileName.size())
  {
      loadProject(fileName);
  }

  return fileName;
}

void PresetManager::loadProject(QString fileName)
{
  QFile file(fileName);
  if (file.open(QIODevice::ReadOnly | QIODevice::Text))
  {
      _project = QJsonDocument::fromJson(file.readAll()).object().toVariantMap();
      QFileInfo info(fileName);
      _projectFileName = fileName;
      _settings->setValue("lastProjectFile", fileName);
      _settings->setValue("lastOpenedDirectory", info.absolutePath());
      emit projectLoaded(fileName);
  }

  else
    emit projectLoaded("");
}

QString PresetManager::saveProjectDialog()
{
  QString lastOpenedDir = _settings->value("lastOpenedDirectory").toString();
  lastOpenedDir = lastOpenedDir == "" ? QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) : lastOpenedDir;

  QString fileName = QFileDialog::getSaveFileName(nullptr, tr("Save current SBCA project"), lastOpenedDir, tr("SBCA projects (*.sbca)"));

  if(fileName.size())
  {
      QFileInfo info(fileName);
      _settings->setValue("lastOpenedDirectory", info.absolutePath());
      _settings->setValue("lastProjectFile", fileName);
      _projectFileName = fileName;
      saveProject();
  }

  return fileName;
}

void PresetManager::saveProject()
{
  QFile jsonFile(_projectFileName);
  if (jsonFile.open(QIODevice::WriteOnly | QIODevice::Truncate))
  {
      QJsonDocument doc;
      doc.setObject(QJsonObject::fromVariantMap(_project));
      jsonFile.write(doc.toJson());
  }
}

int PresetManager::calculateCommandCountForChannelPreset() const
{
  int counter = 0;
  auto predefinedGroupsList = _jsonConfigManager.getCommandGroupsList(JsonConfigManager::CHANNEL);
  for (auto & groupName : predefinedGroupsList)
  {
    auto cmdList = _jsonConfigManager.getCommandList(groupName);
    counter += cmdList.size();
  }

  return counter;
}

void PresetManager::addCommandToPresetList(const QString &groupName, const QString &commandName, int consoleChannel)
{
//  QVariantMap newCommand;
//  newCommand["groupName"] = groupName;
//  newCommand["commandName"] = commandName;

  MidiCommand requestCommand(_jsonConfigManager.getRequestSeq(groupName, commandName));
  MidiCommand changeCommand(_jsonConfigManager.getChangeSeq(groupName, commandName));

  requestCommand.setMidiChannel(_settings->value("midiChannel").toInt());
  requestCommand.setConsoleChannel(consoleChannel);

  auto data = _portsManager.getDataForRequest(requestCommand);

  changeCommand.setMidiChannel(_settings->value("midiChannel").toInt());
  changeCommand.setConsoleChannel(consoleChannel);
  changeCommand.setData(data);

//  newCommand["commandString"] = changeCommand.getCommand().join(" ");
  _currentCommandList.push_back(changeCommand.getCommand().join(" "));
}

QString PresetManager::getChannelNameFromConsole(int channel) const
{
  MidiCommand request1(_channelNameShortCommandTemplate1);
  request1.setMidiChannel(_settings->value("midiChannel").toInt());
  request1.setConsoleChannel(channel);

  auto data1 = _portsManager.getDataForRequest(request1);

  MidiCommand request2(_channelNameShortCommandTemplate2);
  request2.setMidiChannel(_settings->value("midiChannel").toInt());
  request2.setConsoleChannel(channel);

  auto data2 = _portsManager.getDataForRequest(request2);

  QString textValue1 = "";
  for(auto & byte : data1)
  {
      textValue1 += QString::fromLocal8Bit(QByteArray::fromHex(byte.toLatin1()));
  }

  QString textValue2 = "";
  for(auto & byte : data2)
  {
      textValue2 += QString::fromLocal8Bit(QByteArray::fromHex(byte.toLatin1()));
  }

  return textValue1 + textValue2;
}

QString PresetManager::getMixNameFromConsole(int mixIndex) const
{
  MidiCommand request1(_mixNameShortCommandTemplate1);
  request1.setMidiChannel(_settings->value("midiChannel").toInt());
  request1.setConsoleChannel(mixIndex);

  auto data1 = _portsManager.getDataForRequest(request1);

  MidiCommand request2(_mixNameShortCommandTemplate2);
  request2.setMidiChannel(_settings->value("midiChannel").toInt());
  request2.setConsoleChannel(mixIndex);

  auto data2 = _portsManager.getDataForRequest(request2);

  QString textValue1 = "";
  for(auto & byte : data1)
  {
      textValue1 += QString::fromLocal8Bit(QByteArray::fromHex(byte.toLatin1()));
  }

  QString textValue2 = "";
  for(auto & byte : data2)
  {
      textValue2 += QString::fromLocal8Bit(QByteArray::fromHex(byte.toLatin1()));
  }

  return textValue1 + textValue2;
}

void PresetManager::loadPredefinedChannelPresetsList(QString presetName, QString presetDesc, int consoleChannel)
{
  emit predefinedListDownloadingStarted();

  _progressCounter.set(calculateCommandCountForChannelPreset());
  _currentCommandList.clear();
  auto predefinedGroupsList = _jsonConfigManager.getCommandGroupsList(JsonConfigManager::CHANNEL);
  for (auto & groupName : predefinedGroupsList)
  {
    auto cmdList = _jsonConfigManager.getCommandList(groupName);
    for (auto & commandName : cmdList)
    {
      addCommandToPresetList(groupName, commandName, consoleChannel);
      _progressCounter.count();
    }
  }

  updateChannelPreset(presetName, presetDesc, _currentCommandList);
  emit predefinedListDownloadingFinished();
}

int PresetManager::getChannelCount() const
{
  return _project["channels"].toList().size();
}

void PresetManager::updateChannelCount(int count)
{
  int prevCount = getChannelCount();

  if (count == prevCount)
    return;

  else if (count > prevCount)
  {
    auto channels = _project["channels"].toList();
    auto lastChannel = channels.last().toMap()["channel"].toInt();
    int countToAdd = count - prevCount;

    for (int i = 0; i < countToAdd; i++)
    {
      QVariantMap channel;
      channel["channelName"] = "Channel " + QString::number(i + lastChannel + 2);
      channel["channel"] = i  + lastChannel + 1;
      channel["presetInUse"] = "<None>";
      channel["nameFromConsole"] = getChannelNameFromConsole(i  + lastChannel + 1);
      channels.push_back(channel);
    }

    _project["channels"] = channels;
    saveProject();
    emit channelListChanged();
  }

  else
  {
    auto channels = _project["channels"].toList();
    int countToRemove = prevCount - count;

    for (int i = 0; i < countToRemove; i++)
      channels.removeLast();

    _project["channels"] = channels;
    saveProject();
    emit channelListChanged();
  }
}
