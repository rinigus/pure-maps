Use for imports that are corresponding to Qt 5.9, as much as possible. When possible,
prefer to import Kirigami 2.4, as it is available at UBPorts and the code can be shared
between the platforms.

Recommended imports are

```
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "."
```

Some files import

```
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
```

If needed, import corresponding to Qt 5.11

```
import QtQuick 2.11
import QtQuick.Controls 2.4
```

