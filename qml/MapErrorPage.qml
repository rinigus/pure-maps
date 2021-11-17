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
        spacing: styler.themePaddingLarge

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
            visible: app.conf.profile === "offline"
            text: app.tr("You are using an offline profile. Make sure that you have OSM Scout Server installed " +
                         "and running. Depending on your system, it is available either in application stores " +
                         "(OpenRepos for Sailfish OS, OpenStore for Ubuntu Touch), Flathub, or your distribution. " +
                         'See <a href="https://rinigus.github.io/osmscout-server">OSM Scout Server manual</a> for ' +
                         "details.")
            textFormat: Text.StyledText
            truncMode: truncModes.none
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            text: app.tr("Last error:\n%1").arg(lastError)
            truncMode: truncModes.none
            wrapMode: Text.WordWrap
        }

        IconListItem {
            icon: styler.iconMaps
            label: app.tr("Maps")
            onClicked: app.pushMain(Qt.resolvedUrl("BasemapPage.qml"))
        }

        IconListItem {
            icon: styler.iconPreferences
            label: app.tr("Preferences")
            onClicked: app.push(Qt.resolvedUrl("PreferencesPage.qml"))
        }

        // We use icon+combobox only here, hence no separate class
        ListItemPL {
            id: item
            anchors.left: parent.left
            anchors.right: parent.right
            contentHeight: Math.max(styler.themeItemSizeSmall, profileComboBox.height)

            IconPL {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: styler.themeHorizontalPageMargin
                anchors.verticalCenter: label.verticalCenter
                fillMode: Image.PreserveAspectFit
                height: styler.themeItemSizeSmall*0.8
                iconName: styler.iconProfile
            }

            LabelPL {
                id: label
                anchors.left: icon.right
                anchors.leftMargin: styler.themePaddingMedium
                color: {
                    if (!item.enabled) return styler.themeSecondaryHighlightColor;
                    if (item.highlighted) return styler.themeHighlightColor;
                    return styler.themePrimaryColor;
                }
                height: styler.themeItemSizeSmall
                text: app.tr("Profile")
                truncMode: truncModes.fade
                verticalAlignment: Text.AlignVCenter
            }

            ComboBoxPL {
                id: profileComboBox
                anchors.left: label.right
                anchors.leftMargin: styler.themePaddingMedium
                anchors.right: parent.right
                anchors.topMargin: styler.isSilica ? parent.top : undefined
                anchors.verticalCenter: styler.isSilica ? undefined : label.verticalCenter
                model: [ app.tr("Online"), app.tr("Offline"),
                    hereAvailable ? app.tr("HERE - Online") : app.tr("HERE (disabled)"),
                    app.tr("Mixed") ]
                property var values: ["online", "offline", "HERE", "mixed"]
                property bool hereAvailable: py.evaluate("poor.key.has_here")
                Component.onCompleted: {
                    var value = app.conf.profile;
                    profileComboBox.currentIndex = profileComboBox.values.indexOf(value);
                }
                onCurrentIndexChanged: {
                    var index = profileComboBox.currentIndex;
                    var val = profileComboBox.values[index];
                    if (val === "HERE" && !hereAvailable) return;
                    py.call_sync("poor.app.set_profile", [val]);
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
    Component.onDestruction: app.errorPageOpen = false;

}
