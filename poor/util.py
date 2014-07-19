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

"""Miscellaneous helper functions."""

import contextlib
import functools
import glob
import itertools
import json
import math
import os
import poor
import sys
import urllib.parse


def bbox_deg2num(xmin, xmax, ymin, ymax, zoom):
    """Convert longitude, latitude bounding box to tile numbers."""
    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    xmin = max(-179.999999, xmin)
    xmax = min( 179.999999, xmax)
    ymin = max( -85.051099, ymin)
    ymax = min(  85.051099, ymax)
    xtilemin, ytilemax = deg2num(xmin, ymin, zoom)
    xtilemax, ytilemin = deg2num(xmax, ymax, zoom)
    return xtilemin, xtilemax, ytilemin, ytilemax

def calculate_bearing(x1, y1, x2, y2):
    """Calculate bearing in degrees from point 1 to point 2."""
    # This is the initial bearing on the great-circle path.
    # http://www.movable-type.co.uk/scripts/latlong.html
    x1, y1, x2, y2 = map(math.radians, (x1, y1, x2, y2))
    x = (math.cos(y1) * math.sin(y2) -
         math.sin(y1) * math.cos(y2) * math.cos(x2-x1))

    y = math.sin(x2-x1) * math.cos(y2)
    bearing = math.degrees(math.atan2(y, x))
    return (bearing + 360) % 360

def calculate_distance(x1, y1, x2, y2):
    """Calculate distance in meters from point 1 to point 2."""
    # Using the Haversine formula.
    # http://www.movable-type.co.uk/scripts/latlong.html
    x1, y1, x2, y2 = map(math.radians, (x1, y1, x2, y2))
    a = (math.sin((y2-y1)/2)**2 + math.sin((x2-x1)/2)**2 *
         math.cos(y1) * math.cos(y2))

    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return 6371000 * c

def calculate_segment_distance(x, y, x1, y1, x2, y2):
    """Calculate distance in meters from point to segment."""
    # This is not quite correct, but maybe close enough,
    # given sufficiently short segments.
    med_dist_deg = math.sqrt((x - (x1+x2)/2)**2 + (y - (y1+y2)/2)**2)
    med_dist_m = calculate_distance(x, y, (x1+x2)/2, (y1+y2)/2)
    seg_dist_deg = math.sqrt(poor.polysimp.get_sq_seg_dist(x, y, x1, y1, x2, y2))
    return seg_dist_deg * (med_dist_m / med_dist_deg)

def decode_epl(string, precision=5):
    """
    Decode Google Encoded polyline string representation.

    `precision` usually defaults to five, but note that it can vary!
    Return X and Y coordinates as separate lists.

    http://developers.google.com/maps/documentation/utilities/polylinealgorithm
    """
    # Copied and adapted from various sources, see e.g.
    # http://facstaff.unca.edu/mcmcclur/GoogleMaps/EncodePolyline/decode.js
    # http://seewah.blogspot.fi/2009/11/gpolyline-decoding-in-python.html
    # http://github.com/mapbox/polyline/blob/master/src/polyline.js
    i = x = y = 0
    xout = []
    yout = []
    while i < len(string):
        b = shift = result = 0
        while True:
            b = ord(string[i]) - 63
            i = i + 1
            result |= (b & 0x1f) << shift
            shift += 5
            if b < 0x20: break
        dy = ~(result >> 1) if result & 1 else result >> 1
        y += dy
        shift = result = 0
        while True:
            b = ord(string[i]) - 63
            i = i + 1
            result |= (b & 0x1f) << shift
            shift += 5
            if b < 0x20: break
        dx = ~(result >> 1) if result & 1 else result >> 1
        x += dx
        xout.append(x / 10**precision)
        yout.append(y / 10**precision)
    return xout, yout

def deg2num(x, y, zoom):
    """Convert longitude, latitude to tile numbers."""
    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    yrad = math.radians(y)
    n = 2**zoom
    xtile = int((x + 180) / 360 * n)
    ytile = int((1 - (math.log(math.tan(yrad) + (1 / math.cos(yrad)))
                      / math.pi)) / 2 * n)

    return xtile, ytile

def format_bearing(bearing):
    """Format `bearing` to a human readable string."""
    bearing = (bearing + 360) % 360
    bearing = int(round(bearing/45)*45)
    if bearing ==   0: return "north"
    if bearing ==  45: return "north-east"
    if bearing ==  90: return "east"
    if bearing == 135: return "south-east"
    if bearing == 180: return "south"
    if bearing == 225: return "south-west"
    if bearing == 270: return "west"
    if bearing == 315: return "north-west"
    if bearing == 360: return "north"
    raise ValueError("Unexpected bearing: {}"
                     .format(repr(bearing)))

def format_distance(distance, n=2, units="m"):
    """Format `distance` to `n` significant digits and unit label."""
    # XXX: We might need to support for non-SI units here.
    if units == "km" and abs(distance) < 1:
        return format_distance(distance*1000, n, "m")
    if units == "m" and abs(distance) > 1000:
        return format_distance(distance/1000, n, "km")
    ndigits = n - math.ceil(math.log10(abs(max(1, distance)) + 1/1000000))
    if units == "m":
        ndigits = min(0, ndigits)
    distance = round(distance, ndigits)
    fstring = "{{:.{:d}f}} {{}}".format(max(0, ndigits))
    return fstring.format(distance, units)

