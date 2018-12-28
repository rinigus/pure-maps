/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

Rectangle {
    id: panel
    anchors.left: parent.left
    anchors.right: parent.right
    color: app.styler.blockBg
    height: 0
    y: mode === modes.bottom ? parent.height - _offset : -height + _offset
    z: 910

    // properties
    property int  contentHeight: 0
    property int  mode: modes.bottom
    property bool noAnimation: false

    readonly property var modes: QtObject {
        readonly property int bottom: 1
        readonly property int top: 2
    }

    // internal properties
    default property alias _content: itemCont.data
    property bool _hiding: false
    property int  _offset: 0

    // signals
    signal clicked(var mouse)
    signal hidden
    signal swipedOut

    Behavior on _offset {
        id: movementBehavior
        enabled: !noAnimation && (!mouse.drag.active || mouse.dragDone)
        NumberAnimation {
            duration: 150
            easing.type: Easing.Linear
            onRunningChanged: {
                if (running) return;
                if (panel._hiding) {
                    panel._hiding = false;
                    panel.hidden();
                }
                _updatePanel();
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        drag.axis: Drag.YAxis
        // "filterChildren" makes sometimes parts of the panel transparent to
        // drag events. probably some bug in either my implementation or qml
        // drag.filterChildren: true
        drag.minimumY: panel.mode === panel.modes.bottom ? panel.parent.height - panel.height : -panel.height
        drag.maximumY: panel.mode === panel.modes.bottom ? panel.parent.height : 0
        drag.target: panel

        property bool dragDone: true

        Item {
            id: itemCont
            anchors.fill: parent
        }

        onClicked: panel.clicked(mouse)

        onPressed: {
            dragDone=false;
        }

        onReleased: {
            if (panel.mode === panel.modes.bottom) _offset = panel.parent.height - panel.y;
            else _offset = panel.y + panel.height;
            dragDone = true;
            var t = Math.min(panel.parent.height*0.1, panel.height * 0.25);
            var d = panel.height - _offset; //panel.y - drag.minimumY;
            if (d > t) {
                panel._hidePanel();
                swipedOut();
            }
            else
                panel._showPanel(true);
        }
    }

    Connections {
        target: parent
        onHeightChanged: _updatePanel()
    }

    onContentHeightChanged: _updatePanel()

    Component.onCompleted: _updatePanel()

    function _hidePanel() {
        if (movementBehavior.enabled && _offset > 0)
            panel._hiding = true;
        if (!panel._hiding && _offset > 0)
            hidden();
        _offset = 0;
    }

    function _updatePanel() {
        if (contentHeight > 0) panel._showPanel();
        else panel._hidePanel();
    }

    function _showPanel(animate) {
        if (!contentHeight || _hiding) return;
        panel._hiding = false;
        panel.height = contentHeight;
        if (_offset > 0) noAnimation = !animate;
        _offset = panel.contentHeight;
        noAnimation = false;
    }
}
