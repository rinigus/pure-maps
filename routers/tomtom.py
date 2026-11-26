# -*- coding: utf-8 -*-

# Copyright (C) 2026 Boris Solodki
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
Routing using TomTom Routing API, with live traffic.

https://developer.tomtom.com/routing-api/documentation
"""

import copy
import poor
import urllib.parse

from poor.i18n import _
from poor.i18n import __
from poor.util import format_distance

CONF_DEFAULTS = {
    "avoid_dirt": 0,
    "avoid_ferry": 0,
    "avoid_highway": 0,
    "avoid_toll": 0,
    "language": poor.util.get_default_locale("en_GB").replace("_", "-"),
    "shorter": 0,
    "traffic": 1,
    "type": "car",
}

MODE = {
    "car": "car",
    "motorcycle": "car",
    "bicycle": "bicycle",
    "pedestrian": "foot",
}

URL = ("https://api.tomtom.com/routing/1/calculateRoute/{points}/json"
       "?key={key}"
       "&travelMode={travel_mode}"
       "&routeType={route_type}"
       "&traffic={traffic}"
       "&computeTravelTimeFor=all"
       "&instructionsType=text"
       "&language={lang}"
       "&maxAlternatives=0")

ICONS = {
    "ARRIVE": "arrive",
    "ARRIVE_LEFT": "arrive",
    "ARRIVE_RIGHT": "arrive",
    "DEPART": "depart",
    "STRAIGHT": "continue",
    "FOLLOW": "continue",
    "KEEP_RIGHT": "fork-slight-right",
    "KEEP_LEFT": "fork-slight-left",
    "BEAR_RIGHT": "turn-slight-right",
    "BEAR_LEFT": "turn-slight-left",
    "TURN_RIGHT": "turn-right",
    "TURN_LEFT": "turn-left",
    "SHARP_RIGHT": "turn-sharp-right",
    "SHARP_LEFT": "turn-sharp-left",
    "MAKE_UTURN": "uturn",
    "TRY_MAKE_UTURN": "uturn",
    "ENTER_MOTORWAY": "continue",
    "ENTER_FREEWAY": "continue",
    "ENTER_HIGHWAY": "continue",
    "ENTRANCE_RAMP": "continue",
    "MOTORWAY_EXIT_LEFT": "fork-slight-left",
    "MOTORWAY_EXIT_RIGHT": "fork-slight-right",
    "TAKE_FERRY": "ferry",
    "ROUNDABOUT_CROSS": "roundabout",
    "ROUNDABOUT_RIGHT": "roundabout",
    "ROUNDABOUT_LEFT": "roundabout",
    "ROUNDABOUT_BACK": "roundabout",
    "SWITCH_PARALLEL_ROAD": "continue",
    "SWITCH_MAIN_ROAD": "continue",
    "WAYPOINT_LEFT": "flag",
    "WAYPOINT_RIGHT": "flag",
    "WAYPOINT_REACHED": "flag",
}

cache = {}

def prepare_endpoint(point):
    """Return `point` as a (lat, lon) tuple."""
    if isinstance(point, (list, tuple)):
        return (point[1], point[0])
    if isinstance(point, dict):
        return (point["y"], point["x"])
    geocoder = poor.Geocoder("default")
    results = geocoder.geocode(point, params=dict(limit=1))
    return (results[0]["y"], results[0]["x"])

def route(locations, params):
    """Find route and return its properties as a dictionary."""
    # read the key on every call to follow changes made in preferences
    key = poor.key.get("TOMTOM_KEY")
    loc = list(map(prepare_endpoint, locations))
    if len(loc) < 2: return None
    conf = poor.conf.routers.tomtom
    travel_mode = conf.type if conf.type in MODE else "car"
    motorized = travel_mode in ("car", "motorcycle")
    traffic = "true" if (conf.traffic and motorized) else "false"
    route_type = "shortest" if conf.shorter else "fastest"
    lang = conf.language
    points = ":".join("{:.6f},{:.6f}".format(*p) for p in loc)
    url = URL.format(points=urllib.parse.quote(points, safe=",:"),
                     key="{key}",
                     travel_mode=travel_mode,
                     route_type=route_type,
                     traffic=traffic,
                     lang=urllib.parse.quote(lang))
    if conf.avoid_toll: url += "&avoid=tollRoads"
    if conf.avoid_highway: url += "&avoid=motorways"
    if conf.avoid_ferry: url += "&avoid=ferries"
    if conf.avoid_dirt: url += "&avoid=unpavedRoads"
    heading = params.get("heading", None)
    if heading is not None:
        url += "&vehicleHeading={:d}".format(int(heading) % 360)
    # url without the key is used for caching and never holds the secret
    if traffic == "false":
        with poor.util.silent(KeyError):
            return copy.deepcopy(cache[url])
    try:
        result = poor.http.get_json(url.replace("{key}", urllib.parse.quote(key)))
    except Exception as e:
        # do not let the key leak into logs through the failed URL
        reason = str(e).replace(key, "***")
        print("TomTom routing failed:", reason)
        return dict(error=True,
                    message=_("TomTom request failed, check API key, quota and connection"))
    result = poor.AttrDict(result)
    if "routes" not in result or not result.routes:
        message = ""
        if "detailedError" in result:
            message = result.detailedError.get("message", "")
        elif "error" in result:
            message = result.error.get("description", "")
        return dict(error=True, message="TomTom: {}".format(message)) if message else dict(error=True)
    route = parse_result(locations, result.routes[0], MODE[travel_mode], lang)
    if traffic == "false" and route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route

def parse_result(locations, result, mode, lang):
    """Parse and return route."""
    language = lang.replace("-", "_")
    X, Y, LocPointInd = [], [], [0]
    for leg in result.legs:
        for p in leg.points:
            X.append(float(p.longitude))
            Y.append(float(p.latitude))
        LocPointInd.append(len(X) - 1)
    # legs are split at waypoints; be defensive if the counts differ
    if len(LocPointInd) != len(locations):
        LocPointInd = [0] + [-1] * (len(locations) - 2) + [len(X) - 1]
    instructions = []
    if "guidance" in result and "instructions" in result.guidance:
        instructions = result.guidance.instructions
    maneuvers = []
    for i, ins in enumerate(instructions):
        if i + 1 < len(instructions):
            nxt = instructions[i + 1]
            duration = nxt.get("travelTimeInSeconds", 0) - ins.get("travelTimeInSeconds", 0)
            length = nxt.get("routeOffsetInMeters", 0) - ins.get("routeOffsetInMeters", 0)
        else:
            duration, length = 0, 0
        maneuvers.append(process_maneuver(ins, max(0, duration), length, language))
    if not maneuvers and X:
        # no guidance available, e.g. for some travel modes
        total = float(result.summary.get("travelTimeInSeconds", 0))
        maneuvers = [
            dict(x=X[0], y=Y[0], icon="depart", duration=total,
                 narrative=__("Start navigation", language)),
            dict(x=X[-1], y=Y[-1], icon="arrive", duration=0,
                 narrative=__("Arrive at your destination", language)),
        ]
    route = dict(x=X, y=Y,
                 locations=locations,
                 location_indexes=LocPointInd,
                 maneuvers=maneuvers,
                 mode=mode,
                 language=language)
    summary = result.summary
    delay = 0
    if "noTrafficTravelTimeInSeconds" in summary:
        delay = summary.travelTimeInSeconds - summary.noTrafficTravelTimeInSeconds
    delay = max(delay, summary.get("trafficDelayInSeconds", 0))
    if delay >= 1: route["traffic"] = delay
    return route

def process_maneuver(ins, duration, length, language):
    """Return Pure Maps maneuver from TomTom instruction `ins`."""
    code = ins.get("maneuver", "")
    side = ins.get("drivingSide", "RIGHT")
    icon = ICONS.get(code, None)
    if code == "TAKE_EXIT":
        icon = "fork-slight-left" if side == "LEFT" else "fork-slight-right"
    if icon is None:
        print("TomTom router: unknown maneuver", code)
        icon = "flag"
    narrative = ins.get("message", None) or code.replace("_", " ").capitalize()
    street = []
    if ins.get("street", None): street.append(ins.street)
    street.extend(ins.get("roadNumbers", None) or [])
    exit_number = ins.get("exitNumber", None)
    signpost = ins.get("signpostText", None)
    roundabout_exit_count = None
    if code.startswith("ROUNDABOUT"):
        roundabout_exit_count = ins.get("roundaboutExitNumber", None)
    verbal_post = None
    if length > 100 and not code.startswith("ARRIVE"):
        distance = format_distance(length, short=False, lang=language)
        verbal_post = __("Continue for {distance}", language).format(distance=distance)
    return dict(
        x=float(ins.point.longitude),
        y=float(ins.point.latitude),
        duration=float(duration),
        icon=icon,
        narrative=narrative,
        sign=dict(
            exit_number=[str(exit_number)] if exit_number else None,
            exit_toward=[signpost] if signpost else None,
        ),
        street=street or None,
        roundabout_exit_count=roundabout_exit_count,
        verbal_alert=narrative,
        verbal_pre=narrative,
        verbal_post=verbal_post,
    )
