import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    width: 320
    height: 260

    onVisibleChanged:
    {
        if (visible)
        {
            projectNameInput.text = ""
            channelCountBox.value = 16
        }
    }

    Text
    {
        id: projectNameTitle
        color: "#000000"
        text: qsTr("Project Name")
        font.pixelSize: 16

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 40
        anchors.top: parent.top
    }

    Rectangle
    {
        id: projectNameFrame
        width: 260
        height: 30

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        anchors.top: projectNameTitle.bottom

        color: "transparent"
        border.color: "#ebebeb"
        radius: 2

        TextInput
        {
            id: projectNameInput
            font.pixelSize: 16
            anchors.margins: 4
            anchors.fill: parent
        }
    }

    Text
    {
        id: channelsTitle
        color: "#000000"
        text: qsTr("Channels count")
        font.pixelSize: 16

        anchors.left: projectNameFrame.left
        anchors.topMargin: 40
        anchors.top: projectNameFrame.bottom
    }

    SpinBox
    {
        id: channelCountBox
        anchors.verticalCenter: channelsTitle.verticalCenter
        anchors.right: projectNameFrame.right

        font.pixelSize: 18
        from: 1
        to: 128
    }

    SbcButton
    {
        id: saveProjectButton
        text: qsTr("Save")
        width: 80
        color: "#43A047"
        textColor: "#ffffff"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        enabled: projectNameInput.displayText != ""

        onClicked:
        {
            presetManager.createProject(projectNameInput.displayText, channelCountBox.value)
            parent.visible = false
        }
    }
}

