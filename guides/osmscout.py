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
Listing nearby places using OSM Scout Server.

https://github.com/rinigus/osmscout-server
"""

import copy
import functools
import json
import poor
import unicodedata
import urllib.parse

URL_SEARCH = ("http://localhost:8553/v1/guide"
              "?limit={limit}"
              "&poitype={query}"
              "&name={name}"
              "&radius={radius}"
              "&search={search}")

URL_XY = ("http://localhost:8553/v1/guide"
          "?limit={limit}"
          "&poitype={query}"
          "&name={name}"
          "&radius={radius}"
          "&lng={x}"
          "&lat={y}")

URL_ROUTEONLY = ("http://localhost:8553/v1/guide"
                 "?limit={limit}"
                 "&poitype={query}"
                 "&name={name}"
                 "&radius={radius}")

cache = {}

def autocomplete_type(query, params=None):
    """Return a list of autocomplete dictionaries matching `query`."""
    query = normalize(query)
    results = []
    for t in get_types():
        pos = t["normalized"].find(query)
        if pos < 0: continue
        results.append({"label": t["original"]})
        if len(results) > 100:
            break
    return results

@functools.lru_cache(1)
def get_types():
    """Get list of types"""
    types = []
    for t in poor.http.get_json("http://localhost:8553/v1/poi_types"):
        types.append({"original": t, "normalized": normalize(t)})
    return types

def nearby(query, near, radius, params):
    """Return X, Y and a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    limit = params.get("limit", 50)
    name = params.get("name", "")
    name = urllib.parse.quote_plus(name)
    route_search = params.get("alongRoute", False)
    route = params.get("route", {})
    use_reference = params.get("fromReference", True)
    if route_search and not use_reference:
        url = URL_ROUTEONLY.format(**locals())
    elif isinstance(near, (list, tuple)):
        x, y = near[0], near[1]
        url = URL_XY.format(**locals())
    else:
        search = urllib.parse.quote_plus(near)
        url = URL_SEARCH.format(**locals())
    # with poor.util.silent(KeyError):
    #     return copy.deepcopy(cache[url])
    if route_search:
        results = poor.http.post_json(url, json.dumps(route))
    else:
        results = poor.http.get_json(url)
    results = poor.AttrDict(results)
    x = float(results.origin.lng)
    y = float(results.origin.lat)
    results = [dict(
        title=result.title,
        description=parse_description(result),
        distance=float(result.distance),
        x=float(result.lng),
        y=float(result.lat),
    ) for result in results.results]
    # if results and results[0]:
    #     cache[url] = copy.deepcopy((x, y, results))
    return x, y, results

def normalize(t):
    """Normalize the string"""
    return unicodedata.normalize("NFKC", t).casefold()

def parse_description(result):
    """Parse description from search result."""
    items = []
    with poor.util.silent(Exception):
        type = result.type
        type = type.replace("amenity", "")
        type = type.replace("_", " ").strip()
        items.append(type.capitalize())
    with poor.util.silent(Exception):
        items.append(result.admin_region)
    return ", ".join(items) or "–"
