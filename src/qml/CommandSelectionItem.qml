import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/"

Item
{
    signal commandClicked(string groupName, string commandName)

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
        width: parent.width * 0.3
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
        width: parent.width * 0.3
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
                            commandClicked(groupsList.currentGroupName, commandName)
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
}
