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

URL = ("http://router.project-osrm.org/viaroute"
       "?loc={fm}"
       "&loc={to}"
       "&output=json"
       "&instructions=true"
       "&alt=false")

checksum = None
hints = {}

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
                      ) for maneuver in result["route_instructions"]]

    return {"x": x, "y": y, "maneuvers": maneuvers}
