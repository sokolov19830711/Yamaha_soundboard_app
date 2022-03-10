import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    id: channelPresetPopup
    property string currentPresetName
    property string currentGroupName
    property string currentCommandName
    property var currentCommandList: []
    property var currentRequestCommand: []
    property var currentChangeCommand: []

    property alias commandList: commandList

    onCurrentPresetNameChanged:
    {
        presetNameInput.text = currentPresetName
        commandList.loadList()
    }

    function resetCommandValuesFields()
    {
        midiChannel.text = "0"
        consoleChannel.text = "0000"
        data.text = "0000000000"
    }

    CommandSelectionItem
    {
        id: commandSelectionItem
        width: parent.width * 0.6
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Connections
        {
            target: commandSelectionItem
            function onCommandClicked(groupName, commandName)
            {
                resetCommandValuesFields()
                currentGroupName = groupName
                currentCommandName = commandName
                currentChangeCommand = jsonConfigManager.getChangeSeq(groupName, commandName)
                currentRequestCommand = jsonConfigManager.getRequestSeq(groupName, commandName)
            }
        }
    }

    Text
    {
        id: presetNameTitle
        color: "#000000"
        text: qsTr("Preset Name")
        font.pixelSize: 16

        anchors.verticalCenter: presetNameFrame.verticalCenter
        anchors.rightMargin: 10
        anchors.right: presetNameFrame.left
    }

    Rectangle
    {
        id: presetNameFrame
        width: 200
        height: 30

        anchors.topMargin: 48
        anchors.top: commandSelectionItem.top
        anchors.rightMargin: 20
        anchors.right: parent.right

        color: "transparent"
        border.color: "#ebebeb"
        radius: 2

        TextInput
        {
            id: presetNameInput
            font.pixelSize: 16
            anchors.margins: 4
            anchors.fill: parent

            onTextChanged: currentPresetName = presetNameInput.text
        }
    }

    Text
    {
        id: currentCommandTitle
        color: "#000000"
        text: qsTr("Selected command:")
        font.pixelSize: 14

        anchors.topMargin: 40
        anchors.top: presetNameTitle.bottom
        anchors.leftMargin: -150
        anchors.left: commandSelectionItem.right
    }

    Switch
    {
        id: commandModeSwitch

        anchors.verticalCenter: currentCommandTitle.verticalCenter
        anchors.rightMargin: 20
        anchors.right: parent.right

        checked: true
    }

    Text
    {
        id: commandModeText
        color: "#000000"
        font.pixelSize: 14
        font.bold: true

        anchors.verticalCenter: currentCommandTitle.verticalCenter
        anchors.rightMargin: 10
        anchors.right: commandModeSwitch.left

        text: commandModeSwitch.checked ? "Change" : "Request"
    }

    Text
    {
        id: currentCommandText
        color: "#000000"
        font.pixelSize: 14
        font.bold: true

        anchors.verticalCenter: currentCommandTitle.verticalCenter
        anchors.leftMargin: 10
        anchors.left: currentCommandTitle.right

        Connections
        {
            target: commandSelectionItem
            function onCommandClicked(groupName, commandName)
            {
                currentCommandText.text = commandName
            }
        }
    }

    Text
    {
        id: midiChannelTitle
        color: "#000000"
        text: qsTr("MIDI Channel")
        font.pixelSize: 14

        anchors.topMargin: 20
        anchors.top: currentCommandTitle.bottom
        anchors.left: currentCommandTitle.left
    }

    Rectangle
    {
        id: midiChannelFrame
        width: 40
        height: 30
        anchors.topMargin: 10
        anchors.top: midiChannelTitle.bottom
        anchors.left: midiChannelTitle.left

        color: "transparent"
        border.color: "#ebebeb"
        radius: 2

        TextInput
        {
            id: midiChannel
            font.pixelSize: 16
            font.capitalization: Font.AllUppercase
            horizontalAlignment: TextInput.AlignHCenter

            anchors.margins: 4
            anchors.fill: parent
            validator: RegExpValidator { regExp: /[0-9A-Fa-f]+/ }
        }
    }

    Text
    {
        id: consoleChannelTitle
        color: "#000000"
        text: qsTr("Console Channel")
        font.pixelSize: 14

        anchors.top: midiChannelTitle.top
        anchors.leftMargin: 20
        anchors.left: midiChannelTitle.right
    }

    Rectangle
    {
        id: consoleChannelFrame
        width: 60
        height: 30
        anchors.topMargin: 10
        anchors.top: consoleChannelTitle.bottom
        anchors.left: consoleChannelTitle.left

        color: "transparent"
        border.color: "#ebebeb"
        radius: 2

        TextInput
        {
            id: consoleChannel
            font.pixelSize: 16
            font.capitalization: Font.AllUppercase
            horizontalAlignment: TextInput.AlignHCenter

            anchors.margins: 4
            anchors.fill: parent
            validator: RegExpValidator { regExp: /[0-9A-Fa-f]+/ }
        }
    }

    Text
    {
        id: dataTitle
        color: "#000000"
        text: qsTr("Data to send")
        font.pixelSize: 14

        anchors.top: consoleChannelTitle.top
        anchors.leftMargin: 20
        anchors.left: consoleChannelTitle.right

        visible: commandModeSwitch.checked
    }

    Rectangle
    {
        id: dataFrame
        width: 140
        height: 30
        anchors.topMargin: 10
        anchors.top: dataTitle.bottom
        anchors.left: dataTitle.left

        color: "transparent"
        border.color: "#ebebeb"
        radius: 2

        visible: commandModeSwitch.checked

        TextInput
        {
            id: data
            font.pixelSize: 16
            font.capitalization: Font.AllUppercase
            horizontalAlignment: TextInput.AlignHCenter

            anchors.margins: 4
            anchors.fill: parent
            validator: RegExpValidator { regExp: /[0-9A-Fa-f]+/ }
        }
    }

    SbcButton
    {
        id: addCommandButton
        text: qsTr("Add Command")
        width: 140
        color: "#43A047"
        textColor: "#ffffff"

        anchors.rightMargin: 20
        anchors.right: parent.right
        anchors.top: dataFrame.top

        enabled: currentCommandText.text != ""

        onClicked:
        {
            let newCommand = {}
            newCommand["groupName"] = currentGroupName
            newCommand["commandName"] = currentCommandName

            let commandString = ""
            commandString += currentChangeCommand[0]
            commandString += " "
            commandString += currentChangeCommand[1]
            commandString += " "

            let change = commandModeSwitch.checked

            if(change)
            {
                commandString += currentChangeCommand[2][0]
                commandString += midiChannel.text
                commandString += " "
                commandString += currentChangeCommand[3]
                commandString += " "
                commandString += currentChangeCommand[4]
                commandString += " "
                commandString += currentChangeCommand[5]
                commandString += " "
                commandString += currentChangeCommand[6]
                commandString += " "
                commandString += currentChangeCommand[7]
                commandString += " "
                commandString += currentChangeCommand[8]
                commandString += " "
                commandString += currentChangeCommand[9]
                commandString += " "
            }
            else
            {
                commandString += currentRequestCommand[2][0]
                commandString += midiChannel.text
                commandString += " "
                commandString += currentRequestCommand[3]
                commandString += " "
                commandString += currentRequestCommand[4]
                commandString += " "
                commandString += currentRequestCommand[5]
                commandString += " "
                commandString += currentRequestCommand[6]
                commandString += " "
                commandString += currentRequestCommand[7]
                commandString += " "
                commandString += currentRequestCommand[8]
                commandString += " "
                commandString += currentRequestCommand[9]
                commandString += " "
            }

            var cc = consoleChannel.text.toUpperCase()

            while (cc.length < 4)
            {
                var temp = cc
                cc = ""
                cc += "0"
                cc += temp
            }

            for (var i = 0; i < cc.length - 1; i = i + 2)
            {
                commandString += cc[i]
                commandString += cc[i + 1]
                commandString += " "
            }

            if (change)
            {
                var dd = data.text.toUpperCase()

                while (dd.length < 10)
                {
                    temp = dd
                    dd = ""
                    dd += "0"
                    dd += temp
                }

                for (i = 0; i < dd.length - 1; i = i + 2)
                {
                    commandString += dd[i]
                    commandString += dd[i + 1]
                    commandString += " "
                }
            }

            commandString += "F7"
            newCommand["commandString"] = commandString
            currentCommandList.push(newCommand)
            commandList.updateListView()
        }
    }

    SbcButton
    {
        id: removeCommandButton
        text: qsTr("Remove Command")
        width: 140
        color: "#EF5350"
        textColor: "#ffffff"

        anchors.rightMargin: 20
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.top: addCommandButton.bottom

        enabled: commandList.currentCommandIndex >= 0

        onClicked:
        {
            currentCommandList.splice(commandList.currentCommandIndex, 1)
            commandList.updateListView()
        }
    }

    Rectangle
    {
        anchors.topMargin: 20
        anchors.top: removeCommandButton.bottom
        anchors.left: currentCommandTitle.left
        anchors.rightMargin: 20
        anchors.right: parent.right
        anchors.bottomMargin: 20
        anchors.bottom: savePresetButton.top

        color: "#ffffff"
        border.color: "#ebebeb"
        radius: 10

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
            property int currentCommandIndex: -1

            ScrollBar.vertical: ScrollBar {}

            clip: true

            function loadList()
            {
                commandList.currentCommandName = ""
                channelPresetPopup.currentCommandList = commandListManager.getPresetCommands(channelPresetPopup.currentPresetName)
                updateListView()
            }

            function updateListView()
            {
                commandList.currentCommandName = ""
                commandListModel.clear()
                let list = channelPresetPopup.currentCommandList
                for(var i = 0; i < list.length; i++)
                {
                    commandListModel.append({positionText: i + 1, commandName: list[i]["commandName"] + " " + list[i]["commandString"]})
                }
            }

            model: ListModel
            {
                id: commandListModel
            }

            delegate: Component
            {
                id: commandListDelegate

                Item
                {
                    height: 40
                    width: commandList.width
//                    anchors.left: commandList.left
//                    anchors.right: commandList.right

                    Rectangle
                    {
                        id: delegateBackground
                        anchors.fill: parent
                        color: presetNameButton.checked ? "#ebebeb" : "transparent"
                    }

                    Text
                    {
                        id: pos
                        width: 20
                        color: "#777777"
                        font.pixelSize: 14
                        text: positionText

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                        anchors.left: parent.left
                    }

                    Button
                    {
                        id: presetNameButton
                        checkable: true
                        height: parent.height
                        text: commandName

                        anchors.leftMargin: 10
                        anchors.left: pos.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right

                        background: Rectangle
                        {
                            color: "transparent"
                        }

                        contentItem: Text
                        {
                            font.pixelSize: 16
                            text: parent.text
                            color: "#222222"
                            verticalAlignment: Text.AlignVCenter
                        }

                        ButtonGroup.group: listButtonsGroup

                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                commandList.currentCommandName = commandName
                                commandList.currentCommandIndex = parseInt(positionText) - 1
                            }
                        }
                    }
                }
            }

            ButtonGroup
            {
                id: listButtonsGroup
            }

            Connections
            {
//                target: jsonConfigManager
//                function onJsonConfigFileChanged(name)
//                {
//                    groupsList.loadList()
//                }
            }

            Component.onCompleted:
            {
                loadList()
            }
        }
    }

    SbcButton
    {
        id: savePresetButton
        text: qsTr("Save Preset")
        width: 120
        color: "#43A047"
        textColor: "#ffffff"

        anchors.rightMargin: 20
        anchors.right: parent.right
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        enabled: presetNameInput.text != ""

        onClicked:
        {
            commandListManager.updateCommandList("channelPreset", currentPresetName, currentCommandList)
            parent.visible = false
        }
    }
}
