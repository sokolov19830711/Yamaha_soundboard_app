#include "MidiPortsManager.h"

#include <QApplication>
#include <QDebug>

MidiPortsManager* midiPortsManager;

void mycallback(double deltatime, std::vector<unsigned char> *message, void *)
{
//  unsigned int nBytes = message->size();
//  for ( unsigned int i=0; i<nBytes; i++ )
//    std::cout << "Byte " << i << " = " << (int)message->at(i) << ", ";
//  if ( nBytes > 0 )
//    std::cout << "stamp = " << deltatime << std::endl;

  midiPortsManager->proccessIncomingMessage(message);
}

MidiPortsManager::MidiPortsManager(const QSharedPointer<SettingsManager> &settings, QObject *parent) : QObject(parent),
  _settings(settings)
{
  midiPortsManager = this;
  _responseWaitingTimer.setSingleShot(true);

  try
  {
    _midiin = new RtMidiIn();
  }
  catch ( RtMidiError &error )
  {
    error.printMessage();
  }

  try
  {
    _midiout = new RtMidiOut();
  }
  catch ( RtMidiError &error )
  {
    error.printMessage();
  }

  getAvailableMidiPorts();

  if(_availableOutputPorts.size())
  {
    QString lastOutputPortName = _settings->value("lastOutputPortName").toString();
    if(lastOutputPortName != "")
    {
      for (auto & portName : _availableOutputPorts)
      {
        if (portName == lastOutputPortName)
        {
          setOutputPort(portName);
          break;
        }
      }
    }

    else if (!_midiout->isPortOpen())
    {
      for (auto & portName : _availableOutputPorts)
      {
        if (portName.contains("TestVirtualInput"))
        {
          setOutputPort(portName);
          _settings->setValue("lastOutputPortName", portName);
          break;
        }
      }
    }
  }

  if (!_midiout->isPortOpen())
    qDebug() << "Warning! The output port not opened.";

  if (!_midiin->isPortOpen())
    qDebug() << "Warning! The input port not opened.";
}

MidiPortsManager::~MidiPortsManager()
{
  delete _midiout;
  delete _midiin;
}

QStringList MidiPortsManager::getOutputPorts() const
{
  return _availableOutputPorts;
}

QStringList MidiPortsManager::getInputPorts() const
{
  return _availableInputPorts;
}

int MidiPortsManager::getCurrentOutputPortIndex() const
{
  return _currentOutputPortIndex;
}

int MidiPortsManager::getCurrentInputPortIndex() const
{
  return _currentInputPortIndex;
}

void MidiPortsManager::sendCommand(QStringList command, int responseWaitingDelay)
{
  std::vector<unsigned char> message;
  bool ok;
  for (auto & v : command)
  {
    message.push_back(static_cast<unsigned char>(v.toUInt(&ok, 16)));
  }
  if (!message.empty())
  {
    _midiout->sendMessage(&message);
    addMessageToOutputLog(&message);

    if (responseWaitingDelay > 0)
    {
      _responseWaitingTimer.start(responseWaitingDelay);

      while (_responseWaitingTimer.isActive())
      {
        QApplication::processEvents();
      }
    }
  }
}

void MidiPortsManager::sendCommand(const MidiCommand &command, int responseWaitingDelay)
{
  sendCommand(command.getCommand(), responseWaitingDelay);
}

void MidiPortsManager::sendCommand(QString command, int responseWaitingDelay)
{
  sendCommand(command.simplified().split(" "), responseWaitingDelay);
}

void MidiPortsManager::addMessageToInputLog(std::vector<unsigned char> *message)
{
  QString string;
  for (auto i : *message)
  {
    QString byteValue = QString::number(i, 16);
    if (byteValue.size() < 2)
      byteValue.prepend("0");
    string.append(byteValue.toUpper() + " ");
  }
  string.chop(1);

  emit messageLogged(string);
  qDebug() << "Message received:" << string;
}

void MidiPortsManager::addMessageToOutputLog(std::vector<unsigned char> *message)
{
  QString string;
  for (auto i : *message)
  {
    QString byteValue = QString::number(i, 16);
    if (byteValue.size() < 2)
      byteValue.prepend("0");
    string.append(byteValue.toUpper() + " ");
  }
  string.chop(1);

  emit messageLogged(string);
  qDebug() << "Message sent:" << string;
}

void MidiPortsManager::setOutputPort(QString portName)
{
  if (!_availableOutputPorts.contains(portName))
    return;

  if (_availableOutputPorts.indexOf(portName) == _currentOutputPortIndex)
    return;

  qDebug() << "Setting up output" << portName;
  if (_midiout->isPortOpen())
    _midiout->closePort();

  _currentOutputPortIndex = _availableOutputPorts.indexOf(portName);
  _midiout->openPort(_currentOutputPortIndex);
  _settings->setValue("lastOutputPortName", portName);
}

void MidiPortsManager::setInputPort(QString portName)
{
  if (!_availableInputPorts.contains(portName))
    return;

  if (_availableInputPorts.indexOf(portName) == _currentInputPortIndex)
    return;

  qDebug() << "Setting up input" << portName;
  if (_midiin->isPortOpen())
    _midiin->closePort();

  _currentInputPortIndex = _availableInputPorts.indexOf(portName);
  _midiin->openPort(_currentInputPortIndex);
  _midiin->setCallback( &mycallback);
  _settings->setValue("lastInputPortName", portName);
}

