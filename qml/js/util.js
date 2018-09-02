/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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

function addProperties(items, name, value) {
    // Assign name to value in-place in all given items.
    for (var i = 0; i < items.length; i++)
        items[i][name] = value;
}

function angleDifference(alpha, beta) {
    // Return the absolute difference in degrees between two angles.
    var diff = Math.abs(alpha - beta) % 360;
    return diff > 180 ? 360 - diff : diff;
}

function appendAll(model, items) {
    // Append all items to model.
    for (var i = 0; i < items.length; i++)
        model.append(items[i]);
}

function findMatches(query, candidates, completions, max) {
    // Return an array of matches from among candidates and completions.
    // candidates might contain matches, completions are known to match.
    query = query.toLowerCase();
    var components = query.split(/ +/);
    candidates = candidates.concat(completions);
    var foundBeginning = [], foundLater = [];
    for (var i = 0; i < candidates.length; i++) {
        // Find indices of all query components in given candidate.
        // Require that all components be found and make a distinction
        // between matches at the start of the string vs. later.
        var indices = components.map(function(x) {
            return candidates[i].toLowerCase().indexOf(x);
        });
        var minIndex = Math.min.apply(Math, indices);
        if (minIndex == 0) foundBeginning.push(candidates[i]);
        if (minIndex >= 1) foundLater.push(candidates[i]);
    }
    var found = foundBeginning.concat(foundLater);
    // Add non-matching completions to the end.
    found = found.concat(completions);
    found = uniqueCaseInsensitive(found);
    found = found.slice(0, max);
    for (var i = 0; i < found.length; i++) {
        // Highlight matching portion in markup field.
        // XXX: This is not component-wise.
        found[i] = {"text": found[i]};
        found[i].markup = Theme.highlightText(
            found[i].text, query, Theme.highlightColor);
    }
    return found;
}

function findMatchesInObjects(query, candidates, keys) {
    // Return an array of objects from candidates that
    // have at match among values of the object. The returned
    // array is sorted on return
    var d = Array.apply(null, {"length": candidates.length}).map(Number.call, Number);
    if (query) {
        query = query.toLowerCase();
        var components = query.split(/ +/);
        d = d.filter(function (index) {
            var p = candidates[index];
            var s = "";
            for (var i=0; i < keys.length; i++)
                s = s + " " + p[ keys[i] ].toLowerCase();
            var found = true;
            for (var i=0; i < components.length && found; i++) {
                if (s.indexOf(components[i]) < 0)
                    found = false;
            }
            return found;
        });
    }
    d.sort(function (ai, bi){
        var a = candidates[ai];
        var b = candidates[bi];
        for (var i=0; i < keys.length; i++) {
            var va = a[ keys[i] ];
            var vb = b[ keys[i] ];
            if (va != null && vb == null) return -1;
            if (va == null && vb != null) return  1;
            if (va < vb) return -1;
            if (va > vb) return  1;
        }
        return 0;
    });
    var result = [];
    d.map(function (i){ result.push(candidates[i]); });
    return result;
}

function injectMatches(model, found, text, markup) {
    // Set array of matches into existing ListView model items.
    found = found.slice(0, model.count);
    for (var i = 0; i < found.length; i++) {
        model.setProperty(i, text, found[i].text);
        model.setProperty(i, markup, found[i].markup);
        model.setProperty(i, "visible", true);
    }
    for (var i = found.length; i < model.count; i++)
        model.setProperty(i, "visible", false);
}

function markDefault(providers, defpid) {
    // Edit the default provider's name in-place.
    for (var i = 0; i < providers.length; i++)
        if (providers[i].pid === defpid)
            providers[i].name = (qsTranslate("", "%1 (default)")
                                 .arg(providers[i].name));

}

function median(x) {
    // Calculate the median of numeric array.
    if (x.length === 0) return NaN;
    if (x.length === 1) return x[0];
    x = x.slice();
    x.sort(function(a, b) {
        return a - b;
    });
    var i = Math.floor(x.length / 2);
    if (x.length % 2 === 1)
        return x[i];
    return (x[i-1] + x[i]) / 2;
}

function pluck(items, key) {
    // Return an array of the values of key in items.
    return items.map(function(item) {
        return item[key];
    });
}

function pointsToJson(points) {
    // Return a shallow copy of points with coordinates unpacked.
    return points.map(function(point) {
        var data = shallowCopy(point);
        data.x = data.coordinate.longitude;
        data.y = data.coordinate.latitude;
        delete data.bubble;
        delete data.coordinate;
        return data;
    });
}

function polylineToJson(polyline) {
    // Return a shallow copy of points with coordinates unpacked.
    if (!polyline.coordinates) return {};
    var data = shallowCopy(polyline);
    data.x = pluck(data.coordinates, "longitude");
    data.y = pluck(data.coordinates, "latitude");
    delete data.coordinates;
    return data;
}

function shallowCopy(obj) {
    // Return a shallow copy of object.
    var copy = {};
    for (var key in obj)
        copy[key] = obj[key];
    return copy;
}

function siground(x, n) {
    // Round x to n significant digits.
    var mult = Math.pow(10, n - Math.floor(Math.log(x) / Math.LN10) - 1);
    return Math.round(x * mult) / mult;
}

function sortDefaultFirst(providers) {
    // Sort providers in-place, placing the default first.
    for (var i = 0; i < providers.length; i++) {
        providers[i]["default"] &&
            providers.splice(0, 0, providers.splice(i, 1)[0]);
    }
}

function uniqueCaseInsensitive(x) {
    // Return an array with the case insensitive unique values of x.
    // http://stackoverflow.com/a/1961068
    var u = {}, a = [];
    for (var i = 0; i < x.length; i++) {
        var key = x[i].toLowerCase();
        if (u.hasOwnProperty(key)) continue;
        u[key] = 1;
        a.push(x[i]);
    }
    return a;
}

function uuidv4() {
    // Generate UUID-like string
    // https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
    // implementation from https://stackoverflow.com/a/2117523
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}
