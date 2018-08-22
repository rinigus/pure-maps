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
Geocoding using OpenCage Geocoder.

https://geocoder.opencagedata.com/api
"""

import copy
import poor
import re
import urllib.parse

URL = ("http://api.opencagedata.com/geocode/v1/json"
       "?key=0039dc979e2c48a09149d49c24937074"
       "&q={query}"
       "&limit={limit}"
       "&no_annotations=1"
       "&language={lang}")

cache = {}

def geocode(query, params):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    limit = params.get("limit", 10)
    lang = poor.util.get_default_language("en")
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)["results"]
    results = list(map(poor.AttrDict, results))
    results = [dict(
        title=parse_title(result),
        description=parse_description(result),
        x=float(result.geometry.lng),
        y=float(result.geometry.lat),
    ) for result in results]
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

def parse_description(result):
    """Parse description from geocoding result."""
    title = parse_title(result)
    description = result.formatted
    if description.startswith(title):
        description = description[len(title):]
    return re.sub("^[, ]+", "", description)

def parse_title(result):
    """Parse title from geocoding result."""
    with poor.util.silent(KeyError):
        type = result.components._type
        return str(result.components[type])
    return result.formatted.split(",")[0]
