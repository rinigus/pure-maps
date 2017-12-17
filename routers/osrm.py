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
Routing using OSRM.

http://project-osrm.org/
https://github.com/Project-OSRM/osrm-backend/blob/master/docs/http.md
"""

import copy
import glob
import os
import poor
import re

ICONS = []

# XXX: The following list of narratives for maneuvers is far from complete as
# per the combinations of types and modifiers and combined with the clean-ups
# in parse_narrative is very untranslatable. If we use OSRM in production,
# these issues should be fixed to be able to present a proper narrative.

NARRATIVE = {
            "turn": "Turn {modifier} onto {street}.",
   "turn-straight": "Continue straight along {street}.",
      "turn-uturn": "Make a U-turn.",
        "new-name": "Continue along {street}.",
          "depart": "Head out {modifier} along {street}.",
          "arrive": "Arrive at your destination.",
     "arrive-left": "Your destination is on the left.",
    "arrive-right": "Your destination is on the right.",
           "merge": "Merge {modifier} onto {street}.",
         "on-ramp": "Take the ramp {modifier} onto {street}.",
        "off-ramp": "Take the ramp {modifier} onto {street}.",
            "fork": "Keep {modifier} in the fork ahead.",
     "end-of-road": "Turn {modifier} onto {street}.",
        "use-lane": "Use the lane to go {modifier}.",
        "continue": "Continue {modifier} along {street}.",
  "continue-uturn": "Make a U-turn.",
      "roundabout": "Take the {exit} exit in the roundabout.",
          "rotary": "Take the {exit} exit in the roundabout.",
 "roundabout-turn": "Turn {modifier} in the roundabout.",
}

URL = "http://router.project-osrm.org/route/v1/car/{fm};{to}?steps=true&overview=full"
cache = {}

def init_icons():
    """Initialize the global list of maneuver icons."""
    # OSRM's maneuver types and modifiers match Mapbox directions
    # icons, which are included under qml/icons/navigation.
    directory = os.path.join(poor.DATA_DIR, "qml", "icons", "navigation")
    icons = glob.glob("{}/*.svg".format(directory))
    icons = list(map(os.path.basename, icons))
    icons = [x.replace(".svg", "") for x in icons]
    ICONS.extend(icons)

def get_maneuver_components(maneuver):
    """Return type, modififer, name from `maneuver`."""
    type = maneuver.get("type", "").replace(" ", "-")
    modifier = maneuver.get("modifier", "").replace(" ", "-")
    name = "{}-{}".format(type, modifier)
    return type, modifier, name

def parse_icon(maneuver):
    """Return name of maneuver icon to use."""
    if not ICONS: init_icons()
    type, modifier, name = get_maneuver_components(maneuver)
    if type == "roundabout":
        # XXX: Roundabout modifiers seem bonkers,
        # let's use exit numbers in the narrative instead.
        name = "roundabout"
    if name in ICONS: return name
    if type in ICONS: return type
    if type != "turn":
        # "Types unknown to the client should be handled like the turn type."
        return parse_icon(dict(type="turn", modifier=modifier))
    return "flag"

def parse_narrative(maneuver, street):
    """Return narrative to display for `maneuver`."""
    type, modifier, name = get_maneuver_components(maneuver)
    exit = str(maneuver.get("exit", ""))
    exit = re.sub(r"1$", "1st", exit)
    exit = re.sub(r"2$", "2nd", exit)
    exit = re.sub(r"3$", "3rd", exit)
    exit = re.sub(r"4$", "4th", exit)
    exit = re.sub(r"5$", "5th", exit)
    exit = re.sub(r"6$", "6th", exit)
    exit = re.sub(r"7$", "7th", exit)
    exit = re.sub(r"8$", "8th", exit)
    exit = re.sub(r"9$", "9th", exit)
    narrative = parse_narrative_raw(maneuver)
    narrative = narrative.format(**locals())
    # Clean up narrative since modifier or street might be blank.
    narrative = re.sub(" (along|onto|to go) +.$", ".", narrative)
    narrative = re.sub("  +", " ", narrative)
    return narrative

def parse_narrative_raw(maneuver):
    """Return narrative to display for `maneuver`."""
    type, modifier, name = get_maneuver_components(maneuver)
    if name in NARRATIVE: return NARRATIVE[name]
    if type in NARRATIVE: return NARRATIVE[type]
    if type != "turn":
        # "Types unknown to the client should be handled like the turn type."
        return parse_narrative_raw(dict(type="turn", modifier=modifier))
    return ""

def prepare_endpoint(point):
    """Return `point` as a string ready to be passed on to the router."""
    if isinstance(point, (list, tuple)):
        return "{:.5f},{:.5f}".format(point[0], point[1])
    geocoder = poor.Geocoder("default")
    results = geocoder.geocode(point, dict(limit=1))
    return prepare_endpoint((results[0]["x"], results[0]["y"]))

def route(fm, to, heading, params):
    """Find route and return its properties as a dictionary."""
    fm, to = map(prepare_endpoint, (fm, to))
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    result = poor.http.get_json(url)["routes"][0]
    result = poor.AttrDict(result)
    x, y = poor.util.decode_epl(result.geometry)
    maneuvers = [dict(
        x=float(step.maneuver.location[0]),
        y=float(step.maneuver.location[1]),
        icon=parse_icon(step.maneuver),
        narrative=parse_narrative(step.maneuver, step.get("name", "")),
        duration=float(step.duration),
    ) for step in result.legs[0].steps]
    route = dict(x=x, y=y, maneuvers=maneuvers, mode="car")
    route["attribution"] = poor.util.get_routing_attribution("OSRM")
    route["language"] = "en_US"
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route
