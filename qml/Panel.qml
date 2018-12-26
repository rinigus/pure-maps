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
    height: contentHeight >= parent.height - y ? contentHeight : parent.height - y
    y: parent.height - _offset
    z: 910

    // properties
    property int  contentHeight: 0
    property bool hasData: false
    property bool noAnimation: false

    // internal properties
    default property alias _content: itemCont.data
    property bool _hiding: false
    property int  _offset: 0

    // signals
    signal hidden
    signal swipedOut

    Behavior on _offset {
        id: movementBehavior
        enabled: !noAnimation && (!mouse.drag.active || mouse.dragDone)
        NumberAnimation {
            duration: 100
            easing.type: Easing.Linear
            onRunningChanged: {
                if (running) return;
                panel.noAnimation = !panel.hasData;
                if (panel._hiding) {
                    panel._hiding = false;
                    panel.hidden();
                }
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
        drag.minimumY: panel.parent.height - panel.height
        drag.maximumY: panel.parent.height
        drag.target: panel

        property bool dragDone: true

        Item {
            id: itemCont
            anchors.fill: parent
        }

        onPressed: {
            dragDone=false;
        }

        onReleased: {
            _offset = panel.parent.height - panel.y;
            dragDone = true;
            var t = Math.min(panel.parent.height*0.1, panel.height * 0.25);
            var d = panel.y - drag.minimumY;
            if (d > t) {
                panel._hidePanel();
                swipedOut();
            }
            else
                panel._showPanel();
        }
    }

    Connections {
        target: panel
        onContentHeightChanged: panel.hasData && panel.contentHeight > 0 && !panel._hiding && panel._showPanel()
        onHasDataChanged: {
            if (hasData) panel._showPanel();
            else if (_offset) panel._hidePanel();
        }
    }

    Connections {
        target: parent
        onHeightChanged: {
            if (panel.hasData) panel._showPanel();
            else if (_offset > 0) panel._hidePanel();
        }
    }

    function _hidePanel() {
        if (movementBehavior.enabled)
            panel._hiding = true;
        _offset = 0;
        if (!panel._hiding)
            hidden();
    }

    function _showPanel() {
        panel._hiding = false;
        _offset = panel.contentHeight;
    }
}
