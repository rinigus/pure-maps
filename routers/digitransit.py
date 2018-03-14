# -*- coding: utf-8 -*-

# Copyright (C) 2016 Osmo Salomaa
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
Public transport routing in Finland using Digitransit.

http://digitransit.fi/en/developers/services-and-apis/1-routing-api/
http://dev.hsl.fi/graphql/console/
"""

import datetime
import os
import poor
import re

from poor.i18n import _

GRAPHQL = "{}.graphql".format(os.path.splitext(__file__)[0])
BODY = open(GRAPHQL, "r").read().strip()
BODY = re.sub(r"\{(\s*)$", r"{{\1", BODY, flags=re.MULTILINE)
BODY = re.sub(r"^(\s*)\}", r"\1}}", BODY, flags=re.MULTILINE)

COLORS = {
 "AIRPLANE": "#ed145d",
  "BICYCLE": "#fab00b",
      "BUS": "#007ac9",
    "FERRY": "#00b9e4",
     "RAIL": "#8c4799",
   "SUBWAY": "#ff6319",
     "TRAM": "#00985f",
     "WALK": "#888888",
}

CONF_DEFAULTS = {
    # See digitransit_settings.qml for all possible values.
    "modes": ["AIRPLANE", "BUS", "FERRY", "RAIL", "SUBWAY", "TRAM", "WALK"],
    "optimize": "default",
    "region": "hsl",
}

HEADERS = {"Content-Type": "application/graphql"}

MODE_NAMES = {
 "AIRPLANE": _("airplane"),
  "BICYCLE": _("bicycle"),
      "BUS": _("bus"),
    "FERRY": _("ferry"),
     "RAIL": _("train"),
   "SUBWAY": _("metro"),
     "TRAM": _("tram"),
     "WALK": _("walk"),
}

NARRATIVE = {
    "ww": _("Walk towards {arr_name}."),
    "wb": _("Get a city bike at {dep_name}."),
    "wt": _("Board {mode_name} {line_desc} at {dep_name} at {dep_time}."),
    "wa": _("Walk towards your destination."),
    "bw": _("Leave the city bike at {dep_name} and walk towards {arr_name}."),
    "bt": _("Board {mode_name} {line_desc} at {dep_name} at {dep_time}."),
    "ba": _("Leave the city bike at {dep_name} and walk towards your destination."),
    "tw": _("Get off at {dep_name} and walk towards {arr_name}."),
    "tb": _("Get off at {dep_name} and bike towards {arr_name}."),
    "tt": _("Get off at {dep_name} and transfer to {mode_name} {line_desc} at {dep_time}."),
    "ta": _("Get off at {dep_name} and walk towards your destination."),
}

URL = "http://api.digitransit.fi/routing/v1/routers/{region}/index/graphql"

def merge_bad_legs(legs):
    """Merge any bad legs, modifying legs in-place."""
    # Work around Digitransit sometimes breaking city bike legs
    # into multiple legs, possibly with a short walk between.
    i = 0
    while i < len(legs):
        modes = "-".join(legs[j].mode for j in range(i, len(legs)))
        if modes.startswith(("BICYCLE-BICYCLE", "BICYCLE-WALK-BICYCLE")):
            merge_legs(legs, [i, i + 1])
        else:
            i += 1

def merge_legs(legs, ii):
    """Merge the given legs into one, modifying legs in-place."""
    a, z = ii[0], ii[-1]
    for i in ii[1:]:
        # Accumulate stats and geometry.
        legs[a].length += legs[i].length
        legs[a].duration += legs[i].duration
        legs[a].x += legs[i].x
        legs[a].y += legs[i].y
        legs[a].stops_x += legs[i].stops_x
        legs[a].stops_y += legs[i].stops_y
    # Set arrival based on the last leg.
    legs[a].arr_name = legs[z].arr_name
    legs[a].arr_x = legs[z].arr_x
    legs[a].arr_y = legs[z].arr_y
    legs[a].arr_time = legs[z].arr_time
    legs[a].arr_unix = legs[z].arr_unix
    for i in list(reversed(ii[1:])):
        del legs[i]

def parse_legs(legs):
    """Parse legs from routing result."""
    legs = [poor.AttrDict(
        mode=leg.mode,
        mode_name=MODE_NAMES.get(leg.mode, "BUS"),
        color=COLORS.get(leg.mode, "BUS"),
        agency=parse_agency(leg),
        line=parse_line(leg),
        line_desc=parse_line_description(leg),
        length=float(leg.distance),
        duration=float(leg.duration),
        real_time=leg.realTime,
        dep_name=leg["from"].name,
        dep_x=float(leg["from"].lon),
        dep_y=float(leg["from"].lat),
        dep_time=parse_time(leg.startTime),
        dep_unix=float(leg.startTime)/1000,
        arr_name=leg.to.name,
        arr_x=float(leg.to.lon),
        arr_y=float(leg.to.lat),
        arr_time=parse_time(leg.endTime),
        arr_unix=float(leg.endTime)/1000,
        x=poor.util.decode_epl(leg.legGeometry.points, precision=5)[0],
        y=poor.util.decode_epl(leg.legGeometry.points, precision=5)[1],
        stops_x=[float(x.lon) for x in leg.intermediateStops or []],
        stops_y=[float(x.lat) for x in leg.intermediateStops or []],
    ) for leg in legs]
    merge_bad_legs(legs)
    return legs

def parse_agency(leg):
    """Parse agency name from `leg`."""
    if not leg.route: return ""
    return leg.route.agency.name

def parse_line(leg):
    """Parse line number from `leg`."""
    # We need some kind of a short symbol for city bikes
    # to be shown in a column of public transport line numbers.
    if leg.mode == "BICYCLE": return "CB"
    if not leg.route: return ""
    # Return the mode for legs without a short name,
    # e.g. Helsinki metro and long distance buses.
    short_name = leg.route.get("shortName", "")
    mode_name = MODE_NAMES.get(leg.mode, "").capitalize()
    return short_name or mode_name

def parse_line_description(leg):
    """Parse line description from `leg`."""
    if not leg.route: return ""
    short_name = leg.route.get("shortName", "")
    long_name = leg.route.get("longName", "")
    agency = leg.route.agency.get("name", "")
    return short_name or long_name or agency

def parse_maneuvers(route):
    """Parse list of maneuvers from the legs of `route`."""
    if not route.legs: return []
    maneuvers = []
    prev_mode = "w"
    modes = dict(WALK="w", BICYCLE="b")
    for i, leg in enumerate(route.legs):
        this_mode = modes.get(leg.mode, "t")
        key = prev_mode + this_mode
        # Handle the last leg differently since OpenTripPlanner
        # gives "Destination" as the destination name.
        if i == len(route.legs) - 1:
            key = key[0] + "a"
        narrative = NARRATIVE[key].format(**leg)
        narrative = re.sub(r"\.\.+$", ".", narrative)
        maneuvers.append(poor.AttrDict(
            x=leg.dep_x,
            y=leg.dep_y,
            icon="flag",
            narrative=narrative,
            duration=leg.duration))
        if this_mode == "t":
            # Add intermediate stops as passive maneuver points.
            maneuvers.extend([poor.AttrDict(
                x=leg.stops_x[i],
                y=leg.stops_y[i],
                passive=True,
            ) for i in range(len(leg.stops_x))])
        prev_mode = this_mode
    maneuvers.append(poor.AttrDict(
        x=route.legs[-1].arr_x,
        y=route.legs[-1].arr_y,
        icon="flag",
        narrative=_("Arrive at your destination."),
        duration=0))
    # For clarity, move stops to the nearest point
    # on the route polyline.
    for maneuver in maneuvers:
        i = poor.util.find_closest(route.x, route.y, maneuver.x, maneuver.y)
        maneuver.x = route.x[i]
        maneuver.y = route.y[i]
    return maneuvers

def parse_time(time):
    """Parse human readable time string from `time`."""
    time = datetime.datetime.fromtimestamp(time/1000)
    return re.sub("^0", "", time.strftime("%H:%M"))

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to the router."""
    if isinstance(point, (list, tuple)):
        return "{{lat: {:.6f}, lon: {:.6f}}}".format(point[1], point[0])
    geocoder = poor.Geocoder("digitransit")
    # XXX: limit=1 sometimes returns no results!?
    results = geocoder.geocode(point, dict(limit=3))
    return prepare_endpoint((results[0]["x"], results[0]["y"]))

