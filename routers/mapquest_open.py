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

CONF_DEFAULTS = {"type": "fastest"}

URL = ("http://open.mapquestapi.com/directions/v2/route"
       "?key=Fmjtd%7Cluur2quy2h%2Cbn%3Do5-9aasg4"
       "&ambiguities=ignore"
       "&from={fm}"
       "&to={to}"
       "&unit=k"
       "&routeType={type}"
       "&doReverseGeocode=false"
       "&shapeFormat=cmp"
       "&generalize=1"
       "&manMaps=false")

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to MapQuest."""
    # MapQuest Open accepts both addresses and coordinates as endpoints,
    # but it doesn't seem to understand as many addresses as Nominatim.
    # Hence, let's use Nominatim and feed coordinates to MapQuest.
    if isinstance(point, str):
        geocoder = poor.Geocoder("mapquest_nominatim")
        results = geocoder.geocode(point)
        with poor.util.silent(LookupError):
            point = (results[0]["x"], results[0]["y"])
    if isinstance(point, (list, tuple)):
        point = "{:.6f},{:.6f}".format(point[1], point[0])
    return urllib.parse.quote_plus(point)

def route(fm, to):
    """Find route and return its properties as a dictionary."""
    fm = prepare_endpoint(fm)
    to = prepare_endpoint(to)
    type = poor.conf.routers.mapquest_open.type
    url = URL.format(**locals())
    result = json.loads(poor.util.request_url(url, "utf_8"))
    polyline = result["route"]["shape"]["shapePoints"]
    x, y = poor.util.decode_epl(polyline)
    return {"x": x, "y": y}
