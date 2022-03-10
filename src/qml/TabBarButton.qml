import QtQuick 2.12
import QtQuick.Controls 2.12

Button
{
    text: qsTr("tabBarButton")
    width: 130
    height: 38
    layer.enabled: false
    checkable: true

    bottomPadding: 2
    topPadding: 2
    rightPadding: 2
    leftPadding: 2

    background: Rectangle {
        color: parent.checked ? "#343C4C" : "transparent"
        radius: 16
    }

    contentItem: Text {
        color: "#ffffff"
        text: parent.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.pixelSize: 16
    }

}
