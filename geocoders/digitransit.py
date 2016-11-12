# -*- coding: utf-8 -*-

# Copyright (C) 2016 Osmo Salomaa
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
Geocoding using Digitransit.

https://digitransit.fi/en/developers/services-and-apis/2-geocoding-api/address-search/
"""

import copy
import poor
import urllib.parse

URL = "http://api.digitransit.fi/geocoding/v1/search?text={query}&size={limit}"
cache = {}

def geocode(query, params):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    limit = params.get("limit", 10)
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.request_json(url)["features"]
    results = [dict(title=result["properties"]["name"],
                    description=parse_description(result),
                    x=float(result["geometry"]["coordinates"][0]),
                    y=float(result["geometry"]["coordinates"][1]),
                    ) for result in results]

    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

def parse_description(result):
    """Parse description from geocoding result."""
    props = result["properties"]
    items = []
    with poor.util.silent(Exception):
        items.append(props["neighbourhood"])
    with poor.util.silent(Exception):
        items.append(props["locality"])
    with poor.util.silent(Exception):
        items.append(props["region"])
    with poor.util.silent(Exception):
        items.append(props["country"])
    return ", ".join(items)
