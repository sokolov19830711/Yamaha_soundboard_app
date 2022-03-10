import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    property string currentPresetName

    onVisibleChanged:
    {
        if (visible)
        {
            commandList.loadList(currentPresetName)
        }
    }

    Text
    {
        id: presetNameTitle
        color: "#000000"
        text: qsTr("Command List for ") + currentPresetName
        font.pixelSize: 18

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 30
        anchors.top: parent.top
    }

    Rectangle
    {
        id: commandsFrame
        width: parent.width * 0.9
        height: parent.height * 0.8
        color: "transparent"
        radius: 6
        border.color: "#ebebeb"

        anchors.centerIn: parent

        ListView
        {
            id: commandList
            anchors.topMargin: 10
            anchors.top: parent.top
            anchors.leftMargin: 10
            anchors.left: parent.left
            anchors.rightMargin: 10
            anchors.right: parent.right
            anchors.bottomMargin: 10
            anchors.bottom: parent.bottom

            property string currentCommandName: ""

            ScrollBar.vertical: ScrollBar {}

            clip: true

            function loadList(presetName)
            {
                commandListModel.clear()
                let list = (presetManager.getPreset(currentPresetName))["commands"]
                for(var i = 0; i < list.length; i++)
                {
                    commandListModel.append({commandName : "", commandString : list[i]})
                }

            }

            model: ListModel
            {
                id: commandListModel
            }

            delegate: Component
            {
                id: commandListDelegate
                Button
                {
                    checkable: true
                    width: commandList.width
                    text: commandName

                    background: Rectangle
                    {
                        color: parent.checked ? "#777777" : "#ffffff"
                    }

                    contentItem: Text
                    {
                        text: parent.text
                        color: parent.checked ? "#ffffff" : "#222222"
                        font.pixelSize: 16
                    }

                    Text
                    {
                        text: commandString
                        color: parent.checked ? "#ffffff" : "#222222"
                        font.pixelSize: 16

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 150
                        anchors.left: parent.left
                    }

                    ButtonGroup.group: commandListButtonsGroup

                    onCheckedChanged:
                    {
                        if(checked)
                        {

                        }
                    }
                }
            }

            ButtonGroup
            {
                id: commandListButtonsGroup
            }
        }
    }

    SbcButton
    {
        width: 60
        text: qsTr("Got It")

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        anchors.top: commandsFrame.bottom

        onClicked:
        {
            parent.visible = false
        }
    }
}
