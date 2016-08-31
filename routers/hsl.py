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
Routing using Helsinki Region Transport (HSL) Journey Planner.

http://developer.reittiopas.fi/pages/en/home.php
"""

import poor
import re

COLORS = {  "bus": "#007ac9",
          "ferry": "#00b9e4",
          "metro": "#ff6319",
          "train": "#8c4799",
           "tram": "#00985f",
           "walk": "#888888"}

CONF_DEFAULTS = {"transport_types": [
    "bus", "train", "metro", "tram", "service", "uline", "ferry"],
                 "optimize": "default"}

MODES = {"walk": "walk",
            "1": "bus",
            "2": "tram",
            "3": "bus",
            "4": "bus",
            "5": "bus",
            "6": "metro",
            "7": "ferry",
            "8": "bus",
           "12": "train",
           "21": "bus",
           "22": "bus",
           "23": "bus",
           "24": "bus",
           "25": "bus",
           "36": "bus",
           "37": "bus"}

NARRATIVE = {"00": "Walk towards {arr_name}.",
             "01": "Board {mode} {line} at {dep_name} at {dep_time}.",
             "10": "Get off at {dep_name} and walk towards {arr_name}.",
             "11": "Get off at {dep_name} and transfer to {mode} {line} at {dep_time}."}

URL = ("http://api.reittiopas.fi/hsl/prod/"
       "?request=route"
       "&user=poor-maps"
       "&pass=56388083"
       "&format=json"
       "&epsg_in=4326"
       "&epsg_out=4326"
       "&lang=fi"
       "&from={fm}"
       "&to={to}"
       "&transport_types={transport_types}"
       "&optimize={optimize}"
       "&detail=full"
       "&show=5")

def parse_legs(result):
    """Parse legs from routing result."""
    items = []
    for leg in result["legs"]:
        item = dict(
            mode=MODES[leg["type"]],
            color=COLORS[MODES[leg["type"]]],
            line=parse_line(leg.get("code", "")),
            length=float(leg["length"]),
            dep_name="",
            dep_x=float(leg["locs"][0]["coord"]["x"]),
            dep_y=float(leg["locs"][0]["coord"]["y"]),
            dep_time=parse_time(leg["locs"][0]["depTime"]),
            dep_unix=parse_unix_time(leg["locs"][0]["depTime"]),
            arr_name="",
            arr_x=float(leg["locs"][-1]["coord"]["x"]),
            arr_y=float(leg["locs"][-1]["coord"]["y"]),
            arr_time=parse_time(leg["locs"][-1]["arrTime"]),
            arr_unix=parse_unix_time(leg["locs"][-1]["arrTime"]))

        # Calculate duration separately to match departure and
        # arrival times rounded at one minute accuracy.
        item["duration"] = item["arr_unix"] - item["dep_unix"]
        names = [loc.get("shortName", loc["name"]) for loc in leg["locs"]]
        names = list(filter(None, names))
        with poor.util.silent(IndexError):
            item["dep_name"] = parse_name(names[0])
            item["arr_name"] = parse_name(names[-1])
        # Add stops both used and passed along the leg.
        stops = [loc for loc in leg["locs"] if "code" in loc]
        item["stops_x"] = [float(stop["coord"]["x"]) for stop in stops]
        item["stops_y"] = [float(stop["coord"]["y"]) for stop in stops]
        items.append(item)
    if len(items) > 1:
        # Remove short walking legs, which usually occur
        # when a geocoded endpoint matches a stop.
        items = [x for x in items if x["length"] > 10]
    return items

def parse_line(code):
    """Parse human readable line number from line code."""
    # Journey Planner returns 7-character JORE-codes.
    if not code: return ""
    if code.startswith("31M"):
        # Metro. Use V and M instead of 1 and 2.
        lines = {"1": "V", "2": "M"}
        return lines.get(code[3], code[3])
    if code.startswith(("13", "3")):
        # Metro (?) and trains.
        return code[4]
    # Buses and trams.
    line = code[1:5].strip()
    while len(line) > 1 and line.startswith("0"):
        line = line[1:]
    return line

def parse_maneuvers(route):
    """Parse list of maneuvers from parsed legs of a route."""
    if not route["legs"]: return []
    maneuvers = []
    prev_vehicle = False
    for leg in route["legs"]:
        this_vehicle = (leg["mode"] != "walk")
        key = "{:d}{:d}".format(int(prev_vehicle), int(this_vehicle))
        maneuvers.append(dict(
            x=leg["dep_x"],
            y=leg["dep_y"],
            icon="flag",
            narrative=NARRATIVE[key].format(**leg),
            duration=leg["duration"]*60))

        if this_vehicle:
            # Add stops passed along the way as passive maneuver points.
            for i in range(1, len(leg["stops_x"])-1):
                maneuvers.append(dict(
                    x=leg["stops_x"][i],
                    y=leg["stops_y"][i],
                    passive=True))

        prev_vehicle = this_vehicle
    maneuvers.append(dict(
        x=route["legs"][-1]["arr_x"],
        y=route["legs"][-1]["arr_y"],
        icon="flag",
        narrative="Arrive at your destination.",
        duration=0))

    # Journey Planner returns route shapes and maneuver points
    # that don't always match. To be visually clearer, let's
    # move the maneuver points to closest route nodes.
    for maneuver in maneuvers:
        min_node = 0
        min_dist = 360**2
        for i in range(len(route["x"])):
            dx = maneuver["x"] - route["x"][i]
            dy = maneuver["y"] - route["y"][i]
            dist = dx**2 + dy**2
            if dist < min_dist:
                min_node = i
                min_dist = dist
        maneuver["x"] = route["x"][min_node]
        maneuver["y"] = route["y"][min_node]
    return maneuvers

def parse_name(name):
    """Parse human readable stop name."""
    # Fix inconsistent naming of stops at metro stations.
    return re.sub(r"(\S)\(", r"\1 (", name)

def parse_time(code):
    """Parse human readable time string from time code."""
    # Journey Planner returns YYYYMMDDHHMM.
    time = code[-4:]
    while len(time) > 3 and time.startswith("0"):
        time = time[1:]
    return "{}:{}".format(time[:-2], time[-2:])

def parse_unix_time(code):
    """Parse Unix time (in minutes!) from time code."""
    # Journey Planner returns YYYYMMDDHHMM.
    import time
    return time.mktime(time.strptime(code, "%Y%m%d%H%M"))/60

def parse_x(result):
    """Parse X-coordinates from routing result."""
    coords = []
    for leg in result["legs"]:
        coords.extend(float(point["x"]) for point in leg["shape"])
    return coords

def parse_y(result):
    """Parse Y-coordinates from routing result."""
    coords = []
    for leg in result["legs"]:
        coords.extend(float(point["y"]) for point in leg["shape"])
    return coords

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to the router."""
    if isinstance(point, (list, tuple)):
        return "{:.5f},{:.5f}".format(point[0], point[1])
    results = poor.Geocoder("hsl").geocode(point)
    return prepare_endpoint((results[0]["x"], results[0]["y"]))

def route(fm, to, params):
    """Find routes and return their properties as dictionaries."""
    fm, to = map(prepare_endpoint, (fm, to))
    transport_types = "|".join(poor.conf.routers.hsl.transport_types)
    optimize = poor.conf.routers.hsl.optimize
    url = URL.format(**locals())
    # Date and time parameters are optional.
    for name in set(params) & set(("date", "time", "timetype")):
        url += "&{}={}".format(name, params[name])
    results = poor.http.request_json(url)
    routes = [dict(
        alternative=i+1,
        length=float(result[0]["length"]),
        legs=parse_legs(result[0]),
        x=parse_x(result[0]),
        y=parse_y(result[0]),
    ) for i, result in enumerate(results)]
    for route in routes:
        route["maneuvers"] = parse_maneuvers(route)
        # Calculate duration separately to match departure
        # and arrival times rounded at one minute accuracy.
        dep = route["legs"][ 0]["dep_unix"]
        arr = route["legs"][-1]["arr_unix"]
        route["duration"] = arr - dep
    return routes
