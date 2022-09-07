# -*- coding: utf-8 -*-

# Copyright (C) 2016 rinigus
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
Geocoding using OSM Scout Server Geocoder.

https://github.com/rinigus/osmscout-server
"""

import copy
import poor
import urllib.parse

URL = "http://localhost:8553/v1/search?limit={limit}&search={query}"
URL_REVERSE = "http://localhost:8553/v1/guide?radius={radius}&limit={limit}&lng={lng}&lat={lat}&poitype=any"
cache = {}

def autocomplete(query, x=0, y=0, zoom=16, params={}):
    """Return a list of autocomplete dictionaries matching `query`."""
    if len(query) < 3: return []
    results = geocode(query=query, x=x, y=y, zoom=zoom, params=params)
    return results

def geocode(query, x=0, y=0, zoom=16, params={}):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    limit = params.get("limit", 25)
    url = URL.format(**locals())
    if x and y:
        url += "&lng={:.3f}".format(x)
        url += "&lat={:.3f}".format(y)
        if zoom:
            url += "&zoom={zoom}".format(zoom=int(zoom))
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)
    results = list(map(poor.AttrDict, results))
    results = [dict(
        address=parse_address(result),
        label=parse_label(result),
        link=result.get("website", ""),
        phone=result.get("phone", ""),
        poi_type=parse_type(result),
        postcode=result.get("postal_code", ""),
        title=result.title,
        description=parse_description(result),
        x=float(result.lng),
        y=float(result.lat),
    ) for result in results]
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

def parse_address(result):
    with poor.util.silent(Exception):
        return result.admin_region
    return ""

def parse_description(result):
    """Parse description from geocoding result."""
    items = []
    with poor.util.silent(Exception):
        type = result.type
        type = type.replace("amenity", "")
        type = type.replace("_", " ").strip()
        items.append(type.capitalize())
    with poor.util.silent(Exception):
        items.append(result.admin_region)
    return ", ".join(items) or ""

def parse_label(result):
    """Parse description from geocoding result."""
    label = result.title
    with poor.util.silent(Exception):
        label = result.admin_region
    return label

def parse_type(result):
    with poor.util.silent(Exception):
        type = result.type
        type = type.replace("amenity", "")
        type = type.replace("_", " ").strip()
        return type.capitalize()
    return ""

def reverse(x, y, radius, limit=25, params={}):
    """Return a list of dictionaries of places nearby given coordinates."""
    lng = x
    lat = y
    url = URL_REVERSE.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)
    results = poor.AttrDict(results)
    results = [dict(
        address=parse_address(result),
        link=result.get("website", ""),
        phone=result.get("phone", ""),
        poi_type=parse_type(result),
        postcode=result.get("postal_code", ""),
        title=result.title,
        description=parse_description(result),
        distance=float(result.distance),
        x=float(result.lng),
        y=float(result.lat),
    ) for result in results.results]
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

