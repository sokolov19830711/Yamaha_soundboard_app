import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.15

import "qrc:/"

ApplicationWindow
{
    id: applicationWindow
    width: 960 * scaleFactor
    height: 600 * scaleFactor
    x: settings.value("positionX")
    y: settings.value("positionY")
    visible: true
    color: "#ffffff"
    title: qsTr("Soundboard console application")
    flags: Qt.Window | Qt.FramelessWindowHint

    property real scaleFactor: 1.4
    property int previousX
    property int previousY

//    property alias commandListPopup: commandListPopup
//    property alias channelPresetPopup: channelPresetPopup
//    property alias loadChannelPresetPopup: loadChannelPresetPopup
    property alias viewCommandListPopup: viewCommandListPopup
    property alias viewMixCommandListPopup: viewMixCommandListPopup
    property alias loadPredefinedListPopup: loadPredefinedListPopup
    property alias loadMixPresetPopup: loadMixPresetPopup
    property alias projectNamePopup: projectNamePopup
    property alias presetUsePopup: presetUsePopup
    property alias mixPresetUsePopup: mixPresetUsePopup
    property alias changeChannelPresetPopup: changeChannelPresetPopup
    property alias changeMixPresetPopup: changeMixPresetPopup

    function makeShadowed(state)
    {
        shadowingRect.visible = state
    }

    Item
    {
        id: windowHeader
        height: 28
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        MouseArea
        {
            id: appWindowMoveArea
            height: parent.height
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            onPressed:
            {
                applicationWindow.previousX = mouseX
                applicationWindow.previousY = mouseY
            }

            onMouseXChanged:
            {
                var dx = mouseX - applicationWindow.previousX
                applicationWindow.setX(applicationWindow.x + dx)
                settings.setValue("positionX", applicationWindow.x)
            }

            onMouseYChanged:
            {
                var dy = mouseY - applicationWindow.previousY
                applicationWindow.setY(applicationWindow.y + dy)
                settings.setValue("positionY", applicationWindow.y)
            }
        }

        Rectangle
        {
            anchors.fill: parent
            color: "#eeeeee"

            Text
            {
                color: "#111111"

                text: applicationWindow.title
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.family: "Roboto"
                font.pixelSize: 14

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
            }

            Button
            {
                id: hideButton
                width: 28
                height: 28

                bottomPadding: 0
                topPadding: 0
                rightPadding: 0
                leftPadding: 0

                anchors.right: closeButton.left

                Image
                {
                    source: "qrc:/hideButton"
                }

                onClicked:
                {
                    applicationWindow.showMinimized()
                }

            }

            Button
            {
                id: closeButton
                width: 28
                height: 28
                anchors.right: parent.right

                bottomPadding: 0
                topPadding: 0
                rightPadding: 0
                leftPadding: 0

                Image
                {
                    source: "qrc:/closeButton"
                }

                onClicked:
                {
                    Qt.quit()
                }
            }
        }
    }

    Item
    {
        id: tabBar
        height: 68
        anchors.top: windowHeader.visible ? windowHeader.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle
        {
            id: tabBarBackground
            anchors.fill: parent
            color: "#151D2F"
        }

        ButtonGroup
        {
            id: tabBarButtons
        }

        TabBarButton
        {
            id: homeButton
            text: qsTr("Home")
            width: 80
            anchors.leftMargin: 20
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            checked: true

            ButtonGroup.group: tabBarButtons
        }

        TabBarButton
        {
            id: channelsButton
            text: qsTr("Channels")
            width: 80
            anchors.leftMargin: 10
            anchors.left: homeButton.right
            anchors.verticalCenter: parent.verticalCenter

            ButtonGroup.group: tabBarButtons
        }

        TabBarButton
        {
            id: mixesButton
            text: qsTr("Mixes")
            width: 80
            anchors.leftMargin: 10
            anchors.left: channelsButton.right
            anchors.verticalCenter: parent.verticalCenter

            ButtonGroup.group: tabBarButtons
        }

        TabBarButton
        {
            id: channelPresetsButton
            text: qsTr("Channel Presets")
            anchors.leftMargin: 10
            anchors.left: mixesButton.right
            anchors.verticalCenter: parent.verticalCenter

            ButtonGroup.group: tabBarButtons
        }

        TabBarButton
        {
            id: mixPresetsButton
            text: qsTr("Mix Presets")
            anchors.leftMargin: 10
            anchors.left: channelPresetsButton.right
            anchors.verticalCenter: parent.verticalCenter

            ButtonGroup.group: tabBarButtons
        }

        TabBarButton
        {
            id: configurationsButton
            text: qsTr("Configurations")
            anchors.leftMargin: 10
            anchors.left: mixPresetsButton.right
            anchors.verticalCenter: parent.verticalCenter

            ButtonGroup.group: tabBarButtons
        }
    }

    Item
    {
        id: pagesArea
        anchors.topMargin: tabBar.y + tabBar.height
        anchors.fill: parent

        HomePage
        {
            id: homePage
            anchors.fill: parent
            visible: homeButton.checked
        }

        ChannelsPage
        {
            id: channelsPage
            anchors.fill: parent
            visible: channelsButton.checked
        }

        MixesPage
        {
            id: mixesPage
            anchors.fill: parent
            visible: mixesButton.checked
        }

        ChannelPresetsPage
        {
            id: channelPresetsPage
            anchors.fill: parent
            visible: channelPresetsButton.checked
        }

        MixPresetsPage
        {
            id: mixPresetsPage
            anchors.fill: parent
            visible: mixPresetsButton.checked
        }

        ConfigurationsPage
        {
            id: configurationsPage
            anchors.fill: parent
            visible: configurationsButton.checked
        }
    }

    Rectangle
    {
        id: shadowingRect
        anchors.fill: parent
        visible: false

        color: "#000000"
        opacity: 0.4

        MouseArea
        {
            anchors.fill: parent
        }
    }


    ViewCommandListPopup
    {
        id: viewCommandListPopup
        width: applicationWindow.width * 0.6
        height: applicationWindow.height * 0.8
        anchors.centerIn: applicationWindow.contentItem
    }

    ViewMixCommandListPopup
    {
        id: viewMixCommandListPopup
        width: applicationWindow.width * 0.6
        height: applicationWindow.height * 0.8
        anchors.centerIn: applicationWindow.contentItem
    }

//    CommandListPopup
//    {
//        id: commandListPopup
//        width: applicationWindow.width * 0.8
//        height: applicationWindow.height * 0.8
//        anchors.centerIn: applicationWindow.contentItem
//    }

//    ChannelPresetPopup
//    {
//        id: channelPresetPopup
//        width: applicationWindow.width * 0.8
//        height: applicationWindow.height * 0.8
//        anchors.centerIn: applicationWindow.contentItem
//    }

//    LoadChannelPresetPopup
//    {
//        id: loadChannelPresetPopup
//        width: applicationWindow.width * 0.8
//        height: applicationWindow.height * 0.8
//        anchors.centerIn: applicationWindow.contentItem
//    }

    LoadPredefinedListPopup
    {
        id: loadPredefinedListPopup
        width: applicationWindow.width * 0.4
        height: applicationWindow.height * 0.4
        anchors.centerIn: applicationWindow.contentItem
    }

    LoadMixPresetPopup
    {
        id: loadMixPresetPopup
        width: applicationWindow.width * 0.4
        height: applicationWindow.height * 0.4
        anchors.centerIn: applicationWindow.contentItem
    }

    ProjectNamePopup
    {
        id: projectNamePopup
        anchors.centerIn: applicationWindow.contentItem
    }

    PresetUsePopup
    {
        id: presetUsePopup
        anchors.centerIn: applicationWindow.contentItem
    }

    MixPresetUsePopup
    {
        id: mixPresetUsePopup
        anchors.centerIn: applicationWindow.contentItem
    }

    ChangeChannelPresetPopup
    {
        id: changeChannelPresetPopup
        anchors.centerIn: applicationWindow.contentItem
    }

    ChangeMixPresetPopup
    {
        id: changeMixPresetPopup
        anchors.centerIn: applicationWindow.contentItem
    }
}
