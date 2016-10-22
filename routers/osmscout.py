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

https://github.com/rinigus/osmscout-server
"""

import copy
import json
import poor
import urllib.parse

CONF_DEFAULTS = {"type": "car"}

ICONS = { "flag": "flag",
          "start": "depart",
          "destination": "arrive",
          #5: "arrive-right",
          #6: "arrive-left",
          #7: "continue",
          "straight": "continue",
          "turn-slight-right": "turn-slight-right",
          "turn-right": "turn-right",
          "turn-sharp-right": "turn-sharp-right",
          #12: "uturn",
          #13: "uturn",
          "turn-sharp-left": "turn-sharp-left",
          "turn-left": "turn-left",
          "turn-slight-left": "turn-slight-left",
          #17: "continue",
          #18: "off-ramp-slight-right",
          #19: "off-ramp-slight-left",
          #20: "off-ramp-slight-right",
          #21: "off-ramp-slight-left",
          #22: "fork-straight",
          #23: "fork-slight-right",
          #24: "fork-slight-left",
          "merge": "merge-slight-left",
          "roundabout-enter": "roundabout",
          "roundabout-exit": "off-ramp-slight-right",
          #28: "flag",
          #29: "flag",
          #30: "flag",
          #31: "flag",
          #32: "flag",
          #33: "flag",
          #34: "flag",
          #35: "flag",
          #36: "flag",
          "motorway-change": "flag",
          "motorway-leave": "off-ramp-slight-right",
          "none": "flag"
}

URL = ("http://localhost:8553/v1/route?"
       "type={type}"
       "&radius={radius}")
       
cache = {}

def route(fm, to, params):
    """Find route and return its properties as a dictionary."""
    type = poor.conf.routers.osmscout.type
    radius = 1000.0

    url = URL.format(**locals())
    for i, p in enumerate([fm, to]):
        if isinstance(p, (list, tuple)):
            x, y = p[0], p[1]
            url += "&p[%d][lng]=%0.8f" % (i,x)
            url += "&p[%d][lat]=%0.8f" % (i,y)
        else:
            url += ("&p[%d][search]=" % i) + urllib.parse.quote_plus(p)
            
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    result = poor.http.request_json(url)
    x, y = result["lng"], result["lat"]
    maneuvers = [dict(
        x=float(maneuver["lng"]),
        y=float(maneuver["lat"]),
        icon=ICONS.get(maneuver.get("type", "flag"), "flag"),
        narrative=maneuver["instruction"],
        duration=float(maneuver["time"]),
        length=float(maneuver["length"]),
        post=maneuver.get("verbal_post_transition_instruction", None),
        pre=maneuver.get("verbal_pre_transition_instruction", None) 
    ) for maneuver in result["maneuvers"]]
    route = dict(x=x, y=y, maneuvers=maneuvers)
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)

    return route
