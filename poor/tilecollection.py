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

"""A collection of map tiles visible on screen."""

import poor
import threading

__all__ = ("TileCollection",)


class Tile:

    """Properties of a map tile."""

    def __init__(self, uid):
        """Initialize a :class:`Tile` instance."""
        self.uid = uid
        self.reset()

    def reset(self):
        """Reset properties."""
        self.ready = True
        self.path = ""
        self.xmin = -1
        self.xmax = -1
        self.ymin = -1
        self.ymax = -1
        self.zoom = -1


class TileCollection:

    """A collection of map tiles visible on screen."""

    def __init__(self):
        """Initialize a :class:`TileCollection` instance."""
        self._lock = threading.Lock()
        self._tiles = []

    @poor.util.locked_method
    def get(self, path):
        """Return requested tile ``None``."""
        for tile in self._tiles:
            if tile.path == path:
                return tile
        return None

    @poor.util.locked_method
    def get_free(self, xmin, xmax, ymin, ymax, zoom):
        """Return a random tile outside bounds."""
        for tile in self._tiles:
            if not tile.ready: continue
            if (tile.zoom != zoom or
                tile.xmin  > xmax or
                tile.xmax  < xmin or
                tile.ymin  > ymax or
                tile.ymax  < ymin):
                tile.ready = False
                return tile
        # If no free tile found, grow collection.
        for i in range(len(self._tiles)+1):
            tile = Tile(len(self._tiles)+1)
            self._tiles.append(tile)
        self._tiles[-1].ready = False
        return self._tiles[-1]

    @poor.util.locked_method
    def reset(self):
        """Reset tile properties."""
        for tile in self._tiles:
            tile.reset()
