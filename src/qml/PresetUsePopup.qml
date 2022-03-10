import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    width: 600
    height: 400

    property string presetName

    onVisibleChanged:
    {
        if (visible)
        {
            selectChannelBox.model = presetManager.getChannelNamesList()
        }
    }

    Text
    {
        id: presetNameTitle
        color: "#000000"
        text: qsTr("Channel Preset Name: ") + presetName
        font.pixelSize: 18

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 30
        anchors.top: parent.top
    }

    Text
    {
        id: selectChannelTitle
        color: "#444444"
        text: qsTr("Select Channel to Use Preset On")
        font.pixelSize: 14

        anchors.left: selectChannelBox.left
        anchors.topMargin: 60
        anchors.top: presetNameTitle.bottom
    }

    ComboBox
    {
        id: selectChannelBox
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        anchors.top: selectChannelTitle.bottom
        font.pixelSize: 16
    }

    Text
    {
        id: progressText
        color: "#000000"
        text: qsTr("Applying the preset...")
        font.pixelSize: 16

        anchors.topMargin: 50
        anchors.top: selectChannelBox.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        visible: false

        Connections
        {
            target: presetManager
            function onChannelPresetSendingStarted()
            {
                progressText.visible = true
                progressBar.visible = true
            }
        }

        Connections
        {
            target: presetManager
            function onChannelPresetSendingFinished()
            {
                progressText.visible = false
                progressBar.visible = false
            }
        }
    }

    ProgressBar
    {
        id: progressBar
        width: parent.width * 0.8
        font.pixelSize: 16

        anchors.topMargin: 40
        anchors.top: selectChannelBox.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        visible: false

        Connections
        {
            target: presetManager
            function onProgressChanged(position) {progressBar.value = position}
        }
    }

    SbcButton
    {
        id: assignButton
        text: qsTr("Assign to this Channel")
        width: (selectChannelBox.width - 10) / 2
        height: 50
        color: "#5850EA"
        textColor: "#ffffff"
        textSize: 16

        anchors.right: selectChannelBox.right
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        onClicked:
        {
            presetManager.assignPreset(selectChannelBox.currentText, presetName)
            parent.visible = false
        }
    }

    SbcButton
    {
        id: cancelButton
        text: qsTr("Cancel")
        width: assignButton.width
        height: assignButton.height
        textSize: 16

        anchors.left: selectChannelBox.left
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        onClicked:
        {
            parent.visible = false
        }
    }
}

