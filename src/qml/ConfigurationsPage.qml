import QtQuick 2.12
import QtQuick.Controls 2.12

Item
{
    onVisibleChanged:
    {
        if (visible)
        {
            channelCountBox.value = presetManager.getChannelCount()
        }
    }

    Text
    {
        id: titleText
        color: "#000000"
        text: qsTr("Configurations")
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
        text: qsTr("Use caution in this area")
        font.pixelSize: 16

        anchors.topMargin: 10
        anchors.top: titleText.bottom
        anchors.left: titleText.left
    }

    Rectangle
    {
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
            id: outputPortsText
            color: "#666666"
            text: qsTr("Select the port to send to")
            font.pixelSize: 16

            anchors.topMargin: 40
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.left: parent.left
        }

        ComboBox
        {
            id: outputPortsBox
            width: 360
            currentIndex: portsManager.getCurrentOutputPortIndex();

            anchors.verticalCenter: outputPortsText.verticalCenter
            anchors.leftMargin: 70
            anchors.left: outputPortsText.right

            model: portsManager.getOutputPorts()

            onCurrentTextChanged:
            {
                if(currentText)
                    portsManager.setOutputPort(currentText)
            }
        }

        Text
        {
            id: midiChannelText
            color: "#666666"
            text: qsTr("MIDI Channel")
            font.pixelSize: 16

            anchors.topMargin: 40
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.left: outputPortsBox.right
        }

        ComboBox
        {
            id: midiChannelBox
            width: 80
            currentIndex: settings.value("midiChannel")

            anchors.verticalCenter: outputPortsText.verticalCenter
            anchors.leftMargin: 20
            anchors.left: midiChannelText.right
            font.pixelSize: 16

            model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

            onCurrentIndexChanged:
            {
                settings.setValue("midiChannel", currentIndex)
            }
        }

        Text
        {
            id: inputPortsText
            color: "#666666"
            text: qsTr("Select the port to receive from")
            font.pixelSize: 16

            anchors.topMargin: 40
            anchors.top: outputPortsText.bottom
            anchors.leftMargin: 20
            anchors.left: parent.left
        }

        ComboBox
        {
            id: inputPortsBox
            width: 360

            anchors.verticalCenter: inputPortsText.verticalCenter
            anchors.left: outputPortsBox.left

            model: portsManager.getInputPorts()

            onCurrentTextChanged:
            {
                if(currentText)
                    portsManager.setInputPort(currentText)
            }
        }

        Text
        {
            id: channelsCountText
            color: "#666666"
            text: qsTr("Channel count in use")
            font.pixelSize: 16

            anchors.topMargin: 40
            anchors.top: inputPortsText.bottom
            anchors.leftMargin: 20
            anchors.left: parent.left
        }

        SpinBox
        {
            id: channelCountBox
            anchors.verticalCenter: channelsCountText.verticalCenter
            anchors.left: outputPortsBox.left

            font.pixelSize: 18
            from: 1
            to: 128

            onValueModified:
            {
                presetManager.updateChannelCount(value)
            }
        }

        Rectangle
        {
            width: parent.width * 0.9
            height: 2
            anchors.topMargin: 40
            anchors.top: channelsCountText.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ebebeb"
        }

        //-----------------------------------------------------------------------------------------------

        Text
        {
            id: jsonFileText
            color: "#666666"
            text: qsTr("JSON Config (Template)")
            font.pixelSize: 16

            anchors.topMargin: 80
            anchors.top: channelsCountText.bottom
            anchors.leftMargin: 20
            anchors.left: parent.left
        }

        Text
        {
            id: jsonFileName
            color: "#000000"
            text: setupFileName(settings.value("lastJsonConfigFile"))
            font.pixelSize: 16

            anchors.top: jsonFileText.top
            anchors.leftMargin: 60
            anchors.left: jsonFileText.right

            property string fullFileName

            ToolTip.visible: jsonFileNameMouseArea.containsMouse
            ToolTip.text: fullFileName

            MouseArea
            {
                id: jsonFileNameMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }

            function setupFileName(fileName)
            {
                fullFileName = fileName
                jsonFileName.text = fileName.substring(fileName.lastIndexOf("/") + 1)
            }

            Connections
            {
                target: jsonConfigManager
                function onJsonConfigFileChanged(fileName)
                {
                    jsonFileName.setupFileName(fileName)
                }
            }
        }

        SbcButton
        {
            id: uploadJsonButton
            text: qsTr("Upload")

            anchors.leftMargin: 40
            anchors.left: jsonFileName.right
            anchors.verticalCenter: jsonFileText.verticalCenter

            onClicked:
            {
                jsonConfigManager.selectJsonConfigFileDialog()
            }
        }

        SbcButton
        {
            id: viewCommndsButton
            text: qsTr("View Commands")

            anchors.leftMargin: 20
            anchors.left: uploadJsonButton.right
            anchors.verticalCenter: jsonFileText.verticalCenter

            onClicked:
            {
                applicationWindow.commandListPopup.visible = true
            }
        }

        //-----------------------------------------------------------------------------------------------

        Text
        {
            id: projectFileText
            color: "#666666"
            text: qsTr("Project file")
            font.pixelSize: 16

            anchors.topMargin: 40
            anchors.top: jsonFileText.bottom
            anchors.leftMargin: 20
            anchors.left: parent.left
        }

        Text
        {
            id: projectFileName
            color: "#000000"
            text: setupFileName(settings.value("lastProjectFile"))
            font.pixelSize: 16

            anchors.top: projectFileText.top
            anchors.left: jsonFileName.left

            property string fullFileName: "full name of project file"

            ToolTip.visible: projectFileNameMouseArea.containsMouse
            ToolTip.text: fullFileName

            MouseArea
            {
                id: projectFileNameMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }

            function setupFileName(fileName)
            {
                fullFileName = fileName
                projectFileName.text = fileName.substring(fileName.lastIndexOf("/") + 1)
            }

            Connections
            {
                target: presetManager
                function onProjectLoaded(fileName)
                {
                    projectFileName.setupFileName(fileName)
                }
            }

            Component.onCompleted:
            {
                projectFileName.setupFileName(presetManager.projectFileName())
            }
        }

        SbcButton
        {
            id: uploadProjectButton
            text: qsTr("Upload")

            anchors.leftMargin: 40
            anchors.left: projectFileName.right
            anchors.verticalCenter: projectFileText.verticalCenter

            onClicked:
            {
                presetManager.loadFileDialog()
            }
        }

        SbcButton
        {
            id: createProjectButton
            text: qsTr("Create")

            anchors.leftMargin: 20
            anchors.left: uploadProjectButton.right
            anchors.verticalCenter: projectFileText.verticalCenter

            onClicked:
            {
                applicationWindow.projectNamePopup.visible = true
            }
        }
    }

    Connections
    {
        target: presetManager
        function onProjectLoaded()
        {
            channelCountBox.value = presetManager.getChannelCount()
        }
    }
}
