/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2019 Rinigus, 2019 Purism SPC
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
import "."
import "platform"

PagePL {
    id: page
    title: app.tr("Error")

    property string lastError

    Column {
        width: page.width
        spacing: app.styler.themePaddingLarge

        ListItemLabel {
            text: app.tr("Error occurred while loading current map.")
            truncMode: truncModes.none
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            text: app.tr("Depending on the used map provider, error could be caused " +
                         "by network failure, expired API access key, absence of " +
                         "offline server. Try to address the issue and/or change your" +
                         " map provider, preferences, or profile.\n" +
                         "If you change API access key, you may have to restart Pure Maps.")
            truncMode: truncModes.none
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            text: app.tr("Last error:\n%1").arg(lastError)
            truncMode: truncModes.none
            wrapMode: Text.WordWrap
        }

        IconListItem {
            icon: app.styler.iconMaps
            label: app.tr("Maps")
            onClicked: app.pushMain(Qt.resolvedUrl("BasemapPage.qml"))
        }

        IconListItem {
            icon: app.styler.iconPreferences
            label: app.tr("Preferences")
            onClicked: app.push(Qt.resolvedUrl("PreferencesPage.qml"))
        }

        // We use icon+combobox only here, hence no separate class
        ListItemPL {
            id: item
            anchors.left: parent.left
            anchors.right: parent.right
            contentHeight: Math.max(app.styler.themeItemSizeSmall, profileComboBox.height)

            Image {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: app.styler.themeHorizontalPageMargin
                anchors.verticalCenter: label.verticalCenter
                fillMode: Image.PreserveAspectFit
                height: app.styler.themeItemSizeSmall*0.8
                source: app.styler.iconProfile
            }

            LabelPL {
                id: label
                anchors.left: icon.right
                anchors.leftMargin: app.styler.themePaddingMedium
                color: {
                    if (!item.enabled) return app.styler.themeSecondaryHighlightColor;
                    if (item.highlighted) return app.styler.themeHighlightColor;
                    return app.styler.themePrimaryColor;
                }
                height: app.styler.themeItemSizeSmall
                text: app.tr("Profile")
                truncMode: truncModes.fade
                verticalAlignment: Text.AlignVCenter
            }

            ComboBoxPL {
                id: profileComboBox
                anchors.left: label.right
                anchors.leftMargin: app.styler.themePaddingMedium
                anchors.right: parent.right
                anchors.topMargin: app.styler.isSilica ? parent.top : undefined
                anchors.verticalCenter: app.styler.isSilica ? undefined : label.verticalCenter
                model: [ app.tr("Online"), app.tr("Offline"), app.tr("Mixed") ]
                property var values: ["online", "offline", "mixed"]
                Component.onCompleted: {
                    var value = app.conf.profile;
                    profileComboBox.currentIndex = profileComboBox.values.indexOf(value);
                }
                onCurrentIndexChanged: {
                    var index = profileComboBox.currentIndex;
                    py.call_sync("poor.app.set_profile", [profileComboBox.values[index]]);
                }
            }

            onClicked: profileComboBox.activate()
        }

        Connections {
            target: map
            onErrorStringChanged: lastError = map.errorString;
        }
    }

    Component.onCompleted: app.errorPageOpen = true;
    Component.onDestruction: {
        console.log("Closing error page");
        app.errorPageOpen = false;
    }

}
