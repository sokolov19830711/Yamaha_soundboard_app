import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    id: loadChannelPresetPopup

    property string currentPresetName
    property string currentGroupName
    property string currentCommandName
    property var currentRequestCommand: []
    property var currentChangeCommand: []
    property var currentCommandList: []

    property alias commandList: commandList

    onVisibleChanged:
    {
        if (visible)
        {
            consoleChannel.model = presetManager.getChannelNamesList()
        }
    }

    onCurrentPresetNameChanged:
    {
        presetNameInput.text = currentPresetName
        commandList.loadList()
    }

    function addCommandToPresetList(groupName, commandName)
    {
        let newCommand = {}
        newCommand["groupName"] = groupName
        newCommand["commandName"] = commandName

        let currentChangeCommand = jsonConfigManager.getChangeSeq(groupName, commandName)
        let commandString = ""

        commandString += currentChangeCommand[0]
        commandString += " "
        commandString += currentChangeCommand[1]
        commandString += " "

        commandString += currentChangeCommand[2][0]

        let midiChannel = settings.value("midiChannel").toString(16).toUpperCase()

        commandString += midiChannel
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

//        var cc = consoleChannel.text.toUpperCase()

//        while (cc.length < 4)
//        {
//            var temp = cc
//            cc = ""
//            cc += "0"
//            cc += temp
//        }

//        for (var i = 0; i < cc.length - 1; i = i + 2)
//        {
//            commandString += cc[i]
//            commandString += cc[i + 1]
//            commandString += " "
//        }

        var cc = presetManager.intToMidi2bytes(consoleChannel.channelNo)
        commandString += cc[0]
        commandString += " "
        commandString += cc[1]
        commandString += " "

        cc = commandString.slice(-6, -1)

        let request = currentRequestCommand
        request.splice(2, 1, "3" + midiChannel)
        request.splice(10, 1, cc.split(" ")[0])
        request.splice(11, 1, cc.split(" ")[1])

        let data = portsManager.getDataForRequest(request)

        commandString += data.join(" ")
        commandString += " "
        commandString += "F7"

        newCommand["commandString"] = commandString
        currentCommandList.push(newCommand)
        commandList.updateListView()
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
        id: consoleChannelTitle
        color: "#000000"
        text: qsTr("Console Channel")
        font.pixelSize: 14

        anchors.topMargin: 40
        anchors.top: presetNameTitle.bottom
        anchors.leftMargin: -150
        anchors.left: commandSelectionItem.right
    }

    Rectangle
    {
        id: consoleChannelFrame
        width: 220
        height: 30
        anchors.topMargin: 10
        anchors.top: consoleChannelTitle.bottom
        anchors.left: consoleChannelTitle.left

        color: "transparent"
//        border.color: "#ebebeb"
//        radius: 2

//        TextInput
//        {
//            id: consoleChannel
//            font.pixelSize: 16
//            font.capitalization: Font.AllUppercase
//            horizontalAlignment: TextInput.AlignHCenter

//            anchors.margins: 4
//            anchors.fill: parent
//            validator: RegExpValidator { regExp: /[0-9A-Fa-f]+/ }
//        }

        ComboBox
        {
            id: consoleChannel
            anchors.fill: parent

            property int channelNo: -1

            onCurrentTextChanged:
            {
                let currChannel = presetManager.getChannel(consoleChannel.currentText)["channel"]
                channelNo = currChannel !== undefined ? currChannel : -1
            }
        }
    }

    SbcButton
    {
        id: addPredefinedCommandsButton
        text: qsTr("Load Predefined List")
        width: 160
        color: "#43A047"
        textColor: "#ffffff"

        anchors.rightMargin: 20
        anchors.right: addCommandButton.left
        anchors.top: consoleChannelFrame.top

        enabled: consoleChannel.text != ""

        onClicked:
        {
            let predefinedGroupsList = jsonConfigManager.getCommandGroupsList(1)
            predefinedGroupsList.forEach(function(groupName)
            {
                let cmdList = jsonConfigManager.getCommandList(groupName)
                cmdList.forEach(function(cmdName)
                {
                    addCommandToPresetList(groupName, cmdName)
                })
            })
        }
    }

    SbcButton
    {
        id: addCommandButton
        text: qsTr("Add Command")
        width: 140
        color: "#5850EA"
        textColor: "#ffffff"

        anchors.rightMargin: 20
        anchors.right: parent.right
        anchors.top: consoleChannelFrame.top

        enabled: consoleChannel.channelNo != -1 && currentRequestCommand.length > 0

        onClicked:
        {
            addCommandToPresetList(currentGroupName, currentCommandName)
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
        anchors.left: consoleChannelTitle.left
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
                loadChannelPresetPopup.currentCommandList = presetManager.getPresetCommands(loadChannelPresetPopup.currentPresetName)
                updateListView()
            }

            function updateListView()
            {
                commandList.currentCommandName = ""
                commandListModel.clear()
                let list = loadChannelPresetPopup.currentCommandList
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
                target: jsonConfigManager
                function onJsonConfigFileChanged(name)
                {
                    groupsList.loadList()
                }
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
            presetManager.updateChannelPreset(currentPresetName, currentCommandList)
            parent.visible = false
        }
    }
}
