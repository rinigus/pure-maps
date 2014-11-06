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
A variation of the 'slippy' format using quadtree key indexing.

This tile format is used at least by Bing. The tile division is equivalent
to the 'slippy' format, but tiles are referred to using a single key
constructed from the usual X, Y and Z values.

http://msdn.microsoft.com/en-us/library/bb259689.aspx
"""

import importlib.machinery
import os

path = os.path.join(os.path.dirname(__file__), "slippy.py")
loader = importlib.machinery.SourceFileLoader("slippy", path)
slippy = loader.load_module("slippy")
tile_corners = slippy.tile_corners
tile_path = slippy.tile_path

def list_tiles(xmin, xmax, ymin, ymax, zoom):
    """Return a sequence of tiles within given bounding box."""
    tiles = slippy.list_tiles(xmin, xmax, ymin, ymax, zoom)
    for tile in tiles:
        tile["key"] = num2key(tile["x"], tile["y"], tile["z"])
    return tiles

def num2key(xtile, ytile, zoom):
    """Convert tile numbers to quadkey."""
    key = ""
    for bit in reversed(range(1, zoom+1)):
        digit = ord("0")
        mask = 1 << (bit - 1)
        if xtile & mask != 0:
            digit += 1
        if ytile & mask != 0:
            digit += 2
        key += chr(digit)
    return key
