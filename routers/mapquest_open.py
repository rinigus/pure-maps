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

CONF_DEFAULTS = {
    "avoids": [],
    "language": poor.util.get_default_language("en_US"),
    "type": "fastest",
}

ICONS = {
     0: "continue",
     1: "turn-slight-right",
     2: "turn-right",
     3: "turn-sharp-right",
     4: "flag",
     5: "turn-sharp-left",
     6: "turn-left",
     7: "turn-slight-left",
     8: "uturn",
     9: "uturn",
    10: "merge-slight-left",
    11: "merge-slight-right",
    12: "off-ramp-slight-right",
    13: "off-ramp-slight-left",
    14: "off-ramp-slight-right",
    15: "off-ramp-slight-left",
    16: "fork-slight-right",
    17: "fork-slight-left",
    18: "fork-straight",
}

MODE = {
    "fastest": "car",
    "bicycle": "bicycle",
    "pedestrian": "foot"
}

SUPPORTED_LOCALES = [
    "en_US",
    "en_GB",
    "fr_CA",
    "fr_FR",
    "de_DE",
    "es_ES",
    "es_MX",
    "ru_RU",
]

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
       "&manMaps=false"
       "&locale={locale}")

cache = {}

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to the router."""
    if isinstance(point, (list, tuple)):
        return "{:.5f},{:.5f}".format(point[1], point[0])
    geocoder = poor.Geocoder("default")
    results = geocoder.geocode(point, dict(limit=1))
    return prepare_endpoint((results[0]["x"], results[0]["y"]))

def route(fm, to, heading, params):
    """Find route and return its properties as a dictionary."""
    fm, to = map(prepare_endpoint, (fm, to))
    type = poor.conf.routers.mapquest_open.type
    locale = poor.conf.routers.mapquest_open.language
    locale = (locale if locale in SUPPORTED_LOCALES else "en_US")
    url = URL.format(**locals())
    if type == "fastest":
        # Assume all avoids are related to cars.
        for avoid in poor.conf.routers.mapquest_open.avoids:
            url += "&avoids={}".format(urllib.parse.quote_plus(avoid))
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    result = poor.http.get_json(url)
    result = poor.AttrDict(result)
    x, y = poor.util.decode_epl(result.route.shape.shapePoints)
    maneuvers = []
    for leg in result.route.legs:
        maneuvers.extend(leg.maneuvers)
    maneuvers = [dict(
        x=float(maneuver.startPoint.lng),
        y=float(maneuver.startPoint.lat),
        icon=ICONS.get(maneuver.turnType, "flag"),
        narrative=maneuver.narrative,
        duration=float(maneuver.time),
    ) for maneuver in maneuvers]
    if len(maneuvers) > 1:
        maneuvers[ 0]["icon"] = "depart"
        maneuvers[-1]["icon"] = "arrive"
    mode = MODE.get(type,"car")
    route = dict(x=x, y=y, maneuvers=maneuvers, mode=mode)
    route["language"] = locale
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route
