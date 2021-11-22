# -*- coding: utf-8 -*-

# Copyright (C) 2021 Rinigus
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
Routing using HERE.

https://developer.here.com
"""


# https://developer.here.com/documentation/routing-api/api-reference-swagger.html
#
# Maneuvers are described under "actions" with the drop-down list
# opening specific options.  Also, see Android SDK description for
# public enum ManeuverAction is helpful.


import copy
import poor
import poor.flexpolyline
from poor.i18n import __
from poor.util import calculate_distance, format_distance

CONF_DEFAULTS = {
    "avoid_car_train": 0,
    "avoid_difficult_turn": 0,
    "avoid_dirt": 0,
    "avoid_highway": 0,
    "avoid_ferry": 0,
    "avoid_seasonal_closure": 0,
    "avoid_toll": 0,
    "avoid_tunnel": 0,
    "language": poor.util.get_default_language("en-US"),
    "shorter": 0,
    "type": "car",
}

MODE = {
    "car": "car",
    "bicycle": "bicycle",
    "bus": "car",
    "taxi": "car",
    "scooter": "car",
    "pedestrian": "foot",
}

MODEOPTIONS = {
    "auto": ["use_ferry", "use_highways", "use_tolls"],
    "bicycle": ["bicycle_type", "use_ferry", "use_hills", "use_roads"],
    "bus": ["use_ferry", "use_highways", "use_tolls"],
    "hov": ["use_ferry", "use_highways", "use_tolls"],
    "motorcycle": ["use_ferry", "use_highways", "use_tolls", "use_trails"],
    "motor_scooter": ["use_ferry", "use_highways", "use_hills", "use_primary", "use_tolls"],
    "pedestrian": ["use_ferry", "max_hiking_difficulty"],
    "transit": ["use_bus", "use_rail", "use_transfers"]
}

URL = ("https://router.hereapi.com/v8/routes?apiKey=" + poor.key.get("HERE_APIKEY") +
       "&return=polyline,turnByTurnActions,summary,actions,instructions,travelSummary"
       "&alternatives=0"
       "&lang={lang}"
       "&transportMode={transportMode}"
       "&routingMode={routingMode}"
       "&origin={origin}"
       "&destination={destination}"
       )

cache = {}

def prepare_endpoint(point):
    """Return `point` as a dictionary ready to be passed on to the router."""
    if isinstance(point, (list, tuple)):
        return dict(lat=point[1], lon=point[0])
    if isinstance(point, dict):
        d = dict(lat=point["y"], lon=point["x"])
        if "text" in point: d["name"] = point["text"]
        if "destination" in point and not point["destination"]:
            d["type"] = "break_through"
        else:
            d["type"] = "break"
        return d
    geocoder = poor.Geocoder("default")
    results = geocoder.geocode(point, params=dict(limit=1))
    return prepare_endpoint((results[0]["x"], results[0]["y"]))

def prepare_txtpoint(point):
    """Return URL component describing a location"""
    s = "{},{}".format(point["lat"], point["lon"])
    if "heading" in point:
        s += ";course={}".format(int(point["heading"]))
    if "type" in point and point["type"] == "break_through":
        s += "!passThrough=true"
    return s


def route(locations, params):
    """Find route and return its properties as a dictionary."""
    loc = list(map(prepare_endpoint, locations))
    if len(loc) < 2: return None
    loc[0]["type"] = "break" # pass through not supported for origin
    heading = params.get('heading', None)
    if heading is not None:
        loc[0]["heading"] = heading
    lang = poor.conf.routers.here.language
    units = "metric" if poor.conf.units == "metric" else "imperial"
    transportMode = poor.conf.routers.here.type
    routingMode = "short" if poor.conf.routers.here.shorter else "fast"
    origin = prepare_txtpoint(loc[0])
    destination = prepare_txtpoint(loc[-1])
    via = ''
    for point in loc[1:-1]:
       via += "&via=" + prepare_txtpoint(point)
    avoid = []
    if poor.conf.routers.here.avoid_car_train: avoid.append("carShuttleTrain")
    if transportMode=="truck" and poor.conf.routers.here.avoid_difficult_turn: avoid.append("difficultTurns")
    if poor.conf.routers.here.avoid_dirt: avoid.append("dirtRoad")
    if poor.conf.routers.here.avoid_highway: avoid.append("controlledAccessHighway")
    if poor.conf.routers.here.avoid_ferry: avoid.append("ferry")
    if poor.conf.routers.here.avoid_seasonal_closure: avoid.append("seasonalClosure")
    if poor.conf.routers.here.avoid_toll: avoid.append("tollRoad")
    if poor.conf.routers.here.avoid_tunnel: avoid.append("tunnel")
    if len(avoid) > 0:
        avoid = "&avoid[features]=" + (",".join(avoid))
    else:
        avoid = ""

    url = URL.format(**locals()) + via + avoid
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    result = poor.http.get_json(url)
    result = poor.AttrDict(result)
    #return result
    mode = MODE.get(transportMode,"car")
    return parse_result(url, locations, result, mode, lang, loc)


def parse_result(url, locations, result, mode, lang_translation, locations_processed):
    """Parse and return route"""

    X, Y, Man, LocPointInd = [], [], [], [0]
    location_candidates = []
    for legs in result.routes[0].sections:
        x, y = [], []
        for p in poor.flexpolyline.decode(legs.polyline):
            x.append(p[1])
            y.append(p[0])

        instructions = { i.offset: i.instruction for i in legs.actions }
        language = legs.language
        transport_mode = legs.transport.mode
        maneuvers = []

        if "preActions" in legs:
            for maneuver in legs.preActions:
                m = dict(
                    x=float(x[0]),
                    y=float(y[0]),
                )
                m.update(process_maneuver(maneuver,
                                          transport_mode=transport_mode,
                                          language=language,
                                          lang_translation=lang_translation,
                                          fill_narrative=True))
                maneuvers.append(m)

        # preprocess roundabouts
        for i in range(len(legs.turnByTurnActions)-1):
            m0 = legs.turnByTurnActions[i]
            m1 = legs.turnByTurnActions[i+1]
            if m0.action == "roundaboutEnter" and m1.action == "roundaboutExit":
                m0["exit"] = m1.get("exit", None)

        for maneuver in legs.turnByTurnActions:
            m = dict(
                x=float(x[maneuver.offset]),
                y=float(y[maneuver.offset]),
                narrative=instructions.get(maneuver.offset, None),
            )
            m.update(process_maneuver(maneuver,
                                      transport_mode=transport_mode,
                                      language=language,
                                      lang_translation=lang_translation,
                                      fill_narrative=(m["narrative"] is None)))
            maneuvers.append(m)

        if "postActions" in legs:
            for maneuver in legs.postActions:
                m = dict(
                    x=float(x[-1]),
                    y=float(y[-1]),
                )
                m.update(process_maneuver(maneuver,
                                          transport_mode=transport_mode,
                                          language=language,
                                          lang_translation=lang_translation,
                                          fill_narrative = True))
                maneuvers.append(m)

        X.extend(x)
        Y.extend(y)
        Man.extend(maneuvers)
        location_candidates.append(poor.AttrDict(dict(index=len(X)-1, x=x[-1], y=y[-1])))

    # HERE sets segments not always by waypoints. When boarding a
    # ferry, segment can be introduced without waypoint. When having
    # pass through waypoint, it is not reflected in segments
    ic = 0
    while len(LocPointInd) < len(locations_processed)-1:
        target = locations_processed[len(LocPointInd)]
        if target["type"] == "break_through":
            LocPointInd.append(-1) # will be found by navigator
            continue
        t_lat = target["lat"]
        t_lon = target["lon"]
        delta = [calculate_distance(c.x, c.y, t_lon, t_lat) for c in location_candidates[ic:-1]]
        # move along locations and accept one which is reasonable
        # and close enough to the location. have to handle the
        # case where the same location is in the route multiple
        # times
        min_i = min(range(len(delta)), key=delta.__getitem__)
        min_v = delta[min_i]
        # check if we have multiple minima
        mins = [min_i]
        for i in range(1,len(delta)-1):
            if i!=min_i and delta[i]<1.1*min_v and delta[i-1]>delta[i] and delta[i+1]>delta[i]:
                mins.append(i)
        # get the first minimum
        ic = ic + min(mins)
        LocPointInd.append(location_candidates[ic].index)
        ic += 1

    # add last location
    LocPointInd.append(location_candidates[-1].index)
    if len(LocPointInd) != len(locations_processed):
        print("Error while filling location indexes. Please file and issue at the project page")
        print("Data:", locations_processed, location_candidates, LocPointInd)
        return dict()

    route = dict(x=X, y=Y,
                 locations=locations,
                 location_indexes=LocPointInd,
                 maneuvers=Man, mode=mode)
    route["language"] = result.routes[0].sections[0].language.replace("-","_")
    if route and route["x"]:
        cache[url] = copy.deepcopy(route)
    return route

def get_exit_number(maneuver, language):
    if "exitSign" in maneuver and "number" in maneuver.exitSign:
        return get_name(maneuver.exitSign.number, language)
    return None

def get_exit_toward(maneuver, language):
    toward = []
    if maneuver.action in ["continueHighway", "keep"]:
        if "currentRoad" in maneuver and "toward" in maneuver.currentRoad:
            toward.extend([i.value for i in maneuver.currentRoad.toward])
    if "nextRoad" in maneuver and "number" in maneuver.nextRoad:
        toward.append(get_name(maneuver.nextRoad.number, language))
    if len(toward) > 0:
        return toward
    return None

def get_name(names, language):
    for i in names:
        if i.language == language or i.language.split("-")[0]==language.split("-")[0]:
            return i.value
    if len(names) > 0:
        return names[0].value
    return None

def get_roundabout_exit(maneuver):
    if maneuver.action.startswith("roundabout") and "exit" in maneuver:
        return maneuver.exit
    return None

def get_street(maneuver, language):
    if "nextRoad" in maneuver and "name" in maneuver.nextRoad:
        return get_name(maneuver.nextRoad.name, language)
    return None

def process_maneuver(maneuver, transport_mode, language, lang_translation, fill_narrative):
    action = maneuver.action
    direction = maneuver.get("direction", None)
    duration=float(maneuver.duration)
    exit_number=get_exit_number(maneuver, language)
    exit_toward=get_exit_toward(maneuver, language)
    icon = "flag"
    length=float(maneuver.get("length", -1))
    roundabout_exit_count=get_roundabout_exit(maneuver)
    severity=maneuver.get("severity", None)
    street = get_street(maneuver, language)
    verbal_alert=None
    verbal_pre=None
    if length > 0:
        length=format_distance(length, short=False, lang=lang_translation)
        verbal_post=__("Continue for {distance}", lang_translation).format(distance=length)
    else:
        verbal_post=None

    def unknown():
        print("\n******************************")
        print("HERE Router: Unknown action, please notify the developers by filing an issue at Github with the details below")
        print("For privacy, just blank out street names, coordinates and such")
        print(maneuver)
        print("******************************\n")


    if action == "arrive":
        verbal_pre=__("Arrive at your destination", lang_translation)
        icon="arrive"

    elif action == "board" and transport_mode == "ferry":
        verbal_pre=__("Board the ferry", lang_translation)
        icon="ferry"

    elif action == "continue":
        verbal_pre=__("Continue", lang_translation)
        icon="continue"

    elif action == "continueHighway":
        if direction == "right":
            verbal_pre=__("Merge right and continue on highway", lang_translation)
        elif direction == "left":
            verbal_pre=__("Merge left and continue on highway", lang_translation)
        icon="merge-slight-{direction}".format(direction=direction)

    elif action == "deboard" and transport_mode == "ferry":
        verbal_pre=__("Disembark the ferry", lang_translation)
        icon="ferry"

    elif action == "depart":
        verbal_pre=__("Start navigation", lang_translation)
        icon="depart"

    elif action == "enterHighway":
        if direction == "right":
            verbal_pre=__("Merge right and enter highway", lang_translation)
        elif direction == "left":
            verbal_pre=__("Merge left and enter highway", lang_translation)
        else:
            verbal_pre=__("Enter highway", lang_translation)
        if direction in ["right", "left"]:
            icon="merge-slight-{direction}".format(direction=direction)
        else:
            icon="continue"

    elif action == "exit":
        if severity == "light":
            strength = "slight-"
        else:
            strength = ""
        if exit_number is None:
            if direction == "right":
                verbal_pre=__("Take exit on the right", lang_translation)
            elif direction == "left":
                verbal_pre=__("Take exit on the left", lang_translation)
        else:
            if direction == "right":
                verbal_pre=__("Take exit {number} on the right", lang_translation).format(number=exit_number)
            elif direction == "left":
                verbal_pre=__("Take exit {number} on the left", lang_translation).format(number=exit_number)
        icon="fork-{strength}{direction}".format(strength=strength, direction=direction)

    elif action == "keep":
        diricon = direction
        strength = "slight-"
        if direction == "right":
            verbal_pre=__("Keep right", lang_translation)
        elif direction == "left":
            verbal_pre=__("Keep left", lang_translation)
        elif direction == "middle":
            diricon = "straight"
            strength = ""
            verbal_pre=__("Keep straight", lang_translation)
        icon="fork-{strength}{direction}".format(strength=strength, direction=diricon)

    elif action == "roundaboutEnter":
        verbal_alert="Enter the roundabout"
        if roundabout_exit_count==1:
            verbal_pre=__("Enter the roundabout and take the first exit", lang_translation)
        elif roundabout_exit_count==2:
            verbal_pre=__("Enter the roundabout and take the second exit", lang_translation)
        elif roundabout_exit_count==3:
            verbal_pre=__("Enter the roundabout and take the third exit", lang_translation)
        elif roundabout_exit_count==4:
            verbal_pre=__("Enter the roundabout and take the fourth exit", lang_translation)
        elif roundabout_exit_count==5:
            verbal_pre=__("Enter the roundabout and take the fifth exit", lang_translation)
        elif roundabout_exit_count==2:
            verbal_pre=__("Enter the roundabout and take the sixth exit", lang_translation)
        else:
            verbal_pre=__("Enter the roundabout", lang_translation)
        icon="roundabout"

    elif action == "roundaboutExit":
        verbal_pre=__("Exit the roundabout", lang_translation)
        icon="roundabout"

    elif action == "turn":
        if severity == "light":
            strength = "slight-"
            if direction == "right":
                verbal_pre=__("Bear right", lang_translation)
            elif direction == "left":
                verbal_pre=__("Bear left", lang_translation)
        elif severity == "heavy":
            strength = "sharp-"
            if direction == "right":
                verbal_pre=__("Make a sharp right", lang_translation)
            elif direction == "left":
                verbal_pre=__("Make a sharp left", lang_translation)
        else:
            strength = ""
            if direction == "right":
                verbal_pre=__("Turn right", lang_translation)
            elif direction == "left":
                verbal_pre=__("Turn left", lang_translation)
        icon="turn-{strength}{direction}".format(strength=strength, direction=direction)

    elif action == "uTurn":
        if direction == "right":
            verbal_pre=__("Make a right U-turn", lang_translation)
        elif direction == "left":
            verbal_pre=__("Make a left U-turn", lang_translation)
        else:
            verbal_pre=__("Make a U-turn", lang_translation)
        icon="uturn"

    else:
        # catch all unknown actions
        unknown()
        verbal_pre = "action: " + action

    r = dict(
        duration=duration,
        icon=icon,
        sign=dict(
            exit_number=([exit_number] if exit_number is not None else None),
            exit_toward=exit_toward
        ),
        street=[street] if street is not None else None,
        roundabout_exit_count=roundabout_exit_count,
        verbal_alert=verbal_alert if verbal_alert is not None else verbal_pre,
        verbal_pre=verbal_pre,
        verbal_post=verbal_post
        )
    if fill_narrative:
        r["narrative"] = verbal_pre
    return r
