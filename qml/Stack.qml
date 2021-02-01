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

QtObject {
    property bool keep: false
    property var  _current: null
    property var  _stack: []
    property var  _garbage: []

    function clear() {
        for (var i=0; i < _stack.length; i++)
            for (var j=0; j < _stack[i].length; j++) {
                if (_stack[i][j])
                    _garbage.push(_stack[i][j]);
            }
        // cleanup _garbage
        var _new_garbage = [];
        for (var i=0; i < _garbage.length; i++)
            if (_garbage[i].stack_index <= app.pages.currentIndex)
                _new_garbage.push(_garbage[i]);
            else {
                // console.log("Destroy: " + _garbage[i].page + " " + _garbage[i].stack_index + " " + app.pages.currentIndex);
                _garbage[i].page && _garbage[i].page.destroy();
            }
        _garbage = _new_garbage;

        keep = false;
        _stack = [];
    }

    function push(pagefile, options) {
        var p = app.createObject(pagefile, options ? options : {});
        if (!p) return;
        _stack.push([{"stack_index": app.pages.currentIndex + 1, "page": p}]);
        app.pages.pushMain(p);
        // console.log('Pushed: ' + p);
        return p;
    }

    function pushAttached(pagefile, options) {
        var p = app.createObject(pagefile, options ? options : {});
        if (!p) return;
        _stack[_stack.length-1].push({"stack_index": app.pages.currentIndex + 1, "page": p});
        app.pages.pushAttached(p);
        // console.log('Pushed attached: ' + p);
        return p;
    }

    function restore() {
        var found = false;
        for (var i=0; i < _stack.length; i++) {
            // console.log('Restoring: ' + _stack[i][0] + ' current ' + _current);
            if (_stack[i][0]["page"] === _current) found = true;
            app.pages.push(_stack[i][0]["page"], {}, !found && _current != null);
            // console.log('Current page found ' + found)
            for (var j=1; j < _stack[i].length; j++) {
                // console.log('Restoring attached: ' + _stack[i][j]);
                app.pages.pushAttached(_stack[i][j]["page"], {});
                if (!found) app.pages.navigateForward(true);
                if (!found && _stack[i][j]["page"] === _current) found = true;
                // console.log('Current attached or nonattached page found ' + found)
            }
        }
    }

    function setCurrent(p) {
        // console.log('set current: ' + p);
        _current = p;
    }

}
