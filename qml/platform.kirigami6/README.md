Use for imports corresponding to current Qt 6 and Kirigami 6. Prefer versionless
imports and aliases for controls where useful:

```
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "."
```

This platform intentionally follows the Kirigami Qt 5 platform architecture: it
uses `Kirigami.ApplicationWindow`, `Kirigami.PageRow`, `Kirigami.Page`,
`Kirigami.ScrollablePage`, and `Kirigami.GlobalDrawer` instead of the plain
QtQuick Controls `ApplicationWindow` and `StackView` used by `qtcontrols6`.
