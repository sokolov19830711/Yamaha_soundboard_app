import QtQuick 2.12
import QtQuick.Controls 2.12

Item
{
    Text
    {
        id: titleText
        color: "#000000"
        text: qsTr("Mix Presets")
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
        text: qsTr("Be careful, these are the presets for each mix. If you don't know what you are doing... go away.  :-)")
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

        ListView
        {
            id: presetList
            anchors.topMargin: 10
            anchors.top: parent.top
            anchors.leftMargin: 10
            anchors.left: parent.left
            anchors.rightMargin: 10
            anchors.right: parent.right
            anchors.bottomMargin: 10
            anchors.bottom: parent.bottom

            property string currentPresetName: ""

            ScrollBar.vertical: ScrollBar {}

            clip: true

            function loadList()
            {
                currentPresetName = ""
                presetListModel.clear()
                let mixList = presetManager.getMixPresets()
                for(var i = 0; i < mixList.length; i++)
                {
                    presetListModel.append({positionText: i + 1, presetName: mixList[i]["presetName"], descriptionText: mixList[i]["description"]})
                }
            }

            model: ListModel
            {
                id: presetListModel
            }

            delegate: Component
            {
                id: presetListDelegate

                Item
                {
                    height: 50
                    width: presetList.width

                    Rectangle
                    {
                        id: delegateBackground
                        anchors.fill: parent
                        color: presetNameButton.checked ? "#ebebeb" : "transparent"
                    }

                    Text
                    {
                        id: pos
                        width: 40
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
                        text: presetName

                        anchors.leftMargin: 10
                        anchors.left: pos.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: viewPresetButton.left

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
                                presetList.currentPresetName = presetName
                            }
                        }
                    }

                    Text
                    {
                        id: desc
                        width: 120
                        color: "#777777"
                        font.pixelSize: 14
                        font.italic: true
                        text: descriptionText

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 300
                        anchors.left: parent.left
                    }

                    SbcButton
                    {
                        id: viewPresetButton
                        text: qsTr("View")
                        width: 60

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        anchors.right: editPresetButton.left

                        visible: presetNameButton.checked

                        onClicked:
                        {
                            applicationWindow.viewMixCommandListPopup.currentPresetName = presetName
                            applicationWindow.viewMixCommandListPopup.visible = true
                        }
                    }

                    SbcButton
                    {
                        id: editPresetButton
                        text: qsTr("Edit")
                        width: 60

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        anchors.right: savePresetButton.left

                        visible: presetNameButton.checked

                        onClicked:
                        {
                            applicationWindow.loadMixPresetPopup.currentPresetName = presetName
                            applicationWindow.loadMixPresetPopup.currentPresetDesc = descriptionText
                            applicationWindow.loadMixPresetPopup.editMode = true
                            applicationWindow.loadMixPresetPopup.visible = true
                        }
                    }

                    SbcButton
                    {
                        id: savePresetButton
                        text: qsTr("Use")
                        width: 60
                        color: "#5850EA"
                        textColor: "#ffffff"

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 20
                        anchors.right: parent.right

                        visible: presetNameButton.checked

                        onClicked:
                        {
                            applicationWindow.mixPresetUsePopup.presetName = presetName
                            applicationWindow.mixPresetUsePopup.visible = true
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
                presetList.loadList()
            }

            Connections
            {
                target: presetManager
                function onProjectLoaded(projectFileName)
                {
                    presetList.loadList()
                }
            }

            Connections
            {
                target: presetManager
                function onMixPresetListChanged()
                {
                    presetList.loadList()
                }
            }
        }
    }

    SbcButton
    {
        id: createNewPresetButton
        text: qsTr("Load New Mix Preset")

        anchors.right: underline.right
        anchors.bottomMargin: 10
        anchors.bottom: underline.top

        onClicked:
        {
            applicationWindow.loadMixPresetPopup.currentPresetName = ""
            applicationWindow.loadMixPresetPopup.currentPresetDesc = ""
            applicationWindow.loadMixPresetPopup.visible = true
        }
    }

}
