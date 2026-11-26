# -*- coding: utf-8 -*-

# Copyright (C) 2026 Boris Solodki
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
Geocoding using TomTom Search API.

https://developer.tomtom.com/search-api/documentation
"""

import copy
import poor
import urllib.parse

URL = ("https://api.tomtom.com/search/2/search/{query}.json"
       "?key={key}&limit={limit}&language={lang}&typeahead={typeahead}")
URL_REVERSE = ("https://api.tomtom.com/search/2/reverseGeocode/{lat:.6f},{lon:.6f}.json"
               "?key={key}&language={lang}&radius={radius}")

cache = {}


def get_lang():
    return poor.util.get_default_locale("en_GB").replace("_", "-")

def fetch(url):
    """Fetch `url`, holding a {key} placeholder, with caching."""
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    # read the key on every call to follow changes made in preferences
    key = poor.key.get("TOMTOM_KEY")
    try:
        result = poor.http.get_json(url.replace("{key}", urllib.parse.quote(key)))
    except Exception as e:
        # do not let the key leak into logs through the failed URL
        raise RuntimeError(str(e).replace(key, "***")) from None
    cache[url] = copy.deepcopy(result)
    return result

def search(query, x, y, limit, typeahead):
    url = URL.format(query=urllib.parse.quote(query.strip(), safe=""),
                     key="{key}",
                     limit=int(limit),
                     lang=urllib.parse.quote(get_lang()),
                     typeahead="true" if typeahead else "false")
    if x and y:
        url += "&lat={:.3f}&lon={:.3f}".format(y, x)
    results = fetch(url).get("results", [])
    return [parse_result(poor.AttrDict(r)) for r in results if "position" in r]

def autocomplete(query, x=0, y=0, zoom=16, params={}):
    """Return a list of autocomplete dictionaries matching `query`."""
    if len(query.strip()) < 3: return []
    return search(query, x, y, params.get("limit", 10), True)

def geocode(query, x=0, y=0, zoom=16, params={}):
    """Return a list of dictionaries of places matching `query`."""
    return search(query, x, y, params.get("limit", 20), False)

def reverse(x, y, radius, limit=1, params={}):
    """Return a list of dictionaries of places nearby given coordinates."""
    url = URL_REVERSE.format(lat=y, lon=x, key="{key}",
                             lang=urllib.parse.quote(get_lang()),
                             radius=int(max(1, radius)))
    results = []
    for r in fetch(url).get("addresses", [])[:limit]:
        r = poor.AttrDict(r)
        address = r.get("address", {})
        full = address.get("freeformAddress", "")
        if not full: continue
        title, description = split_address(address, full)
        px, py = x, y
        with poor.util.silent(Exception):
            lat, lon = r.position.split(",")
            px, py = float(lon), float(lat)
        results.append(dict(
            address=full,
            label=full,
            poi_type="",
            postcode=address.get("postalCode", ""),
            title=title,
            description=description,
            x=px,
            y=py,
        ))
    return results

def split_address(address, full):
    """Return title and description out of address."""
    head = full.split(",")[0].strip()
    rest = full[len(full.split(",")[0]):].lstrip(", ").strip()
    if not rest:
        rest = ", ".join(i for i in (address.get("countrySubdivision", ""),
                                     address.get("country", "")) if i)
    return head, rest

def parse_result(result):
    address = result.get("address", {})
    full = address.get("freeformAddress", "")
    poi = result.get("poi", {})
    name = poi.get("name", "")
    if name:
        title, description = name, full
        label = "{}: {}".format(name, full) if full else name
    else:
        title, description = split_address(address, full)
        label = full
    categories = poi.get("categories", None) or []
    # prefer the point to drive to over the centre of the place
    x, y = float(result.position.lon), float(result.position.lat)
    for entry in result.get("entryPoints", None) or []:
        if entry.get("type", "") == "main":
            x, y = float(entry["position"]["lon"]), float(entry["position"]["lat"])
            break
    return dict(
        address=full,
        label=label,
        poi_type=", ".join(c.capitalize() for c in categories),
        postcode=address.get("postalCode", ""),
        title=title,
        description=description,
        phone=poi.get("phone", ""),
        link=poi.get("url", ""),
        x=x,
        y=y,
    )
