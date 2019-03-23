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
import QtPositioning 5.3
import "."
import "platform"

MenuDrawerPL {
    id: page

    banner: "icons/banner.jpg"
    title: "Pure Maps"
    titleIcon: "pure-maps"
    pageMenu: PageMenuPL {
        PageMenuItemPL {
            iconName: app.styler.iconAbout
            text: app.tr("About")
            onClicked: app.push(Qt.resolvedUrl("AboutPage.qml"), {}, true)
        }
    }

    // To make TextSwitch text line up with IconListItem's text label.
    property real switchLeftMargin: app.styler.themeHorizontalPageMargin + app.styler.themePaddingLarge + app.styler.themePaddingSmall

    MenuDrawerItemPL {
        iconName: app.styler.iconStop
        text: app.tr("Stop following the movement")
        visible: app.mode === modes.followMe
        onClicked: {
            if (app.mode !== modes.followMe) return;
            app.setModeExplore();
            app.showMap();
        }
    }

    MenuDrawerItemPL {
        iconName: app.styler.iconSearch
        text: app.tr("Search")
        onClicked: app.pushMain(Qt.resolvedUrl("GeocodePage.qml"))
    }

    MenuDrawerItemPL {
        iconName: app.styler.iconNavigate
        text: app.tr("Navigation")
        onClicked: app.pushMain(Qt.resolvedUrl("RoutePage.qml"))
    }

    MenuDrawerItemPL {
        iconName: app.styler.iconNearby
        text: app.tr("Nearby venues")
        onClicked: app.pushMain(Qt.resolvedUrl("NearbyPage.qml"))
    }

    MenuDrawerItemPL {
        iconName: app.styler.iconFavorite
        text: app.tr("Bookmarks")
        onClicked: app.pushMain(Qt.resolvedUrl("PoiPage.qml"))
    }

    MenuDrawerItemPL {
        enabled: gps.ready
        iconName: app.styler.iconShare
        text: gps.ready ? app.tr("Share current position") : app.tr("Share current position (not ready)")
        onClicked: {
            if (!gps.ready) return;
            var y = gps.position.coordinate.latitude;
            var x = gps.position.coordinate.longitude;
            app.push(Qt.resolvedUrl("SharePage.qml"), {
                         "coordinate": QtPositioning.coordinate(y, x),
                         "title": app.tr("Share Current Position"),
                     }, true);
        }
    }

    MenuDrawerItemPL {
        iconName: app.styler.iconDot
        text: app.tr("Center on current position")
        onClicked: {
            app.map.centerOnPosition();
            app.showMap();
        }
    }

    MenuDrawerItemPL {
        iconName: app.styler.iconMaps
        text: app.tr("Maps")
        onClicked: app.pushMain(Qt.resolvedUrl("BasemapPage.qml"))
    }

    MenuDrawerItemPL {
        iconName: app.styler.iconPreferences
        text: app.tr("Preferences")
        onClicked: app.push(Qt.resolvedUrl("PreferencesPage.qml"), {}, true)
    }

    MenuDrawerSubmenuPL {
        id: profiles
        iconName: {
            if (app.conf.profile === "online") return app.styler.iconProfileOnline;
            if (app.conf.profile === "offline") return app.styler.iconProfileOffline;
            return app.styler.iconProfileMixed;
        }
        text: app.tr("Profile")

        MenuDrawerSubmenuItemPL {
            checked: app.conf.profile === "online"
            text: app.tr("Online")
            onClicked: profiles.set("online")
        }

        MenuDrawerSubmenuItemPL {
            checked: app.conf.profile === "offline"
            text: app.tr("Offline")
            onClicked: profiles.set("offline")
        }

        MenuDrawerSubmenuItemPL {
            checked: app.conf.profile === "mixed"
            text: app.tr("Mixed")
            onClicked: profiles.set("mixed")
        }

        function set(p) {
            py.call_sync("poor.app.set_profile", [p]);
        }
    }

    TextSwitchPL {
        id: autoCenterItem
        checked: app.map.autoCenter
        height: app.styler.themeItemSizeSmall
        leftMargin: page.switchLeftMargin
        text: app.tr("Auto-center on position")
        Connections {
            target: map
            onAutoCenterChanged: {
                if (autoCenterItem.checked !== app.map.autoCenter) {
                    autoCenterItem.checked = app.map.autoCenter;
                    if (!app.map.autoCenter && app.map.autoZoom) {
                        app.map.autoZoom = false;
                        autoZoomItem.checked = false;
                    }
                }
            }
        }
        onCheckedChanged: {
            app.map.autoCenter = autoCenterItem.checked;
            app.map.autoCenter && app.map.centerOnPosition();
        }
    }

    TextSwitchPL {
        id: autoRotateItem
        checked: app.map.autoRotate
        height: app.styler.themeItemSizeSmall
        leftMargin: page.switchLeftMargin
        text: app.tr("Auto-rotate on direction")
        Connections {
            target: map
            onAutoRotateChanged: {
                if (autoRotateItem.checked !== app.map.autoRotate)
                    autoRotateItem.checked = app.map.autoRotate;
            }
        }
        onCheckedChanged: {
            app.map.autoRotate = autoRotateItem.checked;
        }
    }

    TextSwitchPL {
        id: autoZoomItem
        checked: app.map.autoZoom
        enabled: app.map.autoCenter
        height: app.styler.themeItemSizeSmall
        leftMargin: page.switchLeftMargin
        text: app.tr("Auto-zoom map")
        Connections {
            target: map
            onAutoZoomChanged: {
                if (autoZoomItem.checked !== app.map.autoZoom)
                    autoZoomItem.checked = app.map.autoZoom;
            }
        }
        onCheckedChanged: {
            app.map.autoZoom = autoZoomItem.checked;
        }
    }
}
