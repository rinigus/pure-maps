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
import json
import poor

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

URL = ("http://www.mapquestapi.com/directions/v2/{service}"
       "?key=" + poor.key.get("MAPQUEST_KEY") )

cache = {}

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to the router."""
    if isinstance(point, (list, tuple)):
        return "{:.5f},{:.5f}".format(point[1], point[0])
    if isinstance(point, dict):
        return "{:.5f},{:.5f}".format(point["y"], point["x"])
    geocoder = poor.Geocoder("default")
    results = geocoder.geocode(point, params=dict(limit=1))
    return prepare_endpoint((results[0]["x"], results[0]["y"]))

def route(locations, params):
    """Find route and return its properties as a dictionary."""
    loc = list(map(prepare_endpoint, locations))
    heading = params.get('heading', None)
    optimized = params.get('optimized', False) if len(loc) > 3 else False
    type = poor.conf.routers.mapquest_open.type
    locale = poor.conf.routers.mapquest_open.language
    locale = (locale if locale in SUPPORTED_LOCALES else "en_US")
    service = "optimizedroute" if optimized else "route"
    url = URL.format(**locals())
    options = dict(ambiguities="ignore",
                   unit="k",
                   routeType=type,
                   doReverseGeocode=False,
                   shapeFormat="cmp",
                   generalize=5,
                   manMaps=False,
                   locale=locale)
    if type == "fastest":
        # Assume all avoids are related to cars.
        options["avoids"] = poor.conf.routers.mapquest_open.avoids
    input = dict(locations=loc, options=options)
    input = json.dumps(input)
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url + input])
    result = poor.http.post_json(url, input)
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
        street=maneuver.get("streets", None),
    ) for maneuver in maneuvers]
    if len(maneuvers) > 1:
        maneuvers[ 0]["icon"] = "depart"
        maneuvers[-1]["icon"] = "arrive"
    loc_index = result.route.shape.legIndexes
    loc_index[-1] -= 1
    mode = MODE.get(type,"car")
    route = dict(x=x, y=y,
                 locations=[locations[i] for i in result.route.locationSequence],
                 location_indexes=loc_index,
                 maneuvers=maneuvers, mode=mode, optimized=optimized)
    route["language"] = locale
    if route and route["x"]:
        cache[url + input] = copy.deepcopy(route)
    return route
