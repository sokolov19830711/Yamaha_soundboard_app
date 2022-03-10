import QtQuick 2.12
import QtQuick.Controls 2.12

Item
{
    property string goodBackgroundColor: "#D2FFD4"
    property string goodTextColor: "#208024"
    property string wrongBackgroundColor: "#FFF4D2"
    property string wrongTextColor: "#FF9800"

    Text
    {
        id: titleText
        color: "#000000"
        text: qsTr("System Checks")
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
        text: qsTr("Checks different parts of the system to confirm proper operation")
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
            id: internetConnectionText
            text: qsTr("Internet Connection")

            anchors.topMargin: 40
            anchors.leftMargin: 30
            anchors.top: parent.top
            anchors.left: parent.left

            color: "#5850EA"
            font.pixelSize: 16
        }

        Rectangle
        {
            id: internetConnectionRect
            width: 180
            height: 30

            anchors.rightMargin: 30
            anchors.right: parent.right
            anchors.bottomMargin: 5
            anchors.bottom: internetConnectionText.verticalCenter

            color: goodBackgroundColor
            radius: 10

            Text {
                id: internetConnectionStatusText

                anchors.centerIn: parent

                text: qsTr("All Good")
                color: goodTextColor
                font.pixelSize: 16
            }
        }

        Text {
            id: lastCheckedText
            text: qsTr("Last Checked:")

            anchors.horizontalCenter: internetConnectionRect.horizontalCenter
            anchors.topMargin: 5
            anchors.top: internetConnectionText.verticalCenter

            color: "#9E9E9E"
            font.pixelSize: 14
        }

        Rectangle
        {
            id: separator1
            width: parent.width * 0.95
            height: 2
            anchors.topMargin: 20
            anchors.top: lastCheckedText.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            color: "#ebebeb"
        }

        //---------------------------------------------------------------------------------------------

        Text
        {
            id: soundboardConnectionText
            text: qsTr("Sounboard Connection")

            anchors.topMargin: 40
            anchors.leftMargin: 30
            anchors.top: separator1.bottom
            anchors.left: parent.left

            color: "#5850EA"
            font.pixelSize: 16
        }

        Rectangle
        {
            id: soundboardConnectionRect
            width: 180
            height: 30

            anchors.rightMargin: 30
            anchors.right: parent.right
            anchors.bottomMargin: 5
            anchors.bottom: soundboardConnectionText.verticalCenter

            color: goodBackgroundColor
            radius: 10

            property int lastCheckedTime: 0

            Text {
                id: soundboardConnectionStatusText

                anchors.centerIn: parent

                text: qsTr("All Good")
                color: goodTextColor
                font.pixelSize: 16
            }

            Timer
            {
                id: timer2
                interval: 60000

                onTriggered:
                {
                    soundboardConnectionRect.lastCheckedTime += 1
                    lastCheckedText2.text = qsTr("Last Checked: " + soundboardConnectionRect.lastCheckedTime + " min ago")
                }
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    soundboardConnectionRect.lastCheckedTime = 0
                    timer2.stop()
                    timer2.start()
                    connectionsChecker.checkSoundboardConnection()
                    lastCheckedText2.text = qsTr("Last Checked: Right now")
                }
            }

            Connections
            {
                target: connectionsChecker
                function onSoundboardConnectionChecked(state)
                {
                    if (state)
                    {
                        soundboardConnectionRect.color = goodBackgroundColor
                        soundboardConnectionStatusText.color = goodTextColor
                        soundboardConnectionStatusText.text = qsTr("All Good")
                    }
                    else
                    {
                        soundboardConnectionRect.color = wrongBackgroundColor
                        soundboardConnectionStatusText.color = wrongTextColor
                        soundboardConnectionStatusText.text = qsTr("Something Went Wrong")
                    }

                    lastCheckedText2.text = qsTr("Last Checked: Right now")
                    soundboardConnectionRect.lastCheckedTime = 0
                    timer2.stop()
                    timer2.start()
                }
            }

            Component.onCompleted:
            {
                timer2.start()
            }
        }

        Text {
            id: lastCheckedText2
            text: qsTr("Last Checked:")

            anchors.horizontalCenter: soundboardConnectionRect.horizontalCenter
            anchors.topMargin: 5
            anchors.top: soundboardConnectionText.verticalCenter

            color: "#9E9E9E"
            font.pixelSize: 14
        }

        Rectangle
        {
            width: parent.width * 0.95
            height: 2
            anchors.topMargin: 20
            anchors.top: lastCheckedText2.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            color: "#ebebeb"
        }
    }

}
