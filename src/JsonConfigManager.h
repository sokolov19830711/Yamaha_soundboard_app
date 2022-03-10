#ifndef JSONCONFIGMANAGER_H
#define JSONCONFIGMANAGER_H

#include <QObject>
#include <QSharedPointer>
#include <QJsonArray>

#include "SettingsManager.h"

class JsonConfigManager : public QObject
{
  Q_OBJECT

public:

  enum GroupSelector {ALL, CHANNEL, MIX};
  Q_ENUM(GroupSelector)

  JsonConfigManager(const QSharedPointer<SettingsManager>& settings, QObject *parent = nullptr);
  ~JsonConfigManager();

  Q_INVOKABLE QStringList getCommandGroupsList(int selector) const;
  Q_INVOKABLE QStringList getCommandList(QString groupName) const;
  Q_INVOKABLE QStringList getChangeSeq(QString groupName, QString commandName) const;
  Q_INVOKABLE QStringList getRequestSeq(QString groupName, QString commandName) const;
  Q_INVOKABLE QString getChangeSeqString(QString groupName, QString commandName) const;
  Q_INVOKABLE QString getRequestSeqString(QString groupName, QString commandName) const;

public slots:

  QString selectJsonConfigFileDialog();
  void load(QString fileName);

signals:

  void jsonConfigFileChanged(QString fileName);

private:

  QSharedPointer<SettingsManager> _settings;
  QJsonArray _rawJsonArray;

};

#endif // JSONCONFIGMANAGER_H
