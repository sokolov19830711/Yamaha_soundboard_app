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
            selectMixBox.model = presetManager.getMixNamesList()
        }
    }

    Text
    {
        id: presetNameTitle
        color: "#000000"
        text: qsTr("Mix Preset Name: ") + presetName
        font.pixelSize: 18

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 30
        anchors.top: parent.top
    }

    Text
    {
        id: selectMixTitle
        color: "#444444"
        text: qsTr("Select Mix to Use Preset On")
        font.pixelSize: 14

        anchors.left: selectMixBox.left
        anchors.topMargin: 60
        anchors.top: presetNameTitle.bottom
    }

    ComboBox
    {
        id: selectMixBox
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        anchors.top: selectMixTitle.bottom
        font.pixelSize: 16
    }

    Text
    {
        id: progressText
        color: "#000000"
        text: qsTr("Applying the preset...")
        font.pixelSize: 16

        anchors.topMargin: 50
        anchors.top: selectMixBox.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        visible: false

        Connections
        {
            target: presetManager
            function onMixPresetSendingStarted()
            {
                progressText.visible = true
                progressBar.visible = true
            }
        }

        Connections
        {
            target: presetManager
            function onMixPresetSendingFinished()
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
        anchors.top: selectMixBox.bottom
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
        text: qsTr("Assign to this Mix")
        width: (selectMixBox.width - 10) / 2
        height: 50
        color: "#5850EA"
        textColor: "#ffffff"
        textSize: 16

        anchors.right: selectMixBox.right
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        onClicked:
        {
            presetManager.assignMixPreset(selectMixBox.currentText, presetName)
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

        anchors.left: selectMixBox.left
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        onClicked:
        {
            parent.visible = false
        }
    }
}

