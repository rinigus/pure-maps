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

import collections
import poor
import threading

__all__ = ("TileCollection",)


class Tile:

    """Properties of a map tile."""

    def __init__(self, uid):
        """Initialize a :class:`Tile` instance."""
        self.ready = True
        self.x = -1
        self.y = -1
        self.zoom = -1
        self.uid = uid


class TileCollection:

    """A collection of map tiles visible on screen."""

    def __init__(self):
        """Initialize a :class:`TileCollection` instance."""
        self._lock = threading.Lock()
        self._tiles = collections.deque()

    @poor.util.locked_method
    def get(self, x, y, zoom):
        """Return tile at position or ``None``."""
        # Iterate from the right, append found tile to the right.
        for i in reversed(range(len(self._tiles))):
            tile = self._tiles[i]
            if (tile.zoom == zoom and tile.x == x and tile.y == y):
                del self._tiles[i]
                self._tiles.append(tile)
                return tile
        return None

    @poor.util.locked_method
    def get_free(self, xmin, xmax, ymin, ymax, zoom):
        """Return a random tile outside bounds."""
        # Iterate from the left, append found tile to the right.
        for i, tile in enumerate(self._tiles):
            if not tile.ready: continue
            if (tile.zoom != zoom or
                tile.x + 1 < xmin or
                tile.x > xmax or
                tile.y + 1 < ymin or
                tile.y > ymax):
                del self._tiles[i]
                self._tiles.append(tile)
                tile.ready = False
                return tile

        # If no free tile found, grow collection.
        nscreen = (xmax - xmin + 1) * (ymax - ymin + 1)
        nneeded = nscreen * 3 - len(self._tiles)
        for i in range(max(1, nneeded)):
            tile = Tile(len(self._tiles)+1)
            self._tiles.appendleft(tile)
        tile = Tile(len(self._tiles)+1)
        self._tiles.append(tile)
        tile.ready = False
        return tile

    @poor.util.locked_method
    def reset(self):
        """Reset tile properties."""
        for tile in self._tiles:
            tile.ready = True
            tile.x = -1
            tile.y = -1
            tile.zoom = -1
