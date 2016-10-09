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
Geocoding using OSMScout Server Geocoder.

https://github.com/rinigus/osmscout-server
"""

import copy
import poor
import re
import urllib.parse

URL = ("http://localhost:8553/v1/search?"
       "limit={limit}&"
       "search={query}" )

cache = {}

def geocode(query, params):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    limit = params.get("limit", 25)
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.request_json(url)
    results = [dict(title=result["title"],
                    description=parse_description(result),
                    x=float(result["lng"]),
                    y=float(result["lat"]),
                    ) for result in results]

    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

def parse_description(result):
    """Parse description from geocoding result."""
    description = ""
    for i in ["type", "admin_region", "object_id"]:
        if i in result:
            description += result[i] + "; "
    return description.strip()

