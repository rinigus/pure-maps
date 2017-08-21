/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
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
import io.thp.pyotherside 1.2

Python {
    id: py

    property bool ready: false

    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl(".."));
        importModule("poor", function() {
            py.call("poor.main", [], function() {
                py.ready = true;
            });
        });
    }

    onError: console.log("Error: %1".arg(traceback));

    function call_sync(func, args) {
        // XXX: Work around a call_sync bug by using evaluate.
        // https://github.com/thp/pyotherside/issues/49
        // https://together.jolla.com/question/156736
        args = args.map(py.stringify).join(", ");
        return py.evaluate("%1(%2)".arg(func).arg(args));
    }

    function stringify(obj) {
        // Return Python string representation of obj.
        if (Array.isArray(obj)) {
            return "[%1]".arg(obj.map(py.stringify).join(", "));
        } else if (obj === null || obj === undefined) {
            return "None";
        } else if (typeof obj === "string") {
            return "'%1'".arg(obj.replace(/'/g, "\\'"));
        } else if (typeof obj === "number") {
            return obj.toString();
        } else if (typeof obj === "boolean") {
            return obj ? "True" : "False";
        } else if (typeof obj === "object") {
            // Assume all remaining objects are dictionaries.
            return "{%1}".arg(Object.keys(obj).map(function(x) {
                return [py.stringify(x), py.stringify(obj[x])].join(": ");
            }).join(", "));
        } else {
            throw "Unrecognized argument type: %1: %2"
                .arg(obj).arg(typeof obj);
        }
    }

}
