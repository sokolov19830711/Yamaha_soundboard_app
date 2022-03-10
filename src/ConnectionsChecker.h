#ifndef CONNECTIONSCHECKER_H
#define CONNECTIONSCHECKER_H

#include <QObject>
#include <QSharedPointer>
#include <QTimer>

#include "SettingsManager.h"
#include "MidiPortsManager.h"
#include "JsonConfigManager.h"

class ConnectionsChecker : public QObject
{
  Q_OBJECT
public:
  ConnectionsChecker(const QSharedPointer<SettingsManager>& settings, MidiPortsManager& portsManager, JsonConfigManager& jsonConfigManager, QObject *parent = nullptr);

public slots:
  void checkInternetConnection();
  void checkSoundboardConnection();

signals:

  void soundboardConnectionChecked(bool state);

private:

  QSharedPointer<SettingsManager> _settings;
  MidiPortsManager& _portsManager;
  JsonConfigManager& _jsonConfigManager;

  QTimer _timer;
};

#endif // CONNECTIONSCHECKER_H
