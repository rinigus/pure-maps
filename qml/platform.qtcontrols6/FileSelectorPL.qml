/*
 * Copyright (C) 2016-2019 Rinigus https://github.com/rinigus
 *                    2019 Purism SPC
 *
 * This file is part of Pure Maps.
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
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Dialogs 1.2

FileDialog {
    id: fs

    property string selectedFilepath
    signal selected

    onAccepted: {
        var path = fileUrl.toString();
        // remove prefixed "file://"
        path = path.replace(/^(file:\/{2})/,"");
        // unescape html codes like '%23' for '#'
        selectedFilepath = decodeURIComponent(path);
        selected();
    }
}
