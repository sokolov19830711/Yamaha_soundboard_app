#include "ConnectionsChecker.h"

ConnectionsChecker::ConnectionsChecker(const QSharedPointer<SettingsManager> &settings, MidiPortsManager &portsManager, JsonConfigManager &jsonConfigManager, QObject *parent)
  : QObject{parent},
    _settings(settings),
    _portsManager(portsManager),
    _jsonConfigManager(jsonConfigManager)
{
  _timer.setSingleShot(false);
  connect(&_timer, &QTimer::timeout, this, &ConnectionsChecker::checkSoundboardConnection);
  _timer.start(600000);
}

void ConnectionsChecker::checkInternetConnection()
{

}

void ConnectionsChecker::checkSoundboardConnection()
{
  MidiCommand cmd(_jsonConfigManager.getRequestSeq("kSceneDateTime", "kDateTime"), _settings->value("midiChannel").toInt(), 0);
  auto data = _portsManager.getDataForRequest(cmd.getCommand());
  if (data.join("") != QString("0000000000"))
    emit soundboardConnectionChecked(true);
  else
    emit soundboardConnectionChecked(false);
}
