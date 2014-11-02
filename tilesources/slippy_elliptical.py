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
A variation of the 'slippy' format using elliptical Mercator.

This is the tiling format used at least by Yandex. Compared to the 'slippy'
format, the conversion between latitude/longitude coordinates and Mercator
coordinates differs, but the tiling logic is otherwise the same.

http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
http://wiki.openstreetmap.org/wiki/Mercator#Elliptical_Mercator
"""

import functools
import importlib.machinery
import math
import os

path = os.path.join(os.path.dirname(__file__), "slippy.py")
loader = importlib.machinery.SourceFileLoader("slippy", path)
slippy = loader.load_module("slippy")

list_tiles = slippy.list_tiles
tile_corners = slippy.tile_corners
tile_path = slippy.tile_path

RATIO = 6356752.3142 / 6378137
ECCENT = math.sqrt(1 - RATIO**2)

def deg2num(x, y, zoom):
    """Convert longitude, latitude to tile numbers."""
    xmerc = math.radians(x)
    phi = math.radians(y)
    con = ECCENT * math.sin(phi)
    con = ((1 - con) / (1 + con))**(ECCENT/2)
    ts = math.tan(0.5 * (math.pi * 0.5 - phi)) / con
    ymerc = -math.log(ts)
    xtile = int((1 + xmerc/math.pi) / 2 * 2**zoom)
    ytile = int((1 - ymerc/math.pi) / 2 * 2**zoom)
    return xtile, ytile

@functools.lru_cache(256)
def num2deg(xtile, ytile, zoom):
    """Convert tile numbers to longitude, latitude."""
    xmerc = (xtile / 2**zoom * 2 - 1) * math.pi
    ymerc = (1 - ytile / 2**zoom * 2) * math.pi
    x = math.degrees(xmerc)
    ts = math.exp(-ymerc)
    phi = math.pi/2 - 2 * math.atan(ts)
    for i in range(15):
        con = ECCENT * math.sin(phi)
        con = ((1 - con) / (1 + con))**(ECCENT/2)
        dphi = math.pi/2 - 2 * math.atan(ts * con) - phi
        phi += dphi
        if abs(dphi) < 0.000000001: break
    y = math.degrees(phi)
    return x, y

slippy.deg2num = deg2num
slippy.num2deg = num2deg
