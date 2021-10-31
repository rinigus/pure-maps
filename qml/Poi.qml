/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa, 2018-2019 Rinigus, 2019 Purism SPC
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
import QtPositioning 5.4

import "js/util.js" as Util

///////////////////////////////////////////////////
// Keep, load, and store POIs and allow interaction
// with them

Item {
    id: holder

    property var    pois: []

    // internal properties
    property var    _poisKeep: QtObject {
        // keeps a list of current temporary POIs that are kept on a map
        property string stateId
        property var    poiIds: []
    }

    signal poiChanged(string poiId)

    Connections {
        target: app
        onStateIdChanged: holder.clear(true)
    }

    Connections {
        target: infoPanel
        onPoiHidden: holder.clear(true, poiId)
    }

    Component.onCompleted: load()

    function _add(poi, stateId) {
        // Add new POI
        if (has(poi)) return false; // avoid duplicates
        var p = {
            "address": poi.address || "",
            "bookmarked": poi.bookmarked || false,
            "coordinate": poi.coordinate || QtPositioning.coordinate(poi.y, poi.x),
            "email": poi.email || "",
            "link": poi.link || "",
            "phone": poi.phone || "",
            "poiId": poi.poiId || Util.uuidv4(),
            "poiType": poi.poiType || "",
            "postcode": poi.postcode || "",
            "provider": poi.provider || "",
            "shortlisted": poi.shortlisted || false,
            "text": poi.text || "",
            "title": poi.title || "",
            "type": poi.type || "",
        };
        holder.pois.push(p);
        if (stateId) {
            if (stateId !== holder._poisKeep.stateId)
                holder._poisKeep.poiIds = [];
            holder._poisKeep.stateId = stateId;
            holder._poisKeep.poiIds.push(p["poiId"]);
        }
        return p;
    }

    function add(poi, stateId) {
        // Add a new POI and return if it was
        // added successfully
        var r=_add(poi, stateId);
        if (r) {
            save();
            poiChanged(r.poiId);
        }
        return r;
    }

    function addList(pois, stateId) {
        // Add new POIs
        pois.forEach(function (p) {
            _add(p, stateId);
        });
        save();
        poiChanged("");
    }

    function bookmark(poiId, bookmark) {
        if (poiId == null) return;
        var changed = [];
        holder.pois = holder.pois.map(function(p) {
            if (p.poiId != poiId) return p;
            p.bookmarked = bookmark;
            if (!bookmark) p.shortlisted = false;
            changed.push(p.poiId);
            return p;
        } );
        save();
        for (var i = 0; i < changed.length; i++)
            holder.poiChanged(changed[i]);
    }

    function clear(ignoreWhitelisted, poiId) {
        // Hide POI panel if its active
        if (app.poiActive && !poiId) hide();
        holder.pois = holder.pois.filter(function(p) {
            return (p.bookmarked ||
                    (poiId!=null && p.poiId!=poiId) ||
                    (ignoreWhitelisted &&
                     app.stateId === holder._poisKeep.stateId &&
                     holder._poisKeep.poiIds.indexOf(p["poiId"]) >= 0));
        });
        save();
        // emit to reinit poi lists if shown
        if (poiId) poiChanged(poiId);
        else poiChanged("");
    }

    function convertFromPython(pyPoi) {
        // convert POI dict as returned by Python
        // methods into JS representation
        return {
            "address": pyPoi.address || "",
            "email": pyPoi.email || "",
            "link": pyPoi.link || "",
            "phone": pyPoi.phone || "",
            "poiType": pyPoi.poi_type || "",
            "postcode": pyPoi.postcode || "",
            "provider": pyPoi.provider || "",
            "text": pyPoi.text || "",
            "title": pyPoi.title || model.place,
            "type": "geocode",
            "x": pyPoi.x,
            "y": pyPoi.y,
        };
    }

    function getById(poiId) {
        for (var i = 0; i < holder.pois.length; i++)
            if (holder.pois[i].poiId === poiId)
                return holder.pois[i];
    }

    function getProviders(type) {
        // Return list of providers for POIs of given type.
        return holder.pois.filter(function(poi) {
            return poi.type === type && poi.provider;
        }).map(function(poi) {
            return poi.provider;
        }).filter(function(provider, index, self) {
            return self.indexOf(provider) === index;
        });
    }

    function has(poi) {
        // check if such poi exists already
        // return poi if found or null if not
        var longitude = poi.coordinate ? poi.coordinate.longitude : poi.x;
        var latitude = poi.coordinate ? poi.coordinate.latitude : poi.y;
        for (var i = 0; i < holder.pois.length; i++)
            if (Math.abs(longitude - holder.pois[i].coordinate.longitude) < 1e-6 &&
                    Math.abs(latitude - holder.pois[i].coordinate.latitude) < 1e-6)
                return holder.pois[i];
        return null;
    }

    function hide() {
        if (infoPanel) infoPanel.hidePoi();
    }

    function load() {
        // Restore POIs from JSON file.
        py.call("poor.storage.read_pois", [], function(data) {
            data && data.length > 0 && holder.addList(data);
        });
    }

    function remove(poiId, confirm) {
        if (confirm) {
            app.remorse.execute(app.tr("Clearing map"),
                                function() {
                                    holder.remove(poiId);
                                });
            return;
        }

        if (poiId == null) return;
        holder.pois = holder.pois.filter(function(p) {
            return p.poiId != poiId;
        } );
        save();
        poiChanged(poiId);
    }

    function save() {
        // Save POIs to JSON file.
        var pois = holder.pois.filter(function (p) {
            return p.bookmarked;
        })
        var data = Util.pointsToJson(pois);
        py.call_sync("poor.storage.write_pois", [data]);
    }

    function shortlist(poiId, shortlist) {
        if (poiId == null) return;
        var changed = [];
        holder.pois = holder.pois.map(function(p) {
            if (p.poiId != poiId) return p;
            p.shortlisted = shortlist;
            changed.push(p.poiId);
            return p;
        } );
        save();
        for (var i = 0; i < changed.length; i++)
            holder.poiChanged(changed[i]);
    }

    function show(poi) {
        if (infoPanel) infoPanel.showPoi(poi);
    }

    function update(poi) {
        // update a POI with new data
        if (poi.poiId == null) return;
        holder.pois = holder.pois.map(function(p) {
            if (p.poiId != poi.poiId) return p;
            return poi;
        } );
        save();
        poiChanged(poi.poiId);
    }

}
