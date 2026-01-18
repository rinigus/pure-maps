import QtGraphicalEffects 1.0

DropShadow {
    color: shadowEnabled ? "transparent" : styler.shadowColor
    opacity: styler.shadowOpacity
    radius: styler.shadowRadius
    samples: 1 + radius*2

    property bool shadowEnabled: true
}
