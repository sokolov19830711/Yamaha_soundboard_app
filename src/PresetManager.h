#ifndef PRESETMANAGER_H
#define PRESETMANAGER_H

#include <QObject>
#include <QSharedPointer>

#include "SettingsManager.h"
#include "MidiPortsManager.h"
#include "JsonConfigManager.h"
#include "MidiCommand.h"

class CommandSendingProgressCounter : public QObject
{
  Q_OBJECT

public:

  void set(double stepCount)
  {
    _stepCount = stepCount;
    _currentStep = 0;
    emit positionChanged(0.0);
  }

  void count()
  {
    _currentStep++;
    emit positionChanged(_currentStep / _stepCount);
  }

signals:
  void positionChanged(double position);

private:

  double _stepCount = 0.0;
  int _currentStep = 0;
};

class PresetManager : public QObject
{
  Q_OBJECT

public:

  explicit PresetManager(const QSharedPointer<SettingsManager>& settings, MidiPortsManager& portsManager, JsonConfigManager& jsonConfigManager, QObject *parent = nullptr);
  ~PresetManager();

  //Functions marked as Q_INVOKABLE are used in the QML GUI layer to manipulate with the project

  //Functions to operate with the project
  Q_INVOKABLE QString     projectFileName();
  Q_INVOKABLE void        createProject(QString projectName, int channelsCount);

  //Updates or creates Channel preset
  Q_INVOKABLE void        updateChannelPreset(QString presetName, QString presetDesc, QVariantList commands);
  //Udates Channel Preset info
  Q_INVOKABLE void        updateChannelPresetInfo(QString presetName, QString newPresetName, QString presetDesc);
  // Access to a Channel Preset properties
  Q_INVOKABLE QStringList getChannelPresetNamesList() const;
  Q_INVOKABLE QStringList getChannelPresetDescList() const;
  Q_INVOKABLE QVariantMap getPreset(QString presetName) const;
  Q_INVOKABLE QVariantList getPresetCommands(QString presetName) const;
  Q_INVOKABLE void        applyPresetToChannel(QString presetName, int channel);
  Q_INVOKABLE void        loadPredefinedChannelPresetsList(QString presetName, QString presetDesc, int consoleChannel);

  //Channels manipulations
  Q_INVOKABLE int         getMaxChannelCount() const {return MAX_CHANNELS_COUNT;}
  Q_INVOKABLE int         getChannelCount() const;
  Q_INVOKABLE void        updateChannelCount(int count);
  Q_INVOKABLE QStringList getChannelNamesList() const;
  Q_INVOKABLE QVariantList getChannelList() const;
  Q_INVOKABLE int         getFreeChannel() const;
  Q_INVOKABLE bool        isChannelOccupied(int channel) const;
  Q_INVOKABLE QVariantMap getChannel(QString channelName) const;
  Q_INVOKABLE void        assignPreset(QString channelName, QString presetName);
  Q_INVOKABLE void        updateChannel(QString oldChannelName, QString newChannelName, QString presetName, int channel);
  Q_INVOKABLE void        removeChannel(QString channelName);

  //Mixes and Mix Presets manipilations
  Q_INVOKABLE QVariantMap getMix(QString mixName) const;
  Q_INVOKABLE QStringList getMixNamesList() const;
  //Updates or creates Mix preset
  Q_INVOKABLE void        updateMix(QString oldMixName, QString newMixName, QString presetName);
  Q_INVOKABLE QVariantList getMixList() const;
  Q_INVOKABLE QStringList getMixPresetNamesList() const;
  Q_INVOKABLE void        loadMixPreset(QString mixPresetName, QString mixPresetDesc, QString mixName);
  Q_INVOKABLE void        updateMixPresetInfo(QString presetName, QString newPresetName, QString presetDesc);
  Q_INVOKABLE void        assignMixPreset(QString mixName, QString presetName);
  Q_INVOKABLE void        applyMixPreset(QString mixPresetName, QString mixName);
  Q_INVOKABLE QVariantList getMixPresets() const;
  Q_INVOKABLE QVariantMap getMixPreset(QString presetName) const;
  Q_INVOKABLE QStringList getMixNames() const;

public slots:

  QString loadFileDialog();
  void loadProject(QString fileName);

signals:
  void projectLoaded(QString fileName);
  void presetListChanged();
  void channelListChanged();
  void mixListChanged();
  void mixPresetListChanged();

  void predefinedListDownloadingStarted();
  void predefinedListDownloadingFinished();

  void mixPresetLoadingStarted();
  void mixPresetLoadingFinished();

  void mixPresetSendingStarted();
  void mixPresetSendingFinished();

  void channelPresetSendingStarted();
  void channelPresetSendingFinished();

  void progressChanged(double position);

private:

  QString saveProjectDialog();
  void saveProject();

  int calculateCommandCountForChannelPreset() const;
  void addCommandToPresetList(const QString& groupName, const QString& commandName, int consoleChannel);
  QString getChannelNameFromConsole(int channel) const;
  QString getMixNameFromConsole(int mixIndex) const;

  QSharedPointer<SettingsManager> _settings;
  MidiPortsManager& _portsManager;
  JsonConfigManager& _jsonConfigManager;
  QVariantMap _project; // Here we store all project information (channeles, mixes, presets)
  QString _projectFileName;
  bool _hasChanges = false;

  QVariantList _currentCommandList;

  const int MAX_CHANNELS_COUNT = 128;
  const int INPUTS_COUNT = 96;
  const int MAX_MIXES_COUNT = 24;
  QStringList _mixRequestCommandTemplate;
  QStringList _mixChangeCommandTemplate;
  QStringList _channelNameShortCommandTemplate1;
  QStringList _channelNameShortCommandTemplate2;
  QStringList _mixNameShortCommandTemplate1;
  QStringList _mixNameShortCommandTemplate2;

  CommandSendingProgressCounter _progressCounter; // Used for showing a progress bar state in the GUI
};

#endif // PRESETMANAGER_H
