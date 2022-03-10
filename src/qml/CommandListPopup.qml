import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

PopupWindow
{
    Text
    {
        id: groupsText
        color: "#000000"
        text: qsTr("Command Groups")
        font.pixelSize: 18

        anchors.topMargin: 40
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.left: parent.left
    }

    Rectangle
    {
        width: groupsFrame.width
        height: 2
        anchors.topMargin: 6
        anchors.top: groupsText.bottom
        anchors.horizontalCenter: groupsFrame.horizontalCenter
        color: "#ebebeb"
    }

    Rectangle
    {
        id: groupsFrame
        width: parent.width * 0.25
        color: "transparent"
        radius: 6
        border.color: "#ebebeb"

        anchors.topMargin: 20
        anchors.top: groupsText.bottom
        anchors.leftMargin: 20
        anchors.left: parent.left
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        ListView
        {
            id: groupsList
            anchors.topMargin: 10
            anchors.top: parent.top
            anchors.leftMargin: 10
            anchors.left: parent.left
            anchors.rightMargin: 10
            anchors.right: parent.right
            anchors.bottomMargin: 10
            anchors.bottom: parent.bottom

            property string currentGroupName: ""

            ScrollBar.vertical: ScrollBar {}

            clip: true

            function loadList()
            {
                currentGroupName = ""
                groupsListModel.clear()
                let list = jsonConfigManager.getCommandGroupsList(0)
                for(var i = 0; i < list.length; i++)
                {
                    groupsListModel.append({groupName : list[i]})
                }

            }

            model: ListModel
            {
                id: groupsListModel
            }

            delegate: Component
            {
                id: groupsListDelegate
                Button
                {
                    checkable: true
                    width: groupsList.width
                    text: groupName

                    background: Rectangle
                    {
                        color: parent.checked ? "#777777" : "#ffffff"
                    }

                    contentItem: Text
                    {
                        text: parent.text
                        color: parent.checked ? "#ffffff" : "#222222"
                    }

                    ButtonGroup.group: listButtonsGroup

                    onCheckedChanged:
                    {
                        if(checked)
                        {
                            groupsList.currentGroupName = groupName
                            commandList.loadList(groupName)
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

//        Item
//        {
//            id: upperGradientBackground
//            height: 20
//            anchors.leftMargin: 3
//            anchors.left: parent.left
//            anchors.rightMargin: 30
//            anchors.right: parent.right
//            anchors.topMargin: 3
//            anchors.top: parent.top

//            Rectangle
//            {
//                id: upperRect1
//                height: parent.height * 0.5
//                anchors.top: parent.top
//                anchors.left: parent.left
//                anchors.right: parent.right
//                color: "#ffffff"
//                opacity: 0.8
//            }

//            Rectangle
//            {
//                anchors.top: upperRect1.bottom
//                anchors.left: parent.left
//                anchors.right: parent.right
//                anchors.bottom: parent.bottom
//                color: "#ffffff"
//                opacity: 0.4
//            }
//        }

//        Item
//        {
//            id: bottomGradientBackground
//            height: 20
//            anchors.leftMargin: 3
//            anchors.left: parent.left
//            anchors.rightMargin: 30
//            anchors.right: parent.right
//            anchors.bottomMargin: 3
//            anchors.bottom: parent.bottom

//            Rectangle
//            {
//                id: bottomRect1
//                height: parent.height * 0.5
//                anchors.top: parent.top
//                anchors.left: parent.left
//                anchors.right: parent.right
//                color: "#ffffff"
//                opacity: 0.4
//            }

//            Rectangle
//            {
//                anchors.top: bottomRect1.bottom
//                anchors.left: parent.left
//                anchors.right: parent.right
//                anchors.bottom: parent.bottom
//                color: "#ffffff"
//                opacity: 0.8
//            }
//        }
    }

    Text
    {
        id: commandsText
        color: "#000000"
        text: qsTr("Commands")
        font.pixelSize: 18

        anchors.topMargin: 40
        anchors.leftMargin: 40
        anchors.top: parent.top
        anchors.left: groupsFrame.right
    }

    Rectangle
    {
        width: commandsFrame.width
        height: 2
        anchors.topMargin: 6
        anchors.top: commandsText.bottom
        anchors.horizontalCenter: commandsFrame.horizontalCenter
        color: "#ebebeb"
    }

    Rectangle
    {
        id: commandsFrame
        width: parent.width * 0.25
        color: "transparent"
        radius: 6
        border.color: "#ebebeb"

        anchors.topMargin: 20
        anchors.top: commandsText.bottom
        anchors.left: commandsText.left
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

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

            function loadList(groupName)
            {
                currentCommandName = ""
                commandListModel.clear()
                let list = jsonConfigManager.getCommandList(groupName)
                for(var i = 0; i < list.length; i++)
                {
                    commandListModel.append({commandName : list[i]})
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
                    width: groupsList.width
                    text: commandName

                    background: Rectangle
                    {
                        color: parent.checked ? "#777777" : "#ffffff"
                    }

                    contentItem: Text
                    {
                        text: parent.text
                        color: parent.checked ? "#ffffff" : "#222222"
                    }

                    ButtonGroup.group: commandListButtonsGroup

                    onCheckedChanged:
                    {
                        if(checked)
                        {
                            commandList.currentCommandName = commandName
//                            commandChangeText.text = jsonConfigManager.getChangeSeqString(groupsList.currentGroupName, commandList.currentCommandName)
//                            commandRequestText.text = jsonConfigManager.getRequestSeqString(groupsList.currentGroupName, commandList.currentCommandName)

                            commandChangeSetupItem.setupCommand(jsonConfigManager.getChangeSeq(groupsList.currentGroupName, commandList.currentCommandName))
                            commandRequestSetupItem.setupCommand(jsonConfigManager.getRequestSeq(groupsList.currentGroupName, commandList.currentCommandName))
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

    Text
    {
        id: commandChangeTitle
        color: "#000000"
        text: qsTr("Change sequence")
        font.pixelSize: 16

        anchors.topMargin: 80
        anchors.leftMargin: 40
        anchors.top: parent.top
        anchors.left: commandsFrame.right
    }

    Item
    {
        id: commandChangeSetupItem
        height: parent.height * 0.05

        anchors.topMargin: 8
        anchors.top: commandChangeTitle.bottom
        anchors.left: commandChangeTitle.left
        anchors.rightMargin: 20
        anchors.right: parent.right

        property int cellSize: 20
        property var cellList: []

        function setupCommand(seqList)
        {
            cellList.length = 0

            changeByte0.text = seqList[0]
            cellList.push(changeByte0)

            changeByte1.text = seqList[1]
            cellList.push(changeByte1)

            changeByte2.text = "10"
            cellList.push(changeByte2)

            changeByte3.text = seqList[3]
            cellList.push(changeByte3)

            changeByte4.text = seqList[4]
            cellList.push(changeByte4)

            changeByte5.text = seqList[5]
            cellList.push(changeByte5)

            changeByte6.text = seqList[6]
            cellList.push(changeByte6)

            changeByte7.text = seqList[7]
            cellList.push(changeByte7)

            changeByte8.text = seqList[8]
            cellList.push(changeByte8)

            changeByte9.text = seqList[9]
            cellList.push(changeByte9)

            changeByte10.text = "00"
            cellList.push(changeByte10)

            changeByte11.text = "00"
            cellList.push(changeByte11)

            changeByte12.text = "00"
            cellList.push(changeByte12)

            changeByte13.text = "00"
            cellList.push(changeByte13)

            changeByte14.text = "00"
            cellList.push(changeByte14)

            changeByte15.text = "00"
            cellList.push(changeByte15)

            changeByte16.text = "00"
            cellList.push(changeByte16)

            changeByte17.text = seqList[17]
            cellList.push(changeByte17)
        }

        TextField
        {
            id: changeByte0
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.left: parent.left
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte1
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte0.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte2
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte1.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte3
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte2.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte4
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte3.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte5
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte4.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte6
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte5.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte7
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte6.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte8
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte7.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte9
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte8.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte10
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte9.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte11
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte10.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte12
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte11.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte13
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte12.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte14
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte13.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte15
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte14.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte16
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte15.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: changeByte17
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: changeByte16.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }
    }

    SbcButton
    {
        id: sendChangeCommand
        text: qsTr("Send")

        anchors.top: commandChangeSetupItem.bottom
        anchors.left: commandChangeSetupItem.left

        onClicked:
        {
            let commandString = ""
            commandChangeSetupItem.cellList.forEach(function(cell)
            {
                commandString += cell.text
                commandString += " "
            })

            portsManager.sendCommand(commandString)
        }
    }

    Text
    {
        id: commandRequestTitle
        color: "#000000"
        text: qsTr("Request sequence")
        font.pixelSize: 16

        anchors.topMargin: 20
        anchors.leftMargin: 40
        anchors.top: sendChangeCommand.bottom
        anchors.left: commandsFrame.right
    }

    Item
    {
        id: commandRequestSetupItem
        height: parent.height * 0.05

        anchors.topMargin: 8
        anchors.top: commandRequestTitle.bottom
        anchors.left: commandRequestTitle.left
        anchors.rightMargin: 20
        anchors.right: parent.right

        property int cellSize: 20
        property var cellList: []

        function setupCommand(seqList)
        {
            reqByte0.text = seqList[0]
            cellList.push(reqByte0)

            reqByte1.text = seqList[1]
            cellList.push(reqByte1)

            reqByte2.text = "30"
            cellList.push(reqByte2)

            reqByte3.text = seqList[3]
            cellList.push(reqByte3)

            reqByte4.text = seqList[4]
            cellList.push(reqByte4)

            reqByte5.text = seqList[5]
            cellList.push(reqByte5)

            reqByte6.text = seqList[6]
            cellList.push(reqByte6)

            reqByte7.text = seqList[7]
            cellList.push(reqByte7)

            reqByte8.text = seqList[8]
            cellList.push(reqByte8)

            reqByte9.text = seqList[9]
            cellList.push(reqByte9)

            reqByte10.text = "00"
            cellList.push(reqByte10)

            reqByte11.text = "00"
            cellList.push(reqByte11)

            reqByte12.text = seqList[12]
            cellList.push(reqByte12)
        }

        TextField
        {
            id: reqByte0
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.left: parent.left
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte1
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte0.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte2
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte1.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte3
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte2.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte4
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte3.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte5
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte4.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte6
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte5.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte7
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte6.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte8
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte7.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte9
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte8.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte10
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte9.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte11
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte10.right
            padding: 0

            color: "#ffffff"

            background: Rectangle
            {
                color: "green"
                radius: 2
            }
        }

        TextField
        {
            id: reqByte12
            width: parent.cellSize
            height: parent.cellSize
            anchors.top: parent.top
            anchors.leftMargin: 4
            anchors.left: reqByte11.right
            padding: 0

            color: "#ffffff"
            enabled: false

            background: Rectangle
            {
                color: "#999999"
                radius: 2
            }
        }
    }

    SbcButton
    {
        id: sendRequestCommand
        text: qsTr("Send")

        anchors.top: commandRequestSetupItem.bottom
        anchors.left: commandRequestSetupItem.left

        onClicked:
        {
            let commandString = ""
            commandRequestSetupItem.cellList.forEach(function(cell)
            {
                commandString += cell.text
                commandString += " "
            })

            portsManager.sendCommand(commandString)
        }
    }

    Text
    {
        id: responseTitle
        color: "#000000"
        text: qsTr("Response")
        font.pixelSize: 16

        anchors.topMargin: 40
        anchors.top: sendRequestCommand.bottom
        anchors.left: commandRequestTitle.left
    }

    Rectangle
    {
        id: responseFrame
        color: "transparent"
        radius: 6
        border.color: "#ebebeb"

        anchors.topMargin: 16
        anchors.top: responseTitle.bottom
        anchors.left: responseTitle.left
        anchors.rightMargin: 20
        anchors.right: parent.right
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom

        ScrollView
        {
            anchors.fill: parent

            TextArea
            {
                id: responseText

                Connections
                {
                    target: portsManager
                    function onMessageLogged(message)
                    {
                        responseText.text += "\n"
                        responseText.text += message
                    }
                }
            }
        }
    }

    SbcButton
    {
        id: clearResponseButton
        text: qsTr("Clear")

        anchors.bottomMargin: 10
        anchors.bottom: responseFrame.top
        anchors.right: responseFrame.right

        onClicked:
        {
            responseText.text = ""
        }
    }
}
