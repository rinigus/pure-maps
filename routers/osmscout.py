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
Routing using OSM Scout Server's Valhalla and libosmscout routers.

https://github.com/rinigus/osmscout-server
https://github.com/valhalla/valhalla-docs/blob/master/api-reference.md
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

ICONS_OSMSCOUT = {
    "destination": "arrive",
    "flag": "flag",
    "merge": "merge-slight-left",
    "motorway-change": "flag",
    "motorway-leave": "off-ramp-slight-right",
    "none": "flag",
    "roundabout-enter": "roundabout",
    "roundabout-exit": "off-ramp-slight-right",
    "start": "depart",
    "straight": "continue",
    "turn-left": "turn-left",
    "turn-right": "turn-right",
    "turn-sharp-left": "turn-sharp-left",
    "turn-sharp-right": "turn-sharp-right",
    "turn-slight-left": "turn-slight-left",
    "turn-slight-right": "turn-slight-right",
}

URL = "http://localhost:8553/v2/route?json={input}"
cache = {}

def prepare_endpoint(point):
    """Return `point` as a dictionary ready to be passed on to the router."""
    if isinstance(point, (list, tuple)):
        return dict(lat=point[1], lon=point[0])
    geocoder = poor.Geocoder("osmscout")
    results = geocoder.geocode(point, dict(limit=1))
    return prepare_endpoint((results[0]["x"], results[0]["y"]))

def route(fm, to, heading, params):
    """Find route and return its properties as a dictionary."""
    fm, to = map(prepare_endpoint, (fm, to))
    if heading is not None:
        fm["heading"] = heading
    language = poor.conf.routers.osmscout.language
    units = "kilometers" if poor.conf.units == "metric" else "miles"
    input = dict(locations=[fm, to],
                 costing=poor.conf.routers.osmscout.type,
                 directions_options=dict(language=language, units=units))

    input = urllib.parse.quote(json.dumps(input))
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    result = poor.http.get_json(url)
    result = poor.AttrDict(result)
    if result.get("API version", "") == "libosmscout V1":
        return parse_result_libosmscout(url, result)
    return parse_result_valhalla(url, result)

def parse_result_libosmscout(url, result):
    """Parse and return route from libosmscout engine."""
    x, y = result.lng, result.lat
    maneuvers = [dict(
        x=float(maneuver.lng),
        y=float(maneuver.lat),
        icon=ICONS_OSMSCOUT.get(maneuver.get("type"), "flag"),
        narrative=maneuver.instruction,
        duration=float(maneuver.time),
        length=float(maneuver.length),
    ) for maneuver in result.maneuvers]
    route = dict(x=x, y=y, maneuvers=maneuvers)
    route["language"] = result.language
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route

def parse_result_valhalla(url, result):
    """Parse and return route from Valhalla engine."""
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
    route["language"] = result.trip.language
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route
