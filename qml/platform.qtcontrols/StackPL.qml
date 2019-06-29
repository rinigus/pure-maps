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

    function popAttached() {
        if (attached && ps.currentItem == attached) return pop();
        console.log("Cannot popAttached if the current page is not attached");
    }

    function previousPage() {
        return ps.get(currentIndex-1);
    }

    function push(page, options, immediate) {
        // handle file selector as a dialog opened using 'open'
        if (typeof page === 'string' && page.includes('FileSelectorPL.qml')) {
            var fs = app.createObject(page, options ? options : {});
            if (!fs) return null;
            fs.open();
            return fs;
        }

        var p = ps.push(page, options ? options : {}, immediate ? StackView.Immediate.Immediate : StackView.Animated);
        if (attached !== page && !p.isDialog) attached = undefined;
        if (attached === page) hasAttached = false;
        else hasAttached = !!attached;
        return p;
    }

    function pushAttached(page, options) {
        attached = page;
        if (typeof page === 'string') {
            attached = app.createObject(page, options ? options : {});
            if (!attached) return null;
        }
        attached.visible = false;
        hasAttached = true;
        return attached;
    }

    function replace(page, options) {
        return ps.replace(page, options ? options : {});
    }

    function showRoot() {
        ps.currentIndex = 0;
    }
}