def route(fm, to, heading, params):
    """Find routes and return their properties as dictionaries."""
    fm, to = map(prepare_endpoint, (fm, to))
    region = poor.conf.routers.digitransit.region
    url = URL.format(**locals())
    modes = ",".join(poor.conf.routers.digitransit.modes)
    # Add optional parameters, None if missing.
    date = params.get("date", None)
    time = params.get("time", None)
    if date is None and time is not None:
        date = datetime.date.today().isoformat()
    arrive_by = params.get("arrive_by", None)
    optimize = poor.conf.routers.digitransit.optimize
    transfer_penalty = (600 if optimize == "least-transfers" else None)
    walk_reluctance = (10 if optimize == "least-walking" else None)
    body = BODY.format(**locals())
    body = re.sub(r"^.*\bNone\b.*$", "", body, flags=re.MULTILINE)
    body = "\n".join(x for x in body.splitlines() if x)
    result = poor.http.post_json(url, body, headers=HEADERS)
    result = poor.AttrDict(result)
    itineraries = result.data.plan.itineraries
    routes = [poor.AttrDict(
        alternative=i+1,
        length=sum(x.distance for x in itinerary.legs),
        duration=float(itinerary.duration),
        legs=parse_legs(itinerary.legs),
    ) for i, itinerary in enumerate(itineraries)]
    for route in routes:
        route.x = []
        route.y = []
        for leg in route.legs:
            route.x.extend(leg.pop("x"))
            route.y.extend(leg.pop("y"))
        route.maneuvers = parse_maneuvers(route)
        route.mode = "transit"
    return routes
