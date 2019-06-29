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
    property int currentIndex: ps.depth - 1
    property var ps: null

    function completeAnimation() {
        ps.completeAnimation();
    }

    function currentPage() {
        return ps.currentPage;
    }

    function navigateForward(immediate) {
        return ps.navigateForward(immediate ? PageStackAction.Immediate : PageStackAction.Animated)
    }

    function nextPage() {
        return ps.nextPage();
    }

    function pop(page) {
        if (page) ps.pop(page);
        else ps.pop();
    }

    function popAttached() {
        ps.popAttached();
    }

    function previousPage() {
        return ps.previousPage();
    }

    function push(page, options, immediate) {
        return ps.push(page, options ? options : {}, immediate ? PageStackAction.Immediate : PageStackAction.Animated);
    }

    function pushAttached(page, options) {
        return ps.pushAttached(page, options ? options : {});
    }

    function replace(page, options) {
        return ps.replace(page, options ? options : {})
    }

    function showRoot() {
        ps.currentIndex = 0;
    }
}
