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

import QtQuick 2.9
import QtQuick.Controls 2.2
import Ubuntu.Content 1.3
import "."

Page {
    id: fs
 
    property string selectedFilepath
    property var nameFilters
    signal selected
    signal cancel()    
    
	property var activeTransfer
	property var url
	property var handler
	property var contentType

    header: HeaderBarImpl {
        title: app.tr("Choose")
        page: fs
    }

    ContentPeerPicker {
        anchors.fill: parent
        anchors.topMargin: fs.header.height
        visible: parent.visible
        showTitle: false
        contentType: ContentType.Documents
        handler: ContentHandler.Source

        onPeerSelected: {
            peer.selectionType = ContentTransfer.Single
            fs.activeTransfer = peer.request()
            fs.activeTransfer.stateChanged.connect(function() {
                if (fs.activeTransfer.state === ContentTransfer.InProgress) {
                    fs.activeTransfer.items = fs.activeTransfer.items[0].url = url;
                    fs.activeTransfer.state = ContentTransfer.Charged;
                }
                if (fs.activeTransfer.state === ContentTransfer.Charged) {
                    selectedFilepath = fs.activeTransfer.items[0].url;
                    selectedFilepath = selectedFilepath.replace("file://", "");
                    fs.selected();
                    app.pages.pop();
                }
            })
        }

        onCancelPressed: {
            app.pages.pop()
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: fs.activeTransfer
    }
}