def format_time(seconds):
    """Format `time` to format ``# h # min``."""
    hours = int(seconds/3600)
    minutes = round((seconds % 3600) / 60)
    if hours == 0:
        return "{:d} min".format(minutes)
    return "{:d} h {:d} min".format(hours, minutes)

def get_geocoders():
    """Return a list of dictionaries of geocoder attributes."""
    geocoders = []
    for parent in (poor.DATA_HOME_DIR, poor.DATA_DIR):
        for path in glob.glob("{}/geocoders/*.json".format(parent)):
            pid = os.path.basename(path).replace(".json", "")
            # Local definitions override global ones.
            if pid in (x["pid"] for x in geocoders): continue
            active = (pid == poor.conf.geocoder)
            with silent(Exception):
                geocoder = read_json(path)
                geocoder["pid"] = pid
                geocoder["active"] = active
                if not geocoder.get("hidden", False):
                    geocoders.append(geocoder)
    geocoders.sort(key=lambda x: x["name"])
    return geocoders

def get_routers():
    """Return a list of dictionaries of router attributes."""
    routers = []
    for parent in (poor.DATA_HOME_DIR, poor.DATA_DIR):
        for path in glob.glob("{}/routers/*.json".format(parent)):
            pid = os.path.basename(path).replace(".json", "")
            # Local definitions override global ones.
            if pid in (x["pid"] for x in routers): continue
            active = (pid == poor.conf.router)
            with silent(Exception):
                router = read_json(path)
                router["pid"] = pid
                router["active"] = active
                if not router.get("hidden", False):
                    routers.append(router)
    routers.sort(key=lambda x: x["name"])
    return routers

def get_tilesources():
    """Return a list of dictionaries of tilesource attributes."""
    tilesources = []
    for parent in (poor.DATA_HOME_DIR, poor.DATA_DIR):
        for path in glob.glob("{}/tilesources/*.json".format(parent)):
            pid = os.path.basename(path).replace(".json", "")
            # Local definitions override global ones.
            if pid in (x["pid"] for x in tilesources): continue
            active = (pid == poor.conf.tilesource)
            with silent(Exception):
                tilesource = read_json(path)
                tilesource["pid"] = pid
                tilesource["active"] = active
                if not tilesource.get("hidden", False):
                    tilesources.append(tilesource)
    tilesources.sort(key=lambda x: x["name"])
    return tilesources

def locked_method(function):
    """
    Decorator for methods to be run thread-safe.

    Requires class to have an instance variable '_lock'.
    """
    @functools.wraps(function)
    def wrapper(*args, **kwargs):
        with args[0]._lock:
            return function(*args, **kwargs)
    return wrapper

def makedirs(directory):
    """Create and return `directory` or raise :exc:`OSError`."""
    directory = os.path.abspath(directory)
    if os.path.isdir(directory):
        return directory
    try:
        os.makedirs(directory)
    except OSError as error:
        if os.path.isdir(directory):
            return directory
        print("Failed to create directory {}: {}"
              .format(repr(directory), str(error)),
              file=sys.stderr)
        raise # OSError
    return directory

def num2deg(xtile, ytile, zoom):
    """Convert tile numbers to longitude, latitude."""
    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    n = 2**zoom
    x = xtile / n * 360 - 180
    yrad = math.atan(math.sinh(math.pi * (1 - 2 * ytile / n)))
    y = math.degrees(yrad)
    return x, y

def path2uri(path):
    """Convert local filepath to URI."""
    return "file://{}".format(urllib.parse.quote(path))

def prod_tiles(xmin, xmax, ymin, ymax):
    """Enumerate and zip a cartesian product of tile numbers."""
    xtiles = range(xmin, xmax+1)
    ytiles = range(ymin, ymax+1)
    # Order (and thus render) tiles closest to center first.
    return sorted(itertools.product(xtiles, ytiles),
                  key=lambda tile: ((tile[0] - (xmin + xmax)/2)**2 +
                                    (tile[1] - (ymin + ymax)/2)**2))

def read_json(path):
    """Read data from JSON file at `path`."""
    try:
        with open(path, "r", encoding="utf_8") as f:
            return json.load(f)
    except Exception as error:
        print("Failed to read file {}: {}"
              .format(repr(path), str(error)),
              file=sys.stderr)
        raise

@contextlib.contextmanager
def silent(*exceptions):
    """Try to execute body, ignoring `exceptions`."""
    try:
        yield
    except exceptions:
        pass

def write_json(data, path):
    """Write `data` to JSON file at `path`."""
    try:
        makedirs(os.path.dirname(path))
        with open(path, "w", encoding="utf_8") as f:
            json.dump(data, f, ensure_ascii=False, indent=4, sort_keys=True)
    except Exception as error:
        print("Failed to write file {}: {}"
              .format(repr(path), str(error)),
              file=sys.stderr)
        raise
