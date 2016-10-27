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
Routing using OSM Scout Server.

https://github.com/rinigus/osmscout-server
"""

import copy
import poor
import urllib.parse

CONF_DEFAULTS = {"type": "car"}

ICONS = {
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

URL = "http://localhost:8553/v1/route?type={type}"
cache = {}

def render_endpoint(i, point):
    """Return URL component for given endpoint."""
    if isinstance(point, (list, tuple)):
        return ("&p[{i:d}][lng]={x:.6f}&p[{i:d}][lat]={y:.6f}"
                .format(i=i, x=point[0], y=point[1]))
    point = urllib.parse.quote_plus(point)
    return "&p[{i:d}][search]={point}".format(i=i, point=point)

def route(fm, to, params):
    """Find route and return its properties as a dictionary."""
    type = poor.conf.routers.osmscout.type
    url = URL.format(**locals())
    for i, point in enumerate((fm, to)):
        url += render_endpoint(i, point)
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
    ) for maneuver in result["maneuvers"]]
    route = dict(x=x, y=y, maneuvers=maneuvers)
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route
