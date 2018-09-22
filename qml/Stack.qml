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
import Sailfish.Silica 1.0

QtObject {
    property bool keep: false
    property var  _current: null
    property var  _stack: []

    function clear() {
        for (var i=0; i < _stack.length; i++)
            for (var j=0; j < _stack[i].length; j++) {
                // console.log("Destroying: " + _stack[i][j]);
                _stack[i][j].destroy();
            }
        keep = false;
        _stack = [];
    }

    function push(pagefile, options) {
        var pc = Qt.createComponent(pagefile);
        var p = pc.createObject(app, options ? options : {})
        app.pageStack.push(p);
        _stack.push([p]);
        // console.log('Pushed: ' + p);
        return p;
    }

    function pushAttached(pagefile, options) {
        var pc = Qt.createComponent(pagefile);
        var p = pc.createObject(app, options ? options : {})
        app.pageStack.pushAttached(p);
        _stack[_stack.length-1].push(p);
        // console.log('Pushed attached: ' + p);
        return p;
    }

    function restore() {
        var found = false;
        for (var i=0; i < _stack.length; i++) {
            // console.log('Restoring: ' + _stack[i][0]);
            app.pageStack.push(_stack[i][0], {}, PageStackAction.Immediate);
            if (_stack[i][0] === _current) found = true;
            for (var j=1; j < _stack[i].length; j++) {
                // console.log('Restoring attached: ' + _stack[i][j]);
                app.pageStack.pushAttached(_stack[i][j], {});
                if (!found) app.pageStack.navigateForward(PageStackAction.Immediate);
                if (!found && _stack[i][j] === _current) found = true;
            }
        }
    }

    function setCurrent(p) {
        _current = p;
    }

}
