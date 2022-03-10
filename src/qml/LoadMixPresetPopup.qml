import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    id: loadMixPresetPopup

    property string currentPresetName
    property string currentPresetDesc
    property bool editMode: false

    onVisibleChanged:
    {
        if (visible)
        {
            presetNameInput.text = currentPresetName
            presetDescInput.text = currentPresetDesc
            selectMixBox.model = presetManager.getMixNames()
        }
    }

    Text
    {
        id: presetNameTitle
        color: "#000000"
        text: qsTr("Preset Name")
        font.pixelSize: 16

        anchors.leftMargin: 20
        anchors.topMargin: 60
        anchors.left: parent.left
        anchors.top: parent.top
    }

    Rectangle
    {
        id: presetNameFrame
        height: 30

        anchors.verticalCenter: presetNameTitle.verticalCenter
        anchors.leftMargin: 30
        anchors.left: presetNameTitle.right
        anchors.right: loadButton.right

        color: "transparent"
        border.color: "#ebebeb"
        radius: 2

        TextInput
        {
            id: presetNameInput
            font.pixelSize: 16
            anchors.margins: 4
            anchors.fill: parent
        }
    }

    Text
    {
        id: presetDescTitle
        color: "#000000"
        text: qsTr("Description")
        font.pixelSize: 16

        anchors.leftMargin: 20
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.top: presetNameTitle.bottom
    }

    Rectangle
    {
        id: presetDescFrame
        height: 30

        anchors.verticalCenter: presetDescTitle.verticalCenter
        anchors.left: presetNameFrame.left
        anchors.right: loadButton.right

        color: "transparent"
        border.color: "#ebebeb"
        radius: 2

        TextInput
        {
            id: presetDescInput
            font.pixelSize: 16
            anchors.margins: 4
            anchors.fill: parent
        }
    }

    Text
    {
        id: consoleChannelTitle
        color: "#000000"
        text: qsTr("Select Mix")
        font.pixelSize: 16

        anchors.topMargin: 40
        anchors.top: presetDescTitle.bottom
        anchors.left: presetDescTitle.left
    }

    Rectangle
    {
        id: consoleChannelFrame
        width: parent.width * 0.5 - 40
        height: 30
        anchors.topMargin: 10
        anchors.top: consoleChannelTitle.bottom
        anchors.left: consoleChannelTitle.left

        color: "transparent"

        ComboBox
        {
            id: selectMixBox
            anchors.fill: parent
        }
    }

    SbcButton
    {
        id: loadButton
        text: qsTr("Load Preset")
        width: consoleChannelFrame.width
        color: "#43A047"
        textColor: "#ffffff"

        anchors.leftMargin: 20
        anchors.left: consoleChannelFrame.right
        anchors.top: consoleChannelFrame.top

        enabled: selectMixBox.currentText != "" && presetNameInput.text != "" && !progressText.visible

        onClicked:
        {
            presetManager.loadMixPreset(presetNameInput.text, presetDescInput.text, selectMixBox.currentText)
        }
    }

    Text
    {
        id: progressText
        color: "#000000"
        text: qsTr("In progress...")
        font.pixelSize: 16

        anchors.topMargin: 50
        anchors.top: loadButton.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        visible: false

        Connections
        {
            target: presetManager
            function onMixPresetLoadingStarted()
            {
                progressText.visible = true
                progressBar.visible = true
            }
        }

        Connections
        {
            target: presetManager
            function onMixPresetLoadingFinished()
            {
                progressText.visible = false
                progressBar.visible = false
                loadMixPresetPopup.visible = false
            }
        }
    }

    ProgressBar
    {
        id: progressBar
        width: parent.width * 0.8
        font.pixelSize: 16

        anchors.topMargin: 40
        anchors.top: loadButton.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        visible: false

        Connections
        {
            target: presetManager
            function onProgressChanged(position) {progressBar.value = position}
        }

        Connections
        {
            target: presetManager
            function onMixPresetLoadingFinished()
            {
                progressText.visible = false
                progressBar.visible = false
                loadMixPresetPopup.visible = false
            }
        }
    }

    SbcButton
    {
        id: saveButton
        text: qsTr("Save Changes")
        width: loadButton.width
        color: "#43A047"
        textColor: "#ffffff"

        anchors.left: loadButton.left
        anchors.topMargin: 40
        anchors.top: loadButton.bottom

        visible: editMode && !progressText.visible

        enabled: presetNameInput.text != "" && (presetNameInput.text != currentPresetName || presetDescInput.text != currentPresetDesc)

        onClicked:
        {
            presetManager.updateMixPresetInfo(currentPresetName, presetNameInput.text, presetDescInput.text)
            loadMixPresetPopup.visible = false
        }
    }

    SbcButton
    {
        id: cancelButton
        text: qsTr("Cancel")
        width: saveButton.width

        anchors.left: consoleChannelFrame.left
        anchors.topMargin: 40
        anchors.top: loadButton.bottom

        visible: editMode && !progressText.visible

        onClicked:
        {
            loadMixPresetPopup.visible = false
        }
    }
}
