import QtGraphicalEffects 1.0

DropShadow {
    color: shadowEnabled ? "transparent" : styler.shadowColor
    opacity: 0.35
    radius: 10
    samples: 1 + radius*2

    property bool shadowEnabled: true
}
