#ifndef MIDIPORTSMANAGER_H
#define MIDIPORTSMANAGER_H

#include <QObject>
#include <QSharedPointer>
#include <QTimer>

#include "SettingsManager.h"
#include "RtMidi.h"
#include "MidiCommand.h"

class MidiPortsManager : public QObject
{
  Q_OBJECT

public:

  enum IncomingMessageProcessingMode {Default, CreatePreset};

  MidiPortsManager(const QSharedPointer<SettingsManager>& settings, QObject *parent = nullptr);
  ~MidiPortsManager();

  Q_INVOKABLE QStringList getOutputPorts() const;
  Q_INVOKABLE QStringList getInputPorts() const;
  Q_INVOKABLE int getCurrentOutputPortIndex() const;
  Q_INVOKABLE int getCurrentInputPortIndex() const;

  Q_INVOKABLE void sendCommand(QStringList command, int responseWaitingDelay = 0);
  Q_INVOKABLE void sendCommand(const MidiCommand& command, int responseWaitingDelay = 0);
  Q_INVOKABLE void sendCommand(QString command, int responseWaitingDelay = 0);

  Q_INVOKABLE QStringList getDataForRequest(QStringList command);
  Q_INVOKABLE QStringList getDataForRequest(QString command);
  Q_INVOKABLE QStringList getDataForRequest(const MidiCommand& command);

  void addMessageToInputLog(std::vector<unsigned char> *message);
  void addMessageToOutputLog(std::vector<unsigned char> *message);
  void proccessIncomingMessage(std::vector<unsigned char> *message);

public slots:

  void setOutputPort(QString portName);
  void setInputPort(QString portName);

signals:

  void messageLogged(QString message);

private:

  QString getAvailableMidiPorts();

  QSharedPointer<SettingsManager> _settings;

  QStringList _availableInputPorts;
  int _currentInputPortIndex = -1;

  QStringList _availableOutputPorts;
  int _currentOutputPortIndex = -1;

  RtMidiOut *_midiout = nullptr;
  RtMidiIn *_midiin = nullptr;

  IncomingMessageProcessingMode _inputMode = Default;
  bool _isWaitingForRequest = false;
  QTimer _responseWaitingTimer;
  QList<QList<unsigned char>> _lastReceivedMessages;

  const int _DEFAULT_DELAY = 30;
};

#endif // MIDIPORTSMANAGER_H
