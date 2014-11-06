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
A popular spherical Mercator tiling format.

This tile format is used by Google, OpenSteetMap and many others.
It's based on a spherical Mercator projection ("Web Mercator", EPSG: 3857).

http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
"""

import functools
import math
import os

def deg2num(x, y, zoom):
    """Convert longitude, latitude to tile numbers."""
    xmerc = math.radians(x)
    ymerc = math.asinh(math.tan(math.radians(y)))
    xtile = int((1 + xmerc/math.pi) / 2 * 2**zoom)
    ytile = int((1 - ymerc/math.pi) / 2 * 2**zoom)
    return xtile, ytile

def list_tiles(xmin, xmax, ymin, ymax, zoom):
    """Return a sequence of tiles within given bounding box."""
    xmin, xmax = max(-179.999999, xmin), min(179.999999, xmax)
    ymin, ymax = max( -85.051099, ymin), min( 85.051099, ymax)
    xtilemin, ytilemax = deg2num(xmin, ymin, int(zoom))
    xtilemax, ytilemin = deg2num(xmax, ymax, int(zoom))
    tiles = []
    for ytile in range(ytilemin, ytilemax+1):
        for xtile in range(xtilemin, xtilemax+1):
            tiles.append(dict(x=xtile, y=ytile, z=int(zoom)))
    if not tiles: return []
    # Order (and thus render) tiles closest to center first.
    xc = sum(tile["x"] for tile in tiles) / len(tiles)
    yc = sum(tile["y"] for tile in tiles) / len(tiles)
    return sorted(tiles, key=lambda tile: ((tile["x"] - xc)**2 +
                                           (tile["y"] - yc)**2))

@functools.lru_cache(256)
def num2deg(xtile, ytile, zoom):
    """Convert tile numbers to longitude, latitude."""
    xmerc = (xtile / 2**zoom * 2 - 1) * math.pi
    ymerc = (1 - ytile / 2**zoom * 2) * math.pi
    x = math.degrees(xmerc)
    y = math.degrees(math.atan(math.sinh(ymerc)))
    return x, y

def tile_corners(tile):
    """Return coordinates of NE, SE, SW, NW corners of given tile."""
    xtile, ytile, zoom = map(tile.get, ("x", "y", "z"))
    return (num2deg(xtile+1, ytile+0, zoom),
            num2deg(xtile+1, ytile+1, zoom),
            num2deg(xtile+0, ytile+1, zoom),
            num2deg(xtile+0, ytile+0, zoom))

def tile_path(tile, extension):
    """Return relative cache path to use for given tile."""
    xtile, ytile, zoom = map(tile.get, ("x", "y", "z"))
    return os.path.join(str(zoom), str(xtile), str(ytile) + extension)
