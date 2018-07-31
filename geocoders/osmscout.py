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
cache = {}

def autocomplete(query, x, y, params):
    """Return a list of autocomplete dictionaries matching `query`."""
    if len(query) < 3: return []
    key = "autocomplete:{}".format(query)
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[key])
    results = geocode(query, params)
    cache[key] = copy.deepcopy(results)
    return results

def geocode(query, params):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    limit = params.get("limit", 25)
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)
    results = list(map(poor.AttrDict, results))
    results = [dict(
        label=parse_label(result),
        title=result.title,
        description=parse_description(result),
        x=float(result.lng),
        y=float(result.lat),
    ) for result in results]
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

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
    return ", ".join(items) or "–"

def parse_label(result):
    """Parse description from geocoding result."""
    label = result.title
    with poor.util.silent(Exception):
        label = result.admin_region
    return label
