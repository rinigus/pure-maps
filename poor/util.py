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
import urllib.request


def bbox_deg2num(xmin, xmax, ymin, ymax, zoom):
    """Convert longitude, latitude bounding box to tile numbers."""
    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    xmin = max(-179.999999, xmin)
    xmax = min( 179.999999, xmax)
    ymin = max( -85.051099, ymin)
    ymax = min(  85.051099, ymax)
    xtilemin, ytilemax = deg2num(xmin, ymin, zoom)
    xtilemax, ytilemin = deg2num(xmax, ymax, zoom)
    return (xtilemin, xtilemax, ytilemin, ytilemax)

def calculate_distance(x1, y1, x2, y2):
    """Calculate distance in kilometers from point 1 to point 2."""
    # Using the Haversine formula.
    # http://www.movable-type.co.uk/scripts/latlong.html
    x1, y1, x2, y2 = map(math.radians, (x1, y1, x2, y2))
    a = (math.sin((y2-y1)/2)**2 + math.sin((x2-x1)/2)**2 *
         math.cos(y1) * math.cos(y2))

    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return 6371 * c

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

def deg2num(x, y, zoom):
    """Convert longitude, latitude to tile numbers."""
    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    yrad = math.radians(y)
    n = 2**zoom
    xtile = int((x + 180) / 360 * n)
    ytile = int((1 - (math.log(math.tan(yrad) + (1 / math.cos(yrad)))
                      / math.pi)) / 2 * n)

    return (xtile, ytile)

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

def format_distance(distance, n, units="km"):
    """Format `distance` to `n` significant digits and unit label."""
    # XXX: We might need to support for non-SI units here.
    if units == "km" and distance < 1:
        return format_distance(distance*1000, n, units="m")
    ndigits = n - math.ceil(math.log10(abs(distance)))
    if units == "m":
        ndigits = min(0, ndigits)
    distance = round(distance, ndigits)
    fstring = "{{:.{:d}f}} {{}}".format(max(0, ndigits))
    return fstring.format(distance, units)

def get_geocoders():
    """Return a list of dictionaries of geocoder attributes."""
    geocoders = []
    for parent in (poor.CONFIG_HOME_DIR, poor.DATA_DIR):
        for path in glob.glob("{}/geocoders/*.json".format(parent)):
            pid = os.path.basename(path).replace(".json", "")
            # Local definitions override global ones.
            if pid in (x["pid"] for x in geocoders): continue
            active = (pid == poor.conf.geocoder)
            try:
                with open(path, "r", encoding="utf_8") as f:
                    geocoder = json.load(f)
                geocoder["pid"] = pid
                geocoder["active"] = active
                geocoders.append(geocoder)
            except Exception as error:
                print("Failed to read geocoder definition file '{}': {}"
                      .format(path, str(error)),
                      file=sys.stderr)

    geocoders.sort(key=lambda x: x["name"])
    return(geocoders)

def get_tilesources():
    """Return a list of dictionaries of tilesource attributes."""
    tilesources = []
    for parent in (poor.CONFIG_HOME_DIR, poor.DATA_DIR):
        for path in glob.glob("{}/tilesources/*.json".format(parent)):
            pid = os.path.basename(path).replace(".json", "")
            # Local definitions override global ones.
            if pid in (x["pid"] for x in tilesources): continue
            active = (pid == poor.conf.tilesource)
            try:
                with open(path, "r", encoding="utf_8") as f:
                    tilesource = json.load(f)
                tilesource["pid"] = pid
                tilesource["active"] = active
                tilesources.append(tilesource)
            except Exception as error:
                print("Failed to read tilesource definition file '{}': {}"
                      .format(path, str(error)),
                      file=sys.stderr)

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
    """Create and return `directory` or ``None`` if fails."""
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

        return None
    return directory

def num2deg(xtile, ytile, zoom):
    """Convert tile numbers to longitude, latitude."""
    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    n = 2**zoom
    x = xtile / n * 360 - 180
    yrad = math.atan(math.sinh(math.pi * (1 - 2 * ytile / n)))
    y = math.degrees(yrad)
    return (x, y)

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

def request_url(url, encoding=None, timeout=None):
    """
    Request and return data at `url`.

    If `encoding` is ``None``, return bytes, otherwise decode data
    to text using `encoding`. If `timeout` is ``None`` use
    :var:`poor.conf.download_timeout`.
    """
    opener = urllib.request.build_opener()
    agent = "poor-maps/{}".format(poor.__version__)
    opener.addheaders = [("User-Agent", agent)]
    timeout = timeout or poor.conf.download_timeout
    with opener.open(url, timeout=timeout) as f:
        blob = f.read()
        if encoding is None: return blob
        return blob.decode(encoding, errors="replace")

@contextlib.contextmanager
def silent(*exceptions):
    """Try to execute body, ignoring `exceptions`."""
    try:
        yield
    except exceptions:
        pass
