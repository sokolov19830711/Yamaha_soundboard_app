#include "SettingsManager.h"

#include <QDebug>

SettingsManager::SettingsManager(QObject *parent) :
    QObject(parent),
    _settings(_workDirectory + "/SBC_settings.ini", QSettings::IniFormat)
{
  qDebug() << "Settings file: "  << _workDirectory + "/SBC_settings.ini";
    _settings.setValue("workDirectory", _workDirectory);
}

SettingsManager::~SettingsManager()
{
    _settings.sync();
}

void SettingsManager::setValue(QString name, QVariant value)
{
    _settings.setValue(name, value);
    _settings.sync();
}

QVariant SettingsManager::value(QString name)
{
    return _settings.value(name);
}

QString SettingsManager::workDirectory()
{
    return _workDirectory;
}
