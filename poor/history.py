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

"""Managing a history of search queries for places."""

import os
import poor
import sys

__all__ = ("HistoryManager",)


class HistoryManager:

    """Managing a history of search queries for places."""

    def __init__(self, max_size=1000):
        """Initialize a :class:`HistoryManager` instance."""
        self._max_size = max_size
        self._path = os.path.join(poor.CONFIG_HOME_DIR, "places.history")
        self._places = []
        self._read()

    def add_place(self, place):
        """Add `place` to the list of places."""
        place = place.strip()
        self.remove_place(place)
        self._places.insert(0, place)

    @property
    def places(self):
        """Return a list of places."""
        return self._places[:]

    def _read(self):
        """Read list of places from file."""
        if not os.path.isfile(self._path): return
        try:
            with open(self._path, "r", encoding="utf_8") as f:
                self._places = [x.strip() for x in f.read().splitlines()]
                self._places = list(filter(None, self._places))
        except Exception as error:
            print("Failed to read file '{}': {}"
                  .format(self._path, str(error)),
                  file=sys.stderr)

    def remove_place(self, place):
        """Remove `place` from the list of places."""
        with poor.util.silent(ValueError):
            self._places.remove(place)

    def write(self):
        """Write list of places to file."""
        directory = os.path.dirname(self._path)
        directory = poor.util.makedirs(directory)
        if directory is None: return
        self._places = self._places[:self._max_size]
        try:
            with open(self._path, "w", encoding="utf_8") as f:
                f.writelines("\n".join(self._places) + "\n")
        except Exception as error:
            print("Failed to write file '{}': {}"
                  .format(self._path, str(error)),
                  file=sys.stderr)
