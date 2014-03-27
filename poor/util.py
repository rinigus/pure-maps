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
    return (xtilemin, xtilemax, ytilemin, ytilemax)

def deg2num(x, y, zoom):
    """Convert longitude, latitude to tile numbers."""
    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    yrad = math.radians(y)
    n = 2**zoom
    xtile = int((x + 180) / 360 * n)
    ytile = int((1 - (math.log(math.tan(yrad) + (1 / math.cos(yrad)))
                      / math.pi)) / 2 * n)

    return (xtile, ytile)

def get_tilesources():
    """Return a list of dictionaries of tilesource attributes."""
    tilesources = []
    for parent in (poor.CONFIG_HOME_DIR, poor.DATA_DIR):
        for path in glob.glob("{}/tilesources/*.json".format(parent)):
            pid = os.path.basename(path).replace(".json", "")
            # Local definitions override global ones.
            if pid in (x["pid"] for x in tilesources): continue
            try:
                with open(path, "r", encoding="utf_8") as f:
                    tilesource = json.load(f)
                tilesource["pid"] = pid
                tilesources.append(tilesource)
            except Exception as error:
                print("Failed to read tilesource definition file '{}': {}"
                      .format(path, str(error)),
                      file=sys.stderr)

    tilesources.sort(key=lambda x: x["name"])
    return(tilesources)

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
