Implementation for Linux distributions that are limited to Kirigami
2.4 imports and Qt 5.9. The restrictions are imposed by Debian Stable and
UBPorts at this moment (Aug 2019).

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

