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

import json
import poor
import urllib.parse

URL = ("http://open.mapquestapi.com/directions/v2/route"
       "?key=Fmjtd%7Cluur2quy2h%2Cbn%3Do5-9aasg4"
       "&ambiguities=ignore"
       "&from={fm}"
       "&to={to}"
       "&unit=k"
       "&type={type}"
       "&doReverseGeocode=false"
       "&fullShape=true"
       "&manMaps=false")

def route(fm, to):
    """Find route and return its properties as a dictionary."""
    poor.conf.register_router("mapquest_open", {"type": "fastest"})
    if isinstance(fm, (list, tuple)):
        fm = "%.6f,%.6f".format(fm[1], fm[0])
    if isinstance(to, (list, tuple)):
        to = "%.6f,%.6f".format(to[1], to[0])
    fm = urllib.parse.quote_plus(fm)
    to = urllib.parse.quote_plus(to)
    type = poor.conf.routers.mapquest_open.type
    url = URL.format(**locals())
    result = json.loads(poor.util.request_url(url, "utf_8"))
    r = result["route"]
    return {"x": list(map(float, r["shape"]["shapePoints"][1::2])),
            "y": list(map(float, r["shape"]["shapePoints"][0::2]))}
