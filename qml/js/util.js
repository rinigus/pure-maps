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

/*
 * Calculations below between longitude/latitude coordinates,
 * Mercator-projected coordinates and pixel positions on screen
 * assume a spherical Mercator map canvas.
 *
 * http://en.wikipedia.org/wiki/Mercator_projection
 * http://wiki.openstreetmap.org/wiki/Mercator
 */

function addProperties(items, name, value) {
    // Assign name to value in-place in all given items.
    for (var i = 0; i < items.length; i++)
        items[i][name] = value;
}

function appendAll(model, items) {
    // Append all items to model.
    for (var i = 0; i < items.length; i++)
        model.append(items[i]);
}

function deg2rad(deg) {
    // Convert degrees to radians.
    return deg / 180 * Math.PI;
}

function eucd(x1, y1, x2, y2) {
    // Calculate euclidean distance.
    var xd = x2 - x1;
    var yd = y2 - y1;
    return Math.sqrt(xd*xd + yd*yd);
}

function findMatches(query, candidates, max) {
    // Return an array of matches from among candidates.
    query = query.toLowerCase();
    var found = [];
    for (var i = 0; i < candidates.length; i++) {
        // Match at the start of candidate strings.
        var candidate = candidates[i].toLowerCase();
        if (query && candidate.indexOf(query) === 0)
            found.push(candidates[i]);
    }
    for (var i = 0; i < candidates.length; i++) {
        // Match later in the candidate strings.
        var candidate = candidates[i].toLowerCase();
        if (query.length === 0 || candidate.indexOf(query) > 0)
            found.push(candidates[i]);
    }
    found = found.slice(0, max);
    for (var i = 0; i < found.length; i++) {
        // Highlight matching portion in markup field.
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
        return a-b;
    });
    var i = Math.floor(x.length / 2);
    if (x.length % 2 === 1)
        return x[i];
    return (x[i-1] + x[i]) / 2;
}

function rad2deg(rad) {
    // Convert radians to degrees.
    return rad / Math.PI * 180;
}

function removeMapItems(map, items) {
    // Remove map items from map and destroy them.
    for (var i = 0; i < items.length; i++) {
        map.removeMapItem(items[i]);
        items[i].destroy();
    }
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

function xcoord2xpos(x, xmin, xmax, width) {
    // Convert X-coordinate to pixel X-position on screen.
    return Math.round((x - xmin) * (width / (xmax - xmin)));
}

function xpos2xcoord(x, xmin, xmax, width) {
    // Convert screen pixel X-position to X-coordinate.
    return xmin + (x / (width / (xmax - xmin)));
}

function ycoord2ymercator(y) {
    // Convert Y-coordinate to Mercator projected Y-coordinate.
    return Math.log(Math.tan(Math.PI/4 + deg2rad(y)/2));
}

function ycoord2ypos(y, ymin, ymax, height) {
    // Convert Y-coordinate to pixel Y-position on screen.
    ymin = ycoord2ymercator(ymin);
    ymax = ycoord2ymercator(ymax);
    return Math.round((ymax - ycoord2ymercator(y)) * (height / (ymax - ymin)));
}

function ymercator2ycoord(y) {
    // Convert Mercator projected Y-coordinate to Y-coordinate.
    return rad2deg(2 * Math.atan(Math.exp(y)) - Math.PI/2);
}

function ypos2ycoord(y, ymin, ymax, height) {
    // Convert screen pixel Y-position to Y-coordinate.
    ymin = ymercator2ycoord(ymin);
    ymax = ymercator2ycoord(ymax);
    return (ymin + (ymercator2ycoord(y) / (height / (ymax - ymin))));
}