QString MidiPortsManager::getAvailableMidiPorts()
{
  _availableInputPorts.clear();
  _availableOutputPorts.clear();
  QString text;

  // Create an api map.
    QMap<int, QString> apiMap;
    apiMap[RtMidi::MACOSX_CORE] = "OS-X CoreMIDI";
    apiMap[RtMidi::WINDOWS_MM] = "Windows MultiMedia";
    apiMap[RtMidi::UNIX_JACK] = "Jack Client";
    apiMap[RtMidi::LINUX_ALSA] = "Linux ALSA";
    apiMap[RtMidi::RTMIDI_DUMMY] = "RtMidi Dummy";

    std::vector< RtMidi::Api > raw_apis;
    RtMidi :: getCompiledApi(raw_apis);

    auto apis = QVector<RtMidi::Api>(raw_apis.begin(), raw_apis.end());
//    qDebug() << "Compiled APIs:";
    text +=  "Compiled APIs:";
    text += "\n";
    for (int i = 0; i < apis.size(); i++)
    {
//      qDebug() << "  " << apiMap[apis[i]];
      text += " ";
      text += apiMap[apis[i]];
      text += "\n";
    }

    for (int i = 0; i < apis.size(); i++ )
    {
//      qDebug() << "Probing with API " << apiMap[apis[i]];
      text += "Probing with API ";
      text += apiMap[apis[i]];
      text += "\n";

      RtMidiIn  *midiin = 0;
      RtMidiOut *midiout = 0;

      try {

        // RtMidiIn constructor ... exception possible
        midiin = new RtMidiIn(apis[i]);

//        qDebug() << "Current input API: " << apiMap[midiin->getCurrentApi()];
        text += "Current input API: ";
        text += apiMap[midiin->getCurrentApi()];
        text += "\n";

        // Check inputs.
        unsigned int nPorts = midiin->getPortCount();
//        qDebug() << "There are " << nPorts << " MIDI input sources available.";
        text += "There are ";
        text += QString().setNum(nPorts);
        text += " MIDI input sources available.";
        text += "\n";

        for (int i = 0; i < nPorts; i++)
        {
          QString portName = QString::fromStdString(midiin->getPortName(i));
//          qDebug() << "  Input Port #" << i << ": " << portName;
          text += "  Input Port #";
          text += QString().setNum(i);
          text += ": ";
          text += portName;
          text += "\n";

          _availableInputPorts.push_back(portName);
        }

        // RtMidiOut constructor ... exception possible
        midiout = new RtMidiOut(apis[i]);

//        qDebug() << "Current output API: " << apiMap[ midiout->getCurrentApi() ];
        text += "Current outnput API: ";
        text += apiMap[ midiout->getCurrentApi() ];
        text += "\n";

        // Check outputs.
        nPorts = midiout->getPortCount();
//        qDebug() << "There are " << nPorts << " MIDI output ports available.";
        text += "There are ";
        text += QString().setNum(nPorts);
        text += " MIDI output sources available.";
        text += "\n";

        for (unsigned i = 0; i < nPorts; i++)
        {
          QString portName = QString::fromStdString(midiout->getPortName(i));
//          qDebug() << "  Output Port #" << i << ": " << portName;
          text += "  Output Port #";
          text += QString().setNum(i);
          text += ": ";
          text += portName;
          text += "\n";

          _availableOutputPorts.push_back(portName);
        }

      } catch ( RtMidiError &error ) {
        error.printMessage();
      }

      delete midiin;
      delete midiout;
    }

//    qDebug() << _availableInputPorts;
//    qDebug() << _availableOutputPorts;

    return text;
}

void MidiPortsManager::proccessIncomingMessage(std::vector<unsigned char> *message)
{
  switch (_inputMode)
  {
  case Default:
  break;

  case CreatePreset:

    QList<unsigned char> currMessage;
    for (auto byte : *message)
    {
      currMessage.push_back(byte);
    }
    _lastReceivedMessages.push_back(currMessage);
  break;
  }

  addMessageToInputLog(message);
}

QStringList MidiPortsManager::getDataForRequest(QStringList command)
{
  _inputMode = CreatePreset;
  _lastReceivedMessages.clear();
  sendCommand(command, _DEFAULT_DELAY);

  _inputMode = Default;

  if (_lastReceivedMessages.empty())
  {
    qWarning() << "Warning! No response for the command received. Default zero value is used.";
    return {"00", "00", "00", "00", "00"};
  }

  else
  {
    // We should parse the response here and return a data value for the command in a preset
    int msgLength = _lastReceivedMessages.at(0).size();
    if (msgLength < 11)
    {
      qWarning() << "Warning! No the response received is too short. Default zero value is used.";
      return {"00", "00", "00", "00", "00"};
    }

    else
    {
      QStringList bytes;
      for (int i = msgLength - 2; i > msgLength - 7; i--)
      {
        QString currByte = QString::number(_lastReceivedMessages.at(0).at(i), 16).toUpper();
        if (currByte.size() == 1)
          currByte = currByte.prepend("0");
        bytes << currByte;
      }

      return bytes;
    }

  }

  //  return {"00", "00", "00", "00", "00"};
}

QStringList MidiPortsManager::getDataForRequest(QString command)
{
  auto list = command.split("");
  return getDataForRequest(list);
}

QStringList MidiPortsManager::getDataForRequest(const MidiCommand &command)
{
  return getDataForRequest(command.getCommand());
}
