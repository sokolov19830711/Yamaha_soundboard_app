#ifndef COMMANDLISTMANAGER_H
#define COMMANDLISTMANAGER_H

#include <QObject>
#include <QSharedPointer>

#include "JsonSerializable.h"
#include "SettingsManager.h"

class CommandListManager : public QObject
{
  Q_OBJECT

public:

  CommandListManager(const QSharedPointer<SettingsManager>& settings, QObject *parent = nullptr);
  ~CommandListManager();

  Q_INVOKABLE QString projectFileName();
  Q_INVOKABLE void createProject(QString projectName);
  Q_INVOKABLE void updateCommandList(QString type, QString listName, QVariantList commands);
  Q_INVOKABLE QStringList getChannelPresetList() const;
  Q_INVOKABLE QVariantList getPresetCommands(QString presetName) const;


public slots:

  QString loadFileDialog();
  void loadProject(QString fileName);

signals:
  void projectLoaded(QString fileName);

private:

  QString saveProjectDialog();
  void saveProject();
  JsonSerializable* commandList(QString type, QString listName) const;

  QSharedPointer<SettingsManager> _settings;
  JsonSerializable _project;
  QString _projectFileName;
  bool _hasChanges = false;
};

#endif // COMMANDLISTMANAGER_H
