import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    width: 600
    height: 400

    property string channelName
    property int channelNo
    property string applyButtonText

    onVisibleChanged:
    {
        if (visible)
        {
            let list = presetManager.getChannelPresetNamesList()
            list.unshift("<None>")
            selectPresetBox.model = list

            let currentChanel = presetManager.getChannel(channelName)
            channelNo = parseInt(currentChanel["channel"])
            selectPresetBox.currentIndex = selectPresetBox.model.indexOf(currentChanel["presetInUse"])

            channelNameTitle.text = "Channel Name: " + channelName
        }
    }

    Text
    {
        id: channelNameTitle
        color: "#444444"
        text: qsTr("Channel Name:")
        font.pixelSize: 16
        font.bold: true

        anchors.topMargin: 70
        anchors.top: parent.top
        anchors.left: selectPresetBox.left
    }

    Text
    {
        id: selectPresetTitle
        color: "#444444"
        text: qsTr("Select Channel Preset to Use")
        font.pixelSize: 16

        anchors.left: selectPresetBox.left
        anchors.topMargin: 60
        anchors.top: channelNameTitle.bottom
    }

    ComboBox
    {
        id: selectPresetBox
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        anchors.top: selectPresetTitle.bottom
        font.pixelSize: 16
    }


    SbcButton
    {
        id: assignButton
        text: applyButtonText
        width: (selectPresetBox.width - 10) / 2
        height: 50
        color: "#5850EA"
        textColor: "#ffffff"
        textSize: 16

        anchors.right: selectPresetBox.right
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        onClicked:
        {
            presetManager.updateChannel(channelName, channelName, selectPresetBox.currentText, channelNo)
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

        anchors.left: selectPresetBox.left
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        onClicked:
        {
            parent.visible = false
        }
    }
}

