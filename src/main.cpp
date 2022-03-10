#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSharedPointer>
#include <QDebug>

#include "SettingsManager.h"
#include "MidiPortsManager.h"
#include "JsonConfigManager.h"
#include "PresetManager.h"
#include "ConnectionsChecker.h"

int main(int argc, char** argv)
{
    QApplication app(argc, argv);
    app.setOrganizationName("4-Seven-LLC");
    app.setOrganizationDomain("");

    auto settings = QSharedPointer<SettingsManager>::create();
    MidiPortsManager portsManager(settings);
    JsonConfigManager jsonConfigManager(settings);
    PresetManager presetManager(settings, portsManager, jsonConfigManager);
    ConnectionsChecker connectionsChecker(settings, portsManager, jsonConfigManager);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("settings", settings.get());
    engine.rootContext()->setContextProperty("portsManager", &portsManager);
    engine.rootContext()->setContextProperty("jsonConfigManager", &jsonConfigManager);
    engine.rootContext()->setContextProperty("presetManager", &presetManager);
    engine.rootContext()->setContextProperty("connectionsChecker", &connectionsChecker);
    engine.load(QUrl(QStringLiteral("qrc:/src/qml/main.qml")));
    return app.exec();
}
