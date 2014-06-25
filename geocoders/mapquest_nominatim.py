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
Geocoding using MapQuest Nominatim.

http://open.mapquestapi.com/nominatim/
http://wiki.openstreetmap.org/wiki/Nominatim
"""

import copy
import json
import poor
import urllib.parse

URL = ("http://open.mapquestapi.com/nominatim/v1/search.php"
       "?format=json"
       "&q={query}"
       "&addressdetails=1"
       "&limit=20")

cache = {}

def append1(lst, dic, names):
    """Append the first found name in `dic` to `lst`."""
    for name in names:
        if name in dic:
            return lst.append(dic[name])

def geocode(query, nmax):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    url = URL.format(**locals())
    with poor.util.silent(LookupError):
        return copy.deepcopy(cache[url][:nmax])
    results = json.loads(poor.util.request_url(url, "utf_8"))
    results = [dict(title=parse_title(result),
                    description=parse_description(result),
                    x=float(result["lon"]),
                    y=float(result["lat"]),
                    ) for result in results]

    cache[url] = copy.deepcopy(results)
    return results[:nmax]

def parse_address(result):
    """Parse address from geocoding result."""
    address = result["address"]
    items = []
    # http://help.openstreetmap.org/questions/17072
    append1(items, address, ("road", "pedestrian", "footway", "cycleway"))
    append1(items, address, ("house_number",))
    if not items:
        raise ValueError
    return " ".join(items)

def parse_city(result):
    """Parse city from geocoding result."""
    address = result["address"]
    items = []
    # http://wiki.openstreetmap.org/wiki/Key:place
    append1(items, address, ("borough", "suburb", "quarter", "neighbourhood"))
    append1(items, address, ("city", "town", "village", "hamlet"))
    if not items:
        raise ValueError
    return items

def parse_description(result):
    """Parse description from geocoding result."""
    items = []
    with poor.util.silent(Exception):
        items.append(parse_address(result))
    with poor.util.silent(Exception):
        items.extend(parse_city(result))
    with poor.util.silent(Exception):
        items.extend(parse_region(result))
    title = parse_title(result)
    while items and title.startswith(items[0]):
        items.pop(0)
    if not items:
        return "—"
    return ", ".join(items)

def parse_region(result):
    """Parse region from geocoding result."""
    address = result["address"]
    items = []
    # http://wiki.openstreetmap.org/wiki/Key:place
    append1(items, address, ("state", "region", "province", "district"))
    append1(items, address, ("country",))
    if not items:
        raise ValueError
    return items

def parse_title(result):
    """Parse title from geocoding result."""
    address = result["address"]
    with poor.util.silent(Exception):
        return address[result["type"]]
    with poor.util.silent(Exception):
        return address[result["class"]]
    with poor.util.silent(Exception):
        return parse_address(result)
    with poor.util.silent(Exception):
        names = result["display_name"].split(", ")
        end = (2 if names[0].isdigit() else 1)
        return ", ".join(names[:end])
    return "—"
