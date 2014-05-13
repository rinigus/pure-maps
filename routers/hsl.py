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

import json
import poor

COLORS = {  "bus": "#007AC9",
          "ferry": "#00B9E4",
          "metro": "#FF6319",
          "train": "#2DBE2C",
           "tram": "#00985F",
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
        item = dict(mode=MODES.get(leg["type"]),
                    line=parse_line(leg.get("code", "")),
                    length=float(leg["length"]),
                    dep_time=parse_time(leg["locs"][0]["depTime"]),
                    dep_unix=parse_unix_time(leg["locs"][0]["depTime"]),
                    arr_time=parse_time(leg["locs"][-1]["arrTime"]),
                    arr_unix=parse_unix_time(leg["locs"][-1]["arrTime"]),
                    dep_name="",
                    arr_name="")

        # Calculate duration separately to match departure and
        # arrival times rounded at one minute accuracy.
        item["duration"] = item["arr_unix"] - item["dep_unix"]
        item["color"] = COLORS[item["mode"]]
        names = [loc["name"] for loc in leg["locs"]]
        names = list(filter(None, names))
        if names:
            item["dep_name"] = names[0]
            item["arr_name"] = names[-1]
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
    if code.startswith(("13", "3")):
        # Metro and trains.
        return code[4]
    # Buses and trams.
    line = code[1:5].strip()
    while len(line) > 1 and line.startswith("0"):
        line = line[1:]
    return line

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
        coords.extend(point["x"] for point in leg["shape"])
    return coords

def parse_y(result):
    """Parse Y-coordinates from routing result."""
    coords = []
    for leg in result["legs"]:
        coords.extend(point["y"] for point in leg["shape"])
    return coords

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to the router."""
    # Journey Planner requires coordinates, use corresponding geocoder.
    if isinstance(point, str):
        geocoder = poor.Geocoder("hsl")
        results = geocoder.geocode(point, nmax=1)
        point = (results[0]["x"], results[0]["y"])
    return "{:.6f},{:.6f}".format(point[0], point[1])

def route(fm, to, params):
    """Find routes and return their properties as dictionaries."""
    fm = prepare_endpoint(fm)
    to = prepare_endpoint(to)
    transport_types = "|".join(poor.conf.routers.hsl.transport_types)
    optimize = poor.conf.routers.hsl.optimize
    url = URL.format(**locals())
    # Date and time parameters are optional.
    for name in set(params) & set(("date", "time", "timetype")):
        url += "&{}={}".format(name, params[name])
    results = json.loads(poor.util.request_url(url, "utf_8"))
    routes = [dict(alternative=i+1,
                   length=float(result[0]["length"]),
                   legs=parse_legs(result[0]),
                   x=parse_x(result[0]),
                   y=parse_y(result[0]),
                   ) for i, result in enumerate(results)]

    for route in routes:
        # Calculate duration separately to match departure and
        # arrival times rounded at one minute accuracy.
        dep = route["legs"][0]["dep_unix"]
        arr = route["legs"][len(route["legs"])-1]["arr_unix"]
        route["duration"] = arr - dep
    return routes
