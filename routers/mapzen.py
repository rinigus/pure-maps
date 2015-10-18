# -*- coding: utf-8 -*-

# Copyright (C) 2015 Osmo Salomaa
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
Routing using Mapzen Turn-by-Turn.

https://mapzen.com/projects/valhalla
https://github.com/valhalla/valhalla-docs
"""

import copy
import json
import poor
import urllib.parse

CONF_DEFAULTS = {"type": "auto"}

ICONS = { 0: "alert",
          1: "alert",
          2: "turn-right",
          3: "turn-left",
          4: "alert",
          5: "turn-right",
          6: "turn-left",
          7: "straight",
          8: "straight",
          9: "turn-slight-right",
         10: "turn-right",
         11: "turn-sharp-right",
         12: "turn-right",
         13: "turn-left",
         14: "turn-sharp-left",
         15: "turn-left",
         16: "turn-slight-left",
         17: "straight",
         18: "ramp-right",
         19: "ramp-left",
         20: "ramp-right",
         21: "ramp-left",
         22: "straight",
         23: "fork-right",
         24: "fork-left",
         25: "merge-left",
         26: "merge-left",
         27: "ramp-right",
         28: "alert",
         29: "alert"}

URL = ("http://valhalla.mapzen.com/route"
       "?api_key=valhalla-bm7qrlo"
       "&json={input}")

cache = {}

def prepare_endpoint(point):
    """Return `point` as a dictionary ready to be passed on to the router."""
    # Mapzen requires coordinates, let's geocode using Nominatim.
    if isinstance(point, str):
        geocoder = poor.Geocoder("nominatim")
        results = geocoder.geocode(point, dict(limit=1))
        with poor.util.silent(LookupError):
            point = (results[0]["x"], results[0]["y"])
    return dict(lat=point[1], lon=point[0])

def route(fm, to, params):
    """Find route and return its properties as a dictionary."""
    fm = prepare_endpoint(fm)
    to = prepare_endpoint(to)
    type = poor.conf.routers.mapzen.type
    input = dict(locations=[fm, to], costing=type)
    input = urllib.parse.quote(json.dumps(input))
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    result = poor.http.request_json(url)
    legs = result["trip"]["legs"][0]
    x, y = poor.util.decode_epl(legs["shape"], precision=6)
    maneuvers = [dict(x=x[maneuver["begin_shape_index"]],
                      y=y[maneuver["begin_shape_index"]],
                      icon=ICONS.get(maneuver["type"], "alert"),
                      narrative=maneuver["instruction"],
                      duration=float(maneuver["time"]),
                      ) for maneuver in legs["maneuvers"]]

    route = dict(x=x, y=y, maneuvers=maneuvers)
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route
