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

https://mapzen.com/products/turn-by-turn/
https://mapzen.com/documentation/mobility/turn-by-turn/api-reference/
"""

import copy
import json
import poor
import urllib.parse

CONF_DEFAULTS = {
    "language": poor.util.get_default_language("en"),
    "type": "auto",
}

ICONS = {
     0: "flag",
     1: "depart",
     2: "depart-right",
     3: "depart-left",
     4: "arrive",
     5: "arrive-right",
     6: "arrive-left",
     7: "continue",
     8: "continue",
     9: "turn-slight-right",
    10: "turn-right",
    11: "turn-sharp-right",
    12: "uturn",
    13: "uturn",
    14: "turn-sharp-left",
    15: "turn-left",
    16: "turn-slight-left",
    17: "continue",
    18: "off-ramp-slight-right",
    19: "off-ramp-slight-left",
    20: "off-ramp-slight-right",
    21: "off-ramp-slight-left",
    22: "fork-straight",
    23: "fork-slight-right",
    24: "fork-slight-left",
    25: "merge-slight-left",
    26: "roundabout",
    27: "off-ramp-slight-right",
    28: "ferry",
    29: "depart",
    30: "flag",
    31: "flag",
    32: "flag",
    33: "flag",
    34: "flag",
    35: "flag",
    36: "flag",
}

URL = "http://valhalla.mapzen.com/route?api_key=valhalla-bm7qrlo&json={input}"
cache = {}

def prepare_endpoint(point):
    """Return `point` as a dictionary ready to be passed on to the router."""
    if isinstance(point, (list, tuple)):
        return dict(lat=point[1], lon=point[0])
    geocoder = poor.Geocoder("default")
    results = geocoder.geocode(point, dict(limit=1))
    return prepare_endpoint((results[0]["x"], results[0]["y"]))

def route(fm, to, heading, params):
    """Find route and return its properties as a dictionary."""
    fm, to = map(prepare_endpoint, (fm, to))
    if heading is not None:
        fm["heading"] = heading
    language = poor.conf.routers.mapzen.language
    units = "kilometers" if poor.conf.units == "metric" else "miles"
    input = dict(locations=[fm, to],
                 costing=poor.conf.routers.mapzen.type,
                 directions_options=dict(language=language, units=units))

    input = urllib.parse.quote(json.dumps(input))
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    result = poor.http.get_json(url)
    result = poor.AttrDict(result)
    legs = result.trip.legs[0]
    x, y = poor.util.decode_epl(legs.shape, precision=6)
    maneuvers = [dict(
        x=float(x[maneuver.begin_shape_index]),
        y=float(y[maneuver.begin_shape_index]),
        icon=ICONS.get(maneuver.type, "flag"),
        narrative=maneuver.instruction,
        verbal_alert=maneuver.get("verbal_transition_alert_instruction", None),
        verbal_pre=maneuver.get("verbal_pre_transition_instruction", None),
        verbal_post=maneuver.get("verbal_post_transition_instruction", None),
        duration=float(maneuver.time),
    ) for maneuver in legs.maneuvers]
    route = dict(x=x, y=y, maneuvers=maneuvers, mode="car")
    route["attribution"] = poor.util.get_routing_attribution("Mapzen")
    route["language"] = result.trip.language
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route
