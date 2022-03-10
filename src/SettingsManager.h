#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>
#include <QStandardPaths>

class SettingsManager : public QObject
{
    Q_OBJECT

public:

    explicit SettingsManager(QObject *parent = nullptr);
    ~SettingsManager();

    Q_INVOKABLE void setValue(QString name, QVariant value);
    Q_INVOKABLE QVariant value(QString name);
    Q_INVOKABLE QString workDirectory();

signals:

private:

        QString _workDirectory = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation); // For the release version
//        QString _workDirectory = QDir(".").absolutePath(); //For the test version

        QSettings _settings;

};

#endif // SETTINGSMANAGER_H
