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
        for (var i = 0; i < args.length; i++) {
            if (typeof args[i] === "string") {
                args[i] = args[i].replace(/'/, "\\'");
                args[i] = "'%1'".arg(args[i]);
            } else if (typeof args[i] === "number") {
                args[i] = args[i].toString();
            } else if (typeof args[i] === "boolean") {
                args[i] = args[i] ? "True" : "False";
            } else {
                throw "Unrecognized argument type: %1: %2"
                    .arg(args[i]).arg(typeof args[i]);
            }
        }
        var call = "%1(%2)".arg(func).arg(args.join(", "));
        return py.evaluate(call);
    }
}
