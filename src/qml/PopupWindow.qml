import QtQuick 2.12
import QtQuick.Controls 2.12

Item
{
    visible: false

    Rectangle
    {
        anchors.fill: parent
        color: "#ffffff"
        radius: 10
    }

    Button
    {
        id: closeButton
        width: 28
        height: 28

        anchors.topMargin: 10
        anchors.rightMargin: 10
        anchors.top: parent.top
        anchors.right: parent.right

        bottomPadding: 0
        topPadding: 0
        rightPadding: 0
        leftPadding: 0

        Image
        {
            source: "qrc:/popup_closeButton"
        }

        onClicked:
        {
            parent.visible = false
        }
    }

    onVisibleChanged:
    {
        applicationWindow.makeShadowed(visible)
    }
}
