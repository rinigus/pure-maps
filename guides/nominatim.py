# -*- coding: utf-8 -*-

# Copyright (C) 2014 Osmo Salomaa
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
Listing nearby places using MapQuest Nominatim.

http://open.mapquestapi.com/nominatim/
http://wiki.openstreetmap.org/wiki/Nominatim
"""

import copy
import poor
import urllib.parse

URL = ("http://open.mapquestapi.com/nominatim/v1/search.php"
       "?key=2aHt8JcDObJZhGHZ9EPv99F1N5JNp1RI"
       "&format=json"
       "&q={query}"
       "&addressdetails=1"
       "&limit={limit}"
       "&bounded=1"
       "&viewbox={xmin:.5f},{ymax:.5f},{xmax:.5f},{ymin:.5f}"
       "&accept-language={lang}")

cache = {}

def append1(lst, dic, names):
    """Append the first found name in `dic` to `lst`."""
    for name in names:
        if name in dic:
            return lst.append(dic[name])

def get_bbox(x, y, radius):
    """Return xmin, xmax, ymin, ymax."""
    x_m_per_deg = poor.util.calculate_distance(x, y, x+1, y)
    y_m_per_deg = poor.util.calculate_distance(x, y, x, y+1)
    xmin = x - radius/x_m_per_deg
    xmax = x + radius/x_m_per_deg
    ymin = y - radius/y_m_per_deg
    ymax = y + radius/y_m_per_deg
    return xmin, xmax, ymin, ymax

def nearby(query, near, radius, params):
    """Return X, Y and a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    x, y = prepare_point(near)
    xmin, xmax, ymin, ymax = get_bbox(x, y, radius)
    limit = params.get("limit", 50)
    lang = poor.util.get_default_language("en")
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)
    results = list(map(poor.AttrDict, results))
    results = [dict(
        title=parse_title(result),
        description=parse_description(result),
        x=float(result.lon),
        y=float(result.lat),
    ) for result in results]
    if results and results[0]:
        results = poor.util.sorted_by_distance(results, x, y)
        cache[url] = copy.deepcopy((x, y, results))
    return x, y, results

def parse_address(address):
    """Parse address from search result."""
    items = []
    # http://help.openstreetmap.org/questions/17072
    append1(items, address, ("road", "pedestrian", "footway", "cycleway"))
    append1(items, address, ("house_number",))
    if not items:
        raise ValueError
    return " ".join(items)

def parse_city(address):
    """Parse city from search result."""
    items = []
    # http://wiki.openstreetmap.org/wiki/Key:place
    append1(items, address, ("borough", "suburb", "quarter", "neighbourhood"))
    append1(items, address, ("city", "town", "village", "hamlet"))
    if not items:
        raise ValueError
    return items

def parse_description(result):
    """Parse description from search result."""
    items = []
    with poor.util.silent(Exception):
        items.append(parse_address(result.address))
    with poor.util.silent(Exception):
        items.extend(parse_city(result.address))
    title = parse_title(result)
    while items and title.startswith(items[0]):
        del items[0]
    if not items:
        return "—"
    return ", ".join(items)

def parse_title(result):
    """Parse title from search result."""
    address = result.address
    with poor.util.silent(Exception):
        return address[result.type]
    with poor.util.silent(Exception):
        return address[result["class"]]
    with poor.util.silent(Exception):
        return parse_address(result)
    with poor.util.silent(Exception):
        names = result.display_name.split(", ")
        end = (2 if names[0].isdigit() else 1)
        return ", ".join(names[:end])
    return "—"

def prepare_point(point):
    """Return geocoded coordinates for `point`."""
    if isinstance(point, (list, tuple)):
        return point[0], point[1]
    geocoder = poor.Geocoder("default")
    results = geocoder.geocode(point, dict(limit=1))
    return results[0]["x"], results[0]["y"]
