import QtQuick 2.12
import QtQuick.Controls 2.12

Button
{
    id: button
    height: 32

    property string color: "#ffffff"
    property string pressedColor: "#aaaaaa"
    property string textColor: "#000000"
    property int textSize: 14

    background: Rectangle
    {
        color:
        {
            if(button.checkable)
            {
                if(parent.enabled)
                    parent.checked ? button.color : "#aaaaaa"
                else
                    "#888888"
            }

            else
            {
                if(parent.enabled)
                    parent.pressed ? button.pressedColor : button.color
                else
                    "#aaaaaa"
            }
        }
        radius: 4

        border.color: "#bbbbbb"
    }

    contentItem: Text
    {
        color:
        {
            if(button.checkable)
            {
                if(parent.enabled)
                    parent.checked ? "#222222" : "#777777"
                else
                    "#444444"
            }

            else
                parent.enabled ? button.textColor : "#777777"
        }

        text: parent.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.family: "Roboto"
        font.pixelSize: button.textSize
    }
}
