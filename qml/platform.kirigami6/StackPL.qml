/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2026 Rinigus
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

import QtQuick

Item {
    id: stack

    property var attached
    property var attachedTo
    property int currentIndex: ps.currentIndex
    property var currentItem: null
    property var ps: null

    property bool _locked: false

    Connections {
        target: app

        function onInfoActiveChanged() {
            stack.processCurrentIndex();
        }
    }

    Connections {
        target: ps

        function onCurrentIndexChanged() {
            stack.processCurrentIndex();
        }

        function onCurrentItemChanged() {
            stack.processCurrentItem();
        }
    }

    on_LockedChanged: stack.processCurrentItem()

    function completeAnimation() {
    }

    function currentPage() {
        return ps.currentItem;
    }

    function hasAttached(page) {
        return Boolean(attachedTo && attached && page === attachedTo);
    }

    function navigateForward(immediate) {
        if (hasAttached(currentItem) && ps.currentItem.canNavigateForward) return push(attached);
        console.log("There is no page attached to the stack or navigation forward is not allowed, cannot navigateForward");
        return null;
    }

    function nextPage() {
        return attached;
    }

    function pop(page) {
        _locked = true;
        const lastBefore = ps.currentItem;
        let last = page ? ps.pop(page) : ps.pop();
        if (!last) last = lastBefore;
        if (attached && attached !== last && !last.isDialog) {
            attached = undefined;
            attachedTo = undefined;
        }
        _locked = false;
        return last;
    }

    function popAttached() {
        if (attached && ps.currentItem === attached) return pop();
        console.log("Cannot popAttached if the current page is not attached");
        return null;
    }

    function previousPage() {
        return ps.get(currentIndex - 1);
    }

    function processCurrentIndex() {
        if (ps.currentIndex === 0 && ps.depth > 1) {
            if (app.infoActive) return;
            ps.pop(ps.get(0));
            attached = undefined;
            attachedTo = undefined;
        } else if (ps.currentIndex + 1 < ps.depth && (ps.get(ps.currentIndex + 1) === attached
                                                       || ps.get(ps.currentIndex + 1).isDialog)) {
            // Remove attached page from stack when navigating away from it.
            ps.pop(ps.get(ps.currentIndex));
        }
    }

    function processCurrentItem() {
        // Page activation signals are connected to currentItem changes.
        if (_locked) return;
        if (currentItem !== ps.currentItem) currentItem = ps.currentItem;
    }

    function push(page, options, immediate) {
        const pageUrl = page.toString ? page.toString() : page;
        if (typeof pageUrl === "string" && pageUrl.includes("FileSelectorPL.qml")) {
            const fs = app.createObject(page, options ?? {});
            if (!fs) return null;
            fs.open();
            return fs;
        }

        _locked = true;
        if (ps.currentIndex !== ps.depth - 1 && ps.currentIndex > 0) {
            const current = ps.get(ps.currentIndex);
            pop(current);
            _locked = true;
        }

        let pageIndex = -1;
        for (let i = 0; i < ps.depth && pageIndex < 0; i++) {
            if (ps.get(i) === page) pageIndex = i;
        }

        let pushed = null;
        if (pageIndex < 0) {
            pushed = ps.push(page, options ?? {});
        } else {
            _locked = false;
            ps.currentIndex = pageIndex;
            _locked = true;
        }

        if (attached !== page && pushed && !pushed.isDialog) {
            attached = undefined;
            attachedTo = undefined;
        }
        _locked = false;
        return pushed;
    }

    function pushAttached(page, options) {
        attachedTo = currentItem;
        attached = page;
        if (typeof page === "string") {
            attached = app.createObject(page, options ?? {});
            if (!attached) return null;
        }
        attached.visible = false;
        return attached;
    }

    function pushMain(page, options) {
        ps.currentIndex = 0;
        return push(page, options);
    }

    function replace(page, options) {
        return ps.replace(page, options ?? {});
    }

    function showRoot() {
        ps.currentIndex = 0;
    }
}
