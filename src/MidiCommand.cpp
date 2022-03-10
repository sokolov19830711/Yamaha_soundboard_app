#include "MidiCommand.h"

QStringList MidiCommand::requestTemplate = QString("F0 43 3n 3E 19 01 00 00 00 00 cc cc F7").split(" ");
QStringList MidiCommand::changeTemplate = QString("F0 43 1n 3E 19 01 00 00 00 00 cc cc dd dd dd dd dd F7").split(" ");

MidiCommand::MidiCommand(MidiCommandType commandType) : _type(commandType)
{
  switch (_type)
  {
   case Request:
    _command = requestTemplate;
    break;

  case Change:
    _command = changeTemplate;
    break;
  }
}

MidiCommand::MidiCommand(int midiChannel, int consoleChannel)
{
  _type = Request;
  _command = requestTemplate;
  setMidiChannel(midiChannel);
  setConsoleChannel(consoleChannel);
}

MidiCommand::MidiCommand(int midiChannel, int consoleChannel, const QStringList &data)
{
  _type = Change;
  _command = changeTemplate;
  setMidiChannel(midiChannel);
  setConsoleChannel(consoleChannel);
  setData(data);
}

MidiCommand::MidiCommand(const QStringList &commandTemplate)
{
  if (commandTemplate.size() == 13)
    _type = Request;

  else
    _type = Change;

  _command = commandTemplate;
}

MidiCommand::MidiCommand(const QStringList &commandTemplate, int midiChannel, int consoleChannel)
{
  _type = Request;
  _command = commandTemplate;

  if (midiChannel < 0 && midiChannel > 15)
    return;

  _midiCahnnel = midiChannel;
  QString channelInHex = QString::number(midiChannel, 16).toUpper();
  QString midiChannelByte = _command.at(2);
  midiChannelByte.replace(1, 1, channelInHex);
  setByte(2, midiChannelByte);

  if (consoleChannel < 0 && consoleChannel > 127)
    return;

  _consoleChannel = consoleChannel;
  QStringList cc = intToMidi2bytes(_consoleChannel);
  setByte(10, cc.at(0));
  setByte(11, cc.at(1));
}

MidiCommand::MidiCommand(const QStringList &commandTemplate, int midiChannel, int consoleChannel, const QStringList &data)
{
   _type = Change;
  _command = commandTemplate;

  if (midiChannel < 0 && midiChannel > 15)
    return;

  _midiCahnnel = midiChannel;
  QString channelInHex = QString::number(midiChannel, 16).toUpper();
  QString midiChannelByte = _command.at(2);
  midiChannelByte.replace(1, 1, channelInHex);
  setByte(2, midiChannelByte);

  if (consoleChannel < 0 && consoleChannel > 127)
    return;

  _consoleChannel = consoleChannel;
  QStringList cc = intToMidi2bytes(_consoleChannel);
  setByte(10, cc.at(0));
  setByte(11, cc.at(1));

  if (data.size() != 5)
    return;

  _data = data;
  setByte(12, _data.at(0));
  setByte(13, _data.at(1));
  setByte(14, _data.at(2));
  setByte(15, _data.at(3));
  setByte(16, _data.at(4));
}

void MidiCommand::setMidiChannel(int channel)
{
  if (channel < 0 && channel > 15)
    return;

  _midiCahnnel = channel;
  QString channelInHex = QString::number(channel, 16).toUpper();
  QString midiChannelByte = _command.at(2);
  midiChannelByte.replace(1, 1, channelInHex);
  setByte(2, midiChannelByte);
}

void MidiCommand::setConsoleChannel(int channel)
{
  if (channel < 0 && channel > 127)
    return;

  _consoleChannel = channel;
  QStringList cc = intToMidi2bytes(_consoleChannel);
  setByte(10, cc.at(0));
  setByte(11, cc.at(1));
}

void MidiCommand::setData(const QStringList &data)
{
  if (_type != Change)
    return;

  if (data.size() != 5)
    return;

  _data = data;
  setByte(12, _data.at(0));
  setByte(13, _data.at(1));
  setByte(14, _data.at(2));
  setByte(15, _data.at(3));
  setByte(16, _data.at(4));
}

void MidiCommand::setByte(int index, QString value)
{
  if (value.size() != 2)
    return;

  _command.replace(index, value);
}

QString MidiCommand::getByte(int index)
{
  return _command.at(index);
}

bool MidiCommand::isInitialized() const
{
  QString cmd = _command.join("");
  if (cmd.contains("n") || cmd.contains("c") || cmd.contains("d"))
    return false;

  return true;
}

QStringList MidiCommand::intToMidi2bytes(int value) const
{
  int msb = value / 128;
  int lsb = value - msb;

  QString msbString = QString::number(msb, 16).toUpper();
  msbString = msbString.size() > 1 ? msbString : msbString.prepend("0");
  QString lsbString = QString::number(lsb, 16).toUpper();
  lsbString = lsbString.size() > 1 ? lsbString : lsbString.prepend("0");

  QStringList converted;
  converted.push_back(msbString);
  converted.push_back(lsbString);

  return converted;
}
