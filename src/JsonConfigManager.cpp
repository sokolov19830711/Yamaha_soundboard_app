#include "JsonConfigManager.h"

#include <QFile>
#include <QFileDialog>
#include <QFileInfo>
#include <QJsonObject>
#include <QJsonDocument>

#include <QDebug>

JsonConfigManager::JsonConfigManager(const QSharedPointer<SettingsManager> &settings, QObject *parent) : QObject(parent),
  _settings(settings)
{
  if (settings->value("lastJsonConfigFile").toString() != "")
  {
    load(settings->value("lastJsonConfigFile").toString());
  }
}

JsonConfigManager::~JsonConfigManager()
{

}

QStringList JsonConfigManager::getCommandGroupsList(int selector) const
{
  QStringList list;

  switch (selector)
  {
  case ALL:
    for (const auto & groupValue : _rawJsonArray)
      list << groupValue.toObject().keys().first();
    break;

  case CHANNEL:
    for (const auto & groupValue : _rawJsonArray)
    {
      if (groupValue.toObject().begin()->toVariant().toMap().value("channelPreset").toBool())
        list << groupValue.toObject().keys().first();
    }
    break;

  case MIX:
    break;
  }

  return list;
}

QStringList JsonConfigManager::getCommandList(QString groupName) const
{
  QStringList list;
  for (const auto & groupValue : _rawJsonArray)
  {
    if (groupName == groupValue.toObject().keys().first())
    {
      list = groupValue.toObject()[groupName].toObject()["index"].toObject().keys();
      break;
    }
  }

  return list;
}

QStringList JsonConfigManager::getChangeSeq(QString groupName, QString commandName) const
{
  QStringList list;

  for (const auto & groupValue : _rawJsonArray)
  {
    if (groupName == groupValue.toObject().keys().first())
    {
      auto array = groupValue.toObject()[groupName].toObject()["index"].toObject()[commandName].toObject()["parameter-change-format"].toArray();
      for (const auto & value : array)
        list.append(value.toString());
      break;
    }
  }

  return list;
}

QStringList JsonConfigManager::getRequestSeq(QString groupName, QString commandName) const
{
  QStringList list;

  for (const auto & groupValue : _rawJsonArray)
  {
    if (groupName == groupValue.toObject().keys().first())
    {
      auto array = groupValue.toObject()[groupName].toObject()["index"].toObject()[commandName].toObject()["parameter-request-format"].toArray();
      for (const auto & value : array)
        list.append(value.toString());
      break;
    }
  }

  return list;
}

QString JsonConfigManager::getChangeSeqString(QString groupName, QString commandName) const
{
  return getChangeSeq(groupName, commandName).join(" ");
}

QString JsonConfigManager::getRequestSeqString(QString groupName, QString commandName) const
{
  return getRequestSeq(groupName, commandName).join(" ");
}

QString JsonConfigManager::selectJsonConfigFileDialog()
{
  QString lastOpenedDir = _settings->value("lastOpenedDirectory").toString();
  lastOpenedDir = lastOpenedDir == "" ? QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) : lastOpenedDir;

  QString fileName = QFileDialog::getOpenFileName(nullptr, tr("Select JSON config file"), lastOpenedDir, tr("JSON Configs (*.json)"));

  if(fileName.size())
  {
      QFileInfo info(fileName);
      _settings->setValue("lastJsonConfigFile", fileName);
      _settings->setValue("lastOpenedDirectory", info.canonicalPath());
      load(fileName);
  }

  return fileName;
}

void JsonConfigManager::load(QString fileName)
{
  QFile file(fileName);
  if (file.open(QIODevice::ReadOnly | QIODevice::Text))
  {
    _rawJsonArray = QJsonDocument::fromJson(file.readAll()).array();
    _settings->setValue("lastJsonConfigFile", fileName);
    emit jsonConfigFileChanged(fileName);
  }
}
