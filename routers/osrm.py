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
Routing using OSRM.

http://project-osrm.org/
http://github.com/DennisOSRM/Project-OSRM/wiki/Server-api
"""

import json
import poor

NARRATIVE = { 1: "{turn} along {street}.",
              2: "{turn} onto {street}.",
              3: "{turn} onto {street}.",
              4: "{turn} onto {street}.",
              5: "{turn}.",
              6: "{turn} onto {street}.",
              7: "{turn} onto {street}.",
              8: "{turn} onto {street}.",
              9: "{turn}.",
             10: "{turn}.",
             11: "{turn}.",
             12: "{turn} onto {}.",
             13: "{turn}.",
             14: "{turn}.",
             15: "{turn}."}

TURNS = { 1: "Go straight",
          2: "Turn slightly to the right",
          3: "Turn right",
          4: "Turn sharp to the right",
          5: "Make a U-turn",
          6: "Turn sharp to the left",
          7: "Turn left",
          8: "Turn slightly to the left",
          9: "Reach your via point",
         10: "Head on",
         11: "Enter the roundabout",
         12: "Leave the roundabout",
         13: "Stay on the roundabout",
         14: "Start at the end of the street",
         15: "Arrive at your destination"}

# XXX: Use z=14 as a workaround to avoid OSRM not finding a route at all.
# http://lists.openstreetmap.org/pipermail/osrm-talk/2014-June/000588.html

URL = ("http://router.project-osrm.org/viaroute"
       "?loc={fm}"
       "&loc={to}"
       "&output=json"
       "&instructions=true"
       "&alt=false"
       "&z=14")

checksum = None
hints = {}

def parse_narrative(maneuver):
    """Parse narrative from `maneuver`."""
    try:
        turn = TURNS[int(maneuver[0])]
        narrative = NARRATIVE[int(maneuver[0])]
    except (ValueError, KeyError):
        return ""
    street = maneuver[1]
    if street:
        return narrative.format(**locals())
    return "{}.".format(turn)

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to the router."""
    # OSRM requires coordinates, let's geocode using Nominatim.
    if isinstance(point, str):
        geocoder = poor.Geocoder("nominatim")
        results = geocoder.geocode(point)
        point = (results[0]["x"], results[0]["y"])
    point = "{:.6f},{:.6f}".format(point[1], point[0])
    return (point, ("{}&hint={}".format(point, hints[point])
                    if point in hints else point))

def route(fm, to, params):
    """Find route and return its properties as a dictionary."""
    global checksum
    fm_real, fm = prepare_endpoint(fm)
    to_real, to = prepare_endpoint(to)
    url = URL.format(**locals())
    if checksum is not None:
        url += "&checksum={}".format(checksum)
    result = json.loads(poor.util.request_url(url, "utf_8"))
    with poor.util.silent(Exception):
        checksum = str(result["hint_data"]["checksum"])
        hints[fm_real] = str(result["hint_data"]["locations"][0])
        hints[to_real] = str(result["hint_data"]["locations"][1])
    route = result["route_geometry"]
    x, y = poor.util.decode_epl(route, precision=6)
    maneuvers = [dict(x=x[int(maneuver[3])],
                      y=y[int(maneuver[3])],
                      narrative=parse_narrative(maneuver),
                      ) for maneuver in result["route_instructions"]]

    return {"x": x, "y": y, "maneuvers": maneuvers}
