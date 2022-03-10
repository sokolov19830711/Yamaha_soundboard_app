import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    width: 600
    height: 400

    property string mixName
    property int mixIndex
    property string applyButtonText

    onVisibleChanged:
    {
        if (visible)
        {
            let list = presetManager.getMixPresetNamesList()
            list.unshift("<None>")
            selectPresetBox.model = list

            mixNameInput.text = mixName
        }
    }

    Text
    {
        id: mixNameTitle
        color: "#444444"
        text: qsTr("Mix Name:")
        font.pixelSize: 16

        anchors.topMargin: 70
        anchors.top: parent.top
        anchors.left: selectPresetBox.left
    }

    Rectangle
    {
        id: channelNameFrame
        height: 30

        anchors.verticalCenter: mixNameTitle.verticalCenter
        anchors.leftMargin: 20
        anchors.left: mixNameTitle.right
        anchors.right: selectPresetBox.right

        color: "transparent"
        border.color: "#ebebeb"
        radius: 2

        TextInput
        {
            id: mixNameInput
            font.pixelSize: 16
            anchors.margins: 4
            anchors.fill: parent

            text: mixName
        }
    }

    Text
    {
        id: selectPresetTitle
        color: "#444444"
        text: qsTr("Select Mix Preset to Use")
        font.pixelSize: 16

        anchors.left: selectPresetBox.left
        anchors.topMargin: 60
        anchors.top: mixNameTitle.bottom
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

        enabled: mixNameInput.displayText != ""
        onClicked:
        {
            presetManager.updateMix(mixName, mixNameInput.displayText, selectPresetBox.currentText)
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

