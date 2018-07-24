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

function findMatches(query, candidates, max) {
    // Return an array of matches from among candidates.
    query = query.toLowerCase();
    var components = query.split(/ +/);
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
