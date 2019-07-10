/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2019 Rinigus, 2019 Purism SPC
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

Item {
    id: stack

    property var  attached
    property var  attachedTo
    property int  currentIndex: ps.currentIndex
    property var  currentItem: null
    property var  ps: null

    property bool _locked: false

    Connections {
        target: app
        onInfoActiveChanged: stack.processCurrentIndex()
    }

    Connections {
        target: ps
        onCurrentIndexChanged: stack.processCurrentIndex()
        onCurrentItemChanged: stack.processCurrentItem()
    }

    on_LockedChanged: stack.processCurrentItem()

    function completeAnimation() {
    }

    function currentPage() {
        return ps.currentItem;
    }

    function hasAttached(page) {
        return attachedTo && attached && page === attachedTo ? true : false
    }

    function navigateForward(immediate) {
        if (hasAttached(currentItem) && ps.currentItem.canNavigateForward) return push(attached);
        console.log("There is no page attached to the stack or navigation forward is not allowed, cannot navigateForward");
    }

    function nextPage() {
        return attached;
    }

    function pop(page) {
        _locked = true;
        // working around kirigami issue on pop not returning popped item
        var last;
        var last_before = ps.currentItem;
        if (page) last = ps.pop(page);
        else last = ps.pop();
        if (!last) last = last_before;
        if (attached && attached !== last && !last.isDialog) {
            attached = undefined;
            attachedTo = undefined;
        }
        _locked = false;
        return last;
    }

    function popAttached() {
        if (attached && ps.currentItem == attached) return pop();
        console.log("Cannot popAttached if the current page is not attached");
    }

    function previousPage() {
        return ps.get(currentIndex-1);
    }

    function processCurrentItem() {
        // avoid triggering current item needlessly.
        // page activating signals are connected to the
        // changes in currentItem
        if (_locked) return;
        if (currentItem !== ps.currentItem)
            currentItem = ps.currentItem
    }

    function processCurrentIndex() {
        if (ps.currentIndex === 0 && ps.depth > 1) {
            if (app.infoActive) return;
            ps.pop(ps.get(0));
            attached = undefined;
            attachedTo = undefined;
        } else if (ps.currentIndex+1 < ps.depth && (ps.get(ps.currentIndex+1)===attached ||
                                                    ps.get(ps.currentIndex+1).isDialog)) {
            // remove attached page from stack when navigaing away from it
            ps.pop(ps.get(ps.currentIndex));
        }
    }

    function push(page, options, immediate) {
        // handle file selector as a dialog opened using 'open'
        if (typeof page === 'string' && page.includes('FileSelectorPL.qml')) {
            var fs = app.createObject(page, options ? options : {});
            if (!fs) return null;
            fs.open();
            return fs;
        }

        _locked = true;
        if (ps.currentIndex !== ps.depth-1 && ps.currentIndex > 0) {
            var ci = ps.get(ps.currentIndex);
            pop(ci);
            _locked = true;
        }
        // check if we have this page already
        var pi = -1;
        for (var i=0; i < ps.depth && pi < 0; i++){
            if (ps.get(i) === page)
                pi = i;
        }
        var p = null;
        if (pi < 0) p = ps.push(page, options ? options : {});
        else {
            _locked = false;
            ps.currentIndex = pi;
            _locked = true;
        }
        if (attached !== page && (p && !p.isDialog)) {
            attached = undefined;
            attachedTo = undefined;
        }
        _locked = false;
        return p;
    }

    function pushAttached(page, options) {
        attachedTo = currentItem;
        attached = page;
        if (typeof page === 'string') {
            attached = app.createObject(page, options ? options : {});
            if (!attached) return null;
        }
        attached.visible = false;
        return attached;
    }

    function replace(page, options) {
        return ps.replace(page, options ? options : {});
    }

    function showRoot() {
        ps.currentIndex = 0;
    }
}
