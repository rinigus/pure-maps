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
Geocoding using Helsinki Region Transport (HSL) Journey Planner.

http://developer.reittiopas.fi/pages/en/home.php
"""

import copy
import poor
import urllib.parse

URL=("http://api.reittiopas.fi/hsl/prod/"
     "?request=geocode"
     "&user=poor-maps"
     "&pass=56388083"
     "&format=json"
     "&epsg_out=4326"
     "&lang=fi"
     "&key={query}")

cache = {}

def geocode(query, params):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.request_json(url)
    results = [dict(title=parse_title(result),
                    description=parse_description(result),
                    x=float(result["coords"].split(",")[0]),
                    y=float(result["coords"].split(",")[1]),
                    ) for result in results]

    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

def parse_description(result):
    """Parse description from geocoding result."""
    items = []
    if result["locType"] == "stop":
        with poor.util.silent(KeyError):
            items.append(result["details"]["address"])
    items.append(result["city"])
    return ", ".join(items)

def parse_title(result):
    """Parse title from geocoding result."""
    items = [result.get("shortName", result["name"])]
    if result["locType"] == "address":
        with poor.util.silent(KeyError, ValueError):
            items.append(str(result["details"]["houseNumber"]))
    return " ".join(items)
