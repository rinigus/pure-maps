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
Routing using MapQuest Open.

http://open.mapquestapi.com/directions/
"""

import copy
import poor
import urllib.parse

CONF_DEFAULTS = {"avoids": [], "type": "fastest"}

ICONS = { 0: "straight",
          1: "turn-slight-right",
          2: "turn-right",
          3: "turn-sharp-right",
          4: "alert",
          5: "turn-sharp-left",
          6: "turn-left",
          7: "turn-slight-left",
          8: "u-turn-right",
          9: "u-turn-left",
         10: "merge-left",
         11: "merge-right",
         12: "ramp-right",
         13: "ramp-left",
         14: "ramp-right",
         15: "ramp-left",
         16: "fork-right",
         17: "fork-left",
         18: "straight"}

URL = ("http://open.mapquestapi.com/directions/v2/route"
       "?key=Fmjtd|luur2quy2h,bn=o5-9aasg4"
       "&ambiguities=ignore"
       "&from={fm}"
       "&to={to}"
       "&unit=k"
       "&routeType={type}"
       "&doReverseGeocode=false"
       "&shapeFormat=cmp"
       "&generalize=5"
       "&manMaps=false")

cache = {}

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to the router."""
    # MapQuest Open does geocoding too, but not that well.
    if isinstance(point, str):
        geocoder = poor.Geocoder("default")
        results = geocoder.geocode(point, dict(limit=1))
        with poor.util.silent(LookupError):
            point = (results[0]["x"], results[0]["y"])
    if isinstance(point, (list, tuple)):
        point = "{:.5f},{:.5f}".format(point[1], point[0])
    return urllib.parse.quote_plus(point)

def route(fm, to, params):
    """Find route and return its properties as a dictionary."""
    fm = prepare_endpoint(fm)
    to = prepare_endpoint(to)
    type = poor.conf.routers.mapquest_open.type
    url = URL.format(**locals())
    if type == "fastest":
        # Assume all avoids are related to cars.
        for avoid in poor.conf.routers.mapquest_open.avoids:
            url += "&avoids={}".format(urllib.parse.quote_plus(avoid))
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    result = poor.http.request_json(url)
    x, y = poor.util.decode_epl(result["route"]["shape"]["shapePoints"])
    maneuvers = []
    for leg in result["route"]["legs"]:
        maneuvers.extend(leg["maneuvers"])
    maneuvers = [dict(x=float(maneuver["startPoint"]["lng"]),
                      y=float(maneuver["startPoint"]["lat"]),
                      icon=ICONS.get(maneuver["turnType"], "alert"),
                      narrative=maneuver["narrative"],
                      duration=float(maneuver["time"]),
                      ) for maneuver in maneuvers]

    route = dict(x=x, y=y, maneuvers=maneuvers)
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route
