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

"""Managing a history of search queries."""

import os
import poor
import sys

from poor.i18n import _

__all__ = ("HistoryManager",)


class HistoryManager:

    """Managing a history of search queries."""

    _places_blacklist = ["Current position", _("Current position")]

    def __init__(self):
        """Initialize a :class:`HistoryManager` instance."""
        self._place_types = []
        self._places = []
        self._read_place_types()
        self._read_places()

    def add_place(self, place):
        """Add `place` to the list of places."""
        place = place.strip()
        if not place: return
        if place in self._places_blacklist: return
        self.remove_place(place)
        self._places.insert(0, place)

    def add_place_type(self, place_type):
        """Add `place_type` to the list of place types."""
        place_type = place_type.strip()
        if not place_type: return
        self.remove_place_type(place_type)
        self._place_types.insert(0, place_type)

    @property
    def place_types(self):
        """Return a list of place types."""
        return self._place_types[:]

    @property
    def places(self):
        """Return a list of places."""
        return self._places[:]

    def _read_place_types(self):
        """Read list of place types from file."""
        path = os.path.join(poor.CONFIG_HOME_DIR, "place_types.history")
        try:
            if os.path.isfile(path):
                with open(path, "r", encoding="utf_8") as f:
                    self._place_types = [x.strip() for x in f.read().splitlines()]
                    self._place_types = list(filter(None, self._place_types))
        except Exception as error:
            print("Failed to read file '{}': {}"
                  .format(path, str(error)),
                  file=sys.stderr)
        if not self._place_types:
            # Provide some examples of place types.
            self._place_types = ["ATM",
                                 "Café",
                                 "Gas station",
                                 "Grocery store",
                                 "Hotel",
                                 "Pub",
                                 "Restaurant"]

    def _read_places(self):
        """Read list of places from file."""
        path = os.path.join(poor.CONFIG_HOME_DIR, "places.history")
        try:
            if os.path.isfile(path):
                with open(path, "r", encoding="utf_8") as f:
                    self._places = [x.strip() for x in f.read().splitlines()]
                    self._places = list(filter(None, self._places))
        except Exception as error:
            print("Failed to read file '{}': {}"
                  .format(path, str(error)),
                  file=sys.stderr)
        for place in self._places_blacklist:
            self.remove_place(place)

    def remove_place(self, place):
        """Remove `place` from the list of places."""
        place = place.strip().lower()
        for i in reversed(range(len(self._places))):
            if self._places[i].lower() == place:
                del self._places[i]

    def remove_place_type(self, place_type):
        """Remove `place_type` from the list of place types."""
        place_type = place_type.strip().lower()
        for i in reversed(range(len(self._place_types))):
            if self._place_types[i].lower() == place_type:
                del self._place_types[i]

    def _write(self, items, basename):
        """Write `items` to file `basename`."""
        path = os.path.join(poor.CONFIG_HOME_DIR, basename)
        try:
            poor.util.makedirs(os.path.dirname(path))
            with poor.util.atomic_open(path, "w", encoding="utf_8") as f:
                f.writelines("\n".join(items[:1000]) + "\n")
        except Exception as error:
            print("Failed to write file '{}': {}"
                  .format(path, str(error)),
                  file=sys.stderr)

    def write(self):
        """Write lists of history items to files."""
        self._write(self._place_types, "place_types.history")
        self._write(self._places, "places.history")
