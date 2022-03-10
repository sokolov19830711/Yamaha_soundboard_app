import QtQuick 2.12
import QtQuick.Controls 2.12

Item
{
    onVisibleChanged:
    {
        mixList.loadList()
    }

    Text
    {
        id: titleText
        color: "#000000"
        text: qsTr("Mixes")
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
        text: qsTr("The current mixes that are in use. To change or update the parameters for a mix preset, you must go to the Mixes Presets menu.")
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
            id: mixTitleText
            width: 40
            color: "#777777"
            font.pixelSize: 14
            font.bold: true
            text: qsTr("Mix")

            anchors.topMargin: 20
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.left: parent.left
        }

        Text
        {
            id: mixNameTitleText
            width: 80
            color: "#000000"
            font.pixelSize: 14
            font.bold: true
            text: qsTr("Mix Name")

            anchors.topMargin: 20
            anchors.top: parent.top
            anchors.leftMargin: 120
            anchors.left: mixTitleText.right
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
            anchors.left: mixTitleText.right
        }

        ListView
        {
            id: mixList
            anchors.topMargin: 70
            anchors.top: parent.top
            anchors.leftMargin: 10
            anchors.left: parent.left
            anchors.rightMargin: 10
            anchors.right: parent.right
            anchors.bottomMargin: 10
            anchors.bottom: parent.bottom

            property string currentMixName: ""

            ScrollBar.vertical: ScrollBar {}

            clip: true

            function loadList()
            {
                currentMixName = ""
                mixListModel.clear()
                let list = presetManager.getMixList()
                for(var i = 0; i < list.length; i++)
                {
                    mixListModel.append({mixIndexText: list[i]["index"], mixName: list[i]["mixName"], presetInUseText: list[i]["presetInUse"]})
                }
            }

            model: ListModel
            {
                id: mixListModel
            }

            delegate: Component
            {
                id: mixListDelegate

                Item
                {
                    height: 50
                    width: mixList.width

                    Rectangle
                    {
                        id: delegateBackground
                        anchors.fill: parent
                        color: mixNameButton.checked ? "#ebebeb" : "transparent"
                    }

                    Text
                    {
                        id: mixIndex
                        width: 40
                        color: "#777777"
                        font.pixelSize: 14
                        text: mixIndexText

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 30
                        anchors.left: parent.left
                    }

                    Button
                    {
                        id: mixNameButton
                        checkable: true
                        width: mixList.width * 0.2
                        height: parent.height
                        text: mixName

//                        anchors.leftMargin: 10
//                        anchors.left: channelNo.right
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
                                mixList.currentMixName = mixName
                            }
                        }
                    }

                    Text
                    {
                        id: presetInUse
                        width: mixList.width * 0.35
                        font.pixelSize: 14
                        text: presetInUseText

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: mixList.width * 0.4
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

                        visible: mixNameButton.checked

                        onClicked:
                        {
                            applicationWindow.changeMixPresetPopup.mixName = mixName
                            applicationWindow.changeMixPresetPopup.mixIndex = parseInt(mixIndexText)
                            applicationWindow.changeMixPresetPopup.applyButtonText = "Update Mix Preset"
                            applicationWindow.changeMixPresetPopup.visible = true
                        }
                    }
                }
            }

            ButtonGroup
            {
                id: listButtonsGroup
            }

            Component.onCompleted:
            {
                mixList.loadList()
            }

            Connections
            {
                target: presetManager
                function onMixListChanged()
                {
                    mixList.loadList()
                }
            }
        }
    }
}
