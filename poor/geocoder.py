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

"""Translating addresses and names into coordinates."""

import importlib.machinery
import json
import os
import poor
import re
import sys
import time

__all__ = ("Geocoder",)


class Geocoder:

    """Translating addresses and names into coordinates."""

    def __init__(self, id):
        """Initialize a :class:`Geocoder` instance."""
        path, values = self._load_attributes(id)
        self.attribution = values["attribution"]
        self.id = id
        self.name = values["name"]
        self._provider = None
        self.source = values["source"]
        self._init_provider(re.sub(r"\.json$", ".py", path))

    def _format_distance(self, x1, y1, x2, y2):
        """Calculate and format a human readable distance string."""
        distance = poor.util.calculate_distance(x1, y1, x2, y2)
        distance = poor.util.format_distance(distance, n=2)
        bearing = poor.util.calculate_bearing(x1, y1, x2, y2)
        bearing = poor.util.format_bearing(bearing)
        return "{} {}".format(distance, bearing)

    def geocode(self, query, x, y, xmin, xmax, ymin, ymax):
        """Return a list of dictionaries of places matching `query`."""
        try:
            results = self._provider.geocode(query, xmin, xmax, ymin, ymax)
        except Exception as error:
            # XXX: Should we relay an error message to QML?
            print("Geocoding failed: {}".format(str(error)), file=sys.stderr)
            return []
        for result in results:
            result["distance"] = self._format_distance(x,
                                                       y,
                                                       result["x"],
                                                       result["y"])

        return results

    def _init_provider(self, path):
        """Initialize geocoding provider module from `path`."""
        name = "poor.geocoder.provider{:d}".format(int(1000*time.time()))
        loader = importlib.machinery.SourceFileLoader(name, path)
        self._provider = loader.load_module(name)

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("geocoders", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        with open(path, "r", encoding="utf_8") as f:
            return path, json.load(f)
