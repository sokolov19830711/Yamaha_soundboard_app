import QtQuick 2.12
import QtQuick.Controls 2.12

Item
{
    onVisibleChanged:
    {
        channelsList.loadList()
    }

    Text
    {
        id: titleText
        color: "#000000"
        text: qsTr("Channels")
        font.pixelSize: 20

        anchors.topMargin: parent.height * 0.1
        anchors.leftMargin: parent.width * 0.1
        anchors.top: parent.top
        anchors.left: parent.left
    }

    Text
    {
        id: descText
        color: "#666666"
        text: qsTr("The current channels that are in use. To change or update the parameters for a channel preset, you must go to the Channel Presets menu.")
        font.pixelSize: 16

        anchors.topMargin: 10
        anchors.top: titleText.bottom
        anchors.left: titleText.left
    }

    Rectangle
    {
        id: underline
        width: parent.width * 0.8
        height: 2
        anchors.topMargin: 10
        anchors.top: descText.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        color: "#ebebeb"
    }

    Rectangle
    {
        width: parent.width * 0.8
        height: parent.height * 0.7
        anchors.topMargin: 30
        anchors.top: descText.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        color: "#ffffff"
        border.color: "#ebebeb"
        radius: 10

        Text
        {
            id: channelTitleText
            width: 40
            color: "#777777"
            font.pixelSize: 14
            font.bold: true
            text: qsTr("Channel")

            anchors.topMargin: 20
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.left: parent.left
        }

        Text
        {
            id: channelNameTitleText
            width: 80
            color: "#000000"
            font.pixelSize: 14
            font.bold: true
            text: qsTr("Channel Name")

            anchors.topMargin: 20
            anchors.top: parent.top
            anchors.leftMargin: 120
            anchors.left: channelTitleText.right
        }

        Text
        {
            id: presetNameTitleText
            width: 80
            color: "#000000"
            font.pixelSize: 14
            font.bold: true
            text: qsTr("Preset In Use")

            anchors.topMargin: 20
            anchors.top: parent.top
            anchors.leftMargin: 370
            anchors.left: channelTitleText.right
        }

        SbcButton
        {
            id: addChannelButton
            text: qsTr("Add")
            width: 60
            color: "#43A047"
            textColor: "#ffffff"

            visible: false

            anchors.topMargin: 20
            anchors.top: parent.top
            anchors.rightMargin: 20
            anchors.right: parent.right

            onClicked:
            {
                applicationWindow.changeChannelPresetPopup.channelName = ""
                applicationWindow.changeChannelPresetPopup.channelNo = presetManager.getFreeChannel()
                applicationWindow.changeChannelPresetPopup.applyButtonText = "Add Channel"
                applicationWindow.changeChannelPresetPopup.visible = true
            }
        }

        ListView
        {
            id: channelsList
            anchors.topMargin: 70
            anchors.top: parent.top
            anchors.leftMargin: 10
            anchors.left: parent.left
            anchors.rightMargin: 10
            anchors.right: parent.right
            anchors.bottomMargin: 10
            anchors.bottom: parent.bottom

            property string currentChannelName: ""

            ScrollBar.vertical: ScrollBar {}

            clip: true

            function loadList()
            {
                currentChannelName = ""
                channelsListModel.clear()
                let list = presetManager.getChannelList()
                for(var i = 0; i < list.length; i++)
                {
                    channelsListModel.append({channelNoText: list[i]["channel"] + 1, channelName: list[i]["channelName"], presetInUseText: list[i]["presetInUse"]})
                }
            }

            model: ListModel
            {
                id: channelsListModel
            }

            delegate: Component
            {
                id: channelsListDelegate

                Item
                {
                    height: 50
                    width: channelsList.width

                    Rectangle
                    {
                        id: delegateBackground
                        anchors.fill: parent
                        color: channelNameButton.checked ? "#ebebeb" : "transparent"
                    }

                    Text
                    {
                        id: channelNo
                        width: 40
                        color: "#777777"
                        font.pixelSize: 14
                        text: channelNoText

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 30
                        anchors.left: parent.left
                    }

                    Button
                    {
                        id: channelNameButton
                        checkable: true
                        width: channelsList.width * 0.2
                        height: parent.height
                        text: channelName

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: changePresetButton.left

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
                            anchors.leftMargin: 170
                            anchors.left: parent.left
                        }

                        ButtonGroup.group: listButtonsGroup

                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                channelsList.currentChannelName = channelName
                            }
                        }
                    }

                    Text
                    {
                        id: presetInUse
                        width: channelsList.width * 0.35
                        font.pixelSize: 14
                        text: presetInUseText

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: channelsList.width * 0.4
                        anchors.left: parent.left
                    }


                    SbcButton
                    {
                        id: changePresetButton
                        text: qsTr("Change Preset")
                        width: 160
                        color: "#5850EA"
                        textColor: "#ffffff"

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 20
                        anchors.right: parent.right

                        visible: channelNameButton.checked

                        onClicked:
                        {
                            applicationWindow.changeChannelPresetPopup.channelName = channelName
//                            applicationWindow.changeChannelPresetPopup.channelNo = parseInt(channelNoText)
                            applicationWindow.changeChannelPresetPopup.applyButtonText = "Use this Channel Preset"
                            applicationWindow.changeChannelPresetPopup.visible = true
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
                channelsList.loadList()
            }

            Connections
            {
//                target: presetManager
//                function onProjectLoaded(projectFileName)
//                {
//                    presetList.loadList()
//                }
            }

            Connections
            {
                target: presetManager
                function onChannelListChanged()
                {
                    channelsList.loadList()
                }
            }
        }
    }
}
