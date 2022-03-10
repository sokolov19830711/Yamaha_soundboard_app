#ifndef MIDICOMMAND_H
#define MIDICOMMAND_H

#include <QStringList>


class MidiCommand
{

public:

  enum MidiCommandType {Request, Change};

  MidiCommand(MidiCommandType commandType);
  MidiCommand(int midiChannel, int consoleChannel); // Request Command
  MidiCommand(int midiChannel, int consoleChannel, const QStringList& data); // Change Command
  MidiCommand(const QStringList& commandTemplate);
  MidiCommand(const QStringList& commandTemplate, int midiChannel, int consoleChannel); // Request Command
  MidiCommand(const QStringList& commandTemplate, int midiChannel, int consoleChannel, const QStringList& data); // Change Command

  QStringList getCommand() const {return _command;}
  void setMidiChannel(int channel);
  void setConsoleChannel(int channel);
  void setData(const QStringList& data);
  void setByte(int index, QString value);
  QString getByte(int index);
  bool isInitialized() const;

private:

  QStringList intToMidi2bytes(int value) const;

  static QStringList requestTemplate;
  static QStringList changeTemplate;
  MidiCommandType _type;
  QStringList _command;

  int _midiCahnnel;
  int _consoleChannel;
  QStringList _data;

};

#endif // MIDICOMMAND_H
