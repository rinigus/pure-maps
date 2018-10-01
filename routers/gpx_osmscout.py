# -*- coding: utf-8 -*-

# Copyright (C) 2018 Rinigus
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

import json
import poor

CONF_DEFAULTS = {
    "file": "",
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

MODE = {
    "auto": "car",
    "bicycle": "bicycle",
    "bus": "car",
    "hov": "car",
    "motorcycle": "car",
    "motor_scooter": "car",
    "pedestrian": "foot"
}

URL = "http://localhost:8553/v2/trace_route"

def route(fm, to, heading, params):
    """Find route and return its properties as a dictionary."""
    fname = poor.conf.routers.gpx_osmscout.file
    language = poor.conf.routers.gpx_osmscout.language
    units = "kilometers" if poor.conf.units == "metric" else "miles"
    ctype = poor.conf.routers.gpx_osmscout.type
    x, y = poor.util.read_gpx(fname)
    shape = [dict(lat=y[i], lon=x[i]) for i in range(len(x))]
    input = dict(shape=shape,
                 shape_match="map_snap",
                 costing=ctype,
                 directions_options=dict(language=language, units=units))
    input = json.dumps({'json': json.dumps(input)})
    result = poor.http.post_json(URL, input)
    result = poor.AttrDict(result)
    mode = MODE.get(ctype,"car")
    return parse_result_valhalla(result, mode)

def parse_exit(maneuver, key):
    if "sign" not in maneuver or key not in maneuver["sign"]:
        return None
    e = maneuver["sign"][key]
    return [i.get("text", "") for i in e]

def parse_result_valhalla(result, mode):
    """Parse and return route from Valhalla engine."""
    legs = result.trip.legs[0]
    x, y = poor.util.decode_epl(legs.shape, precision=6)
    maneuvers = [dict(
        x=float(x[maneuver.begin_shape_index]),
        y=float(y[maneuver.begin_shape_index]),
        icon=ICONS.get(maneuver.type, "flag"),
        narrative=maneuver.instruction,
        sign=dict(
            exit_branch=parse_exit(maneuver, "exit_branch_elements"),
            exit_name=parse_exit(maneuver, "exit_name_elements"),
            exit_number=parse_exit(maneuver, "exit_number_elements"),
            exit_toward=parse_exit(maneuver, "exit_toward_elements")
        ),
        street=maneuver.get("begin_street_names", maneuver.get("street_names", None)),
        arrive_instruction=maneuver.get("arrive_instruction", None),
        depart_instruction=maneuver.get("depart_instruction", None),
        travel_type=maneuver.get("travel_type", None),
        verbal_alert=maneuver.get("verbal_transition_alert_instruction", None),
        verbal_pre=maneuver.get("verbal_pre_transition_instruction", None),
        verbal_post=maneuver.get("verbal_post_transition_instruction", None),
        duration=float(maneuver.time),
    ) for maneuver in legs.maneuvers]
    route = dict(x=x, y=y, maneuvers=maneuvers, mode=mode)
    route["language"] = result.trip.language
    return route
