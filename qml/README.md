Use for imports (as required)

```
import QtQuick 2.0
QtQuick.Layouts 1.1
import "."
import "platform"
```


When defining width of the columns on the page, don't use anchors, but 

```
width: page.width
```

Otherwise, Kirigami platform may get to trouble.

Pages (PagePL) can have only one item. If some Connections, Timers, or similar is 
added, define them under the main item. This seems to be limitation of Kirigami
`ScrollablePage`.


