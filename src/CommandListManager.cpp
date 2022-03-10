#include "CommandListManager.h"

#include <QFile>
#include <QJsonDocument>
#include <QFileDialog>
#include <QStandardPaths>

#include <QDebug>

CommandListManager::CommandListManager(const QSharedPointer<SettingsManager> &settings, QObject *parent) : QObject(parent),
  _settings(settings)
{
  if (settings->value("lastProjectFile").toString() != "")
  {
    loadProject(settings->value("lastProjectFile").toString());
  }
}

CommandListManager::~CommandListManager()
{
  if (_hasChanges)
    saveProject();
}

QString CommandListManager::projectFileName()
{
  return _projectFileName;
}

void CommandListManager::createProject(QString projectName)
{
  _project.clear();
  _project.setProperty("projectName", projectName);
  _projectFileName = saveProjectDialog();
  _hasChanges = true;
  emit projectLoaded(_projectFileName);
}

void CommandListManager::updateCommandList(QString type, QString listName, QVariantList commands)
{
 JsonSerializable* list = new JsonSerializable();
 list->setProperty("name", listName);
 list->setProperty("type", type);

 for (auto & command : commands)
 {
   JsonSerializable* cmd = new JsonSerializable();
   cmd->setProperties(command.toMap());
   list->addChild(cmd);
 }

 auto existingList = commandList(type, listName);

 if (existingList)
   _project.replaceChild(existingList, list);
 else
  _project.addChild(list);

 _hasChanges = true;
}

QStringList CommandListManager::getChannelPresetList() const
{
  QStringList nameList;
  for (auto & list : _project.listedChildren())
  {
    if (list->property("type").toString() == "channelPreset")
      nameList.push_back(list->property("name").toString());
  }

  return nameList;
}

QVariantList CommandListManager::getPresetCommands(QString presetName) const
{
  QVariantList commands;
  for (auto & preset : _project.listedChildren())
  {
    if (preset->property("name").toString() == presetName)
    {
      for (auto & command : preset->listedChildren())
      {
        commands.push_back(command->properties());
      }
      break;
    }
  }

  return commands;
}

JsonSerializable *CommandListManager::commandList(QString type, QString listName) const
{
  for (auto & list : _project.listedChildren())
  {
    if (list->property("name").toString() == listName && list->property("type").toString() == type)
    {
      return list;
      break;
    }
  }

  return nullptr;
}

QString CommandListManager::loadFileDialog()
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

void CommandListManager::loadProject(QString fileName)
{
  QFile file(fileName);
  if (file.open(QIODevice::ReadOnly | QIODevice::Text))
  {
      _project.fromJsonObject(QJsonDocument::fromJson(file.readAll()).object());
      QFileInfo info(fileName);
      _projectFileName = fileName;
      _settings->setValue("lastProjectFile", fileName);
      _settings->setValue("lastOpenedDirectory", info.absolutePath());
      emit projectLoaded(fileName);
  }

  else
    emit projectLoaded("");
}

QString CommandListManager::saveProjectDialog()
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

void CommandListManager::saveProject()
{
  QFile jsonFile(_projectFileName);
  if (jsonFile.open(QIODevice::WriteOnly | QIODevice::Truncate))
  {
      QJsonDocument doc;
      doc.setObject(_project.toJsonObject());
      jsonFile.write(doc.toJson());
  }
}
