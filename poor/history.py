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

__all__ = ("HistoryManager",)


class HistoryManager:

    """Managing a history of search queries."""

    def __init__(self, max_size=1000):
        """Initialize a :class:`HistoryManager` instance."""
        self._max_size = max_size
        self._places = []
        self._services = []
        self._read_places()
        self._read_services()

    def add_place(self, place):
        """Add `place` to the list of places."""
        place = place.strip()
        if not place: return
        self.remove_place(place)
        self._places.insert(0, place)

    def add_service(self, service):
        """Add `service` to the list of services."""
        service = service.strip()
        if not service: return
        self.remove_service(service)
        self._services.insert(0, service)

    @property
    def places(self):
        """Return a list of places."""
        return self._places[:]

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

    def _read_services(self):
        """Read list of services from file."""
        path = os.path.join(poor.CONFIG_HOME_DIR, "services.history")
        try:
            if os.path.isfile(path):
                with open(path, "r", encoding="utf_8") as f:
                    self._services = [x.strip() for x in f.read().splitlines()]
                    self._services = list(filter(None, self._services))
        except Exception as error:
            print("Failed to read file '{}': {}"
                  .format(path, str(error)),
                  file=sys.stderr)

        if not self._services:
            # Provide some examples of services.
            self._services = ["ATM",
                              "Cafe",
                              "Convenience store",
                              "Gas station",
                              "Grocery shop",
                              "Hotel",
                              "Library",
                              "Pharmacy",
                              "Pub",
                              "Restaurant",
                              "Supermarket"]

    def remove_place(self, place):
        """Remove `place` from the list of places."""
        place = place.strip().lower()
        for i in list(reversed(range(len(self._places)))):
            if self.places[i].lower() == place:
                self._places.pop(i)

    def remove_service(self, service):
        """Remove `service` from the list of services."""
        service = service.strip().lower()
        for i in list(reversed(range(len(self._services)))):
            if self.services[i].lower() == service:
                self._services.pop(i)

    @property
    def services(self):
        """Return a list of services."""
        return self._services[:]

    def _write(self, items, basename):
        """Write `items` to file `basename`."""
        items = items[:self._max_size]
        path = os.path.join(poor.CONFIG_HOME_DIR, basename)
        try:
            poor.util.makedirs(os.path.dirname(path))
            with open(path, "w", encoding="utf_8") as f:
                f.writelines("\n".join(items) + "\n")
        except Exception as error:
            print("Failed to write file '{}': {}"
                  .format(path, str(error)),
                  file=sys.stderr)

    def write(self):
        """Write lists of history items to files."""
        self._write(self._places, "places.history")
        self._write(self._services, "services.history")
