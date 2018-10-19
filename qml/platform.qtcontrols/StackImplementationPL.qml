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

import QtQuick 2.9
import QtQuick.Controls 2.2

// This file has to be symlinked from main QML path
// as StackPL.qml -> platform/StackImplamentationPL.qml
//
// This will allow to use the same path for object creation
// as from the calling functions. When moved to platform,
// such pages, as MenuPage will be not resolved since they
// will be looked from platform subfolder.

QtObject {
    property var  attached
    property bool hasAttached: false
    property int  currentIndex: ps.depth-1
    property var  ps: null

    function completeAnimation() {
    }

    function currentPage() {
        return ps.currentItem;
    }

    function navigateForward(immediate) {
        if (attached && (!ps.currentItem || ps.currentItem.canNavigateForward)) return push(attached);
        console.log("There is no page attached to the stack or navigation forward is not allowed, cannot navigateForward");
    }

    function nextPage() {
        return attached;
    }

    function pop(page) {
        var last;
        if (page) last = ps.pop(page);
        else last = ps.pop();
        if (attached && attached !== last && !last.isDialog)
            attached = undefined;
        hasAttached = !!attached;
        return last;
    }

    function previousPage() {
        return ps.get(currentIndex-1);
    }

    function push(page, options, immediate) {
        var p = ps.push(page, options ? options : {}, immediate ? StackView.Immediate.Immediate : StackView.Animated);
        if (attached !== page && !p.isDialog) attached = undefined;
        if (attached === page) hasAttached = false;
        else hasAttached = !!attached;
        return p;
    }

    function pushAttached(page, options) {
        attached = page;
        if (typeof page === 'string') {
            var pc = Qt.createComponent(page);
            if (pc.status === Component.Error) {
                console.log('Error while creating component');
                console.log(pc.errorString());
                return null;
            }
            attached = pc.createObject(app, options ? options : {})
        }
        attached.visible = false;
        hasAttached = true;
        return attached;
    }

    function replace(page, options) {
        return ps.replace(page, options ? options : {});
    }
}
