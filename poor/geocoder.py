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
import os
import poor
import random
import re
import socket
import sys
import traceback

from poor.i18n import _

__all__ = ("Geocoder",)

RE_GEO_URI = re.compile(r"\bgeo:(-?[\d.]+),(-?[\d.]+)\b", re.IGNORECASE)
RE_LAT_LON = re.compile(r"^\s*(-?\d+(\.\d+)?)[^\w\-]+(-?\d+(\.\d+)?)\s*")


class Geocoder:

    """Translating addresses and names into coordinates."""

    def __new__(cls, id):
        """Return possibly existing instance for `id`."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        if id not in cls._instances:
            cls._instances[id] = object.__new__(cls)
        return cls._instances[id]

    def __init__(self, id):
        """Initialize a :class:`Geocoder` instance."""
        # Initialize properties only once.
        if hasattr(self, "id"): return
        path, values = self._load_attributes(id)
        self._attribution = values.get("attribution", {})
        self.id = id
        self.name = values["name"]
        self._provider = None
        self._init_provider(re.sub(r"\.json$", ".py", path))

    @property
    def attribution(self):
        """Return a list of attribution dictionaries."""
        return [{"text": k, "url": v} for k, v in self._attribution.items()]

    def autocomplete(self, query, x=0, y=0, params=None):
        """
        Return a list of autocomplete dictionaries matching `query`.

        `params` can be used to specify a dictionary of geocoder-specific
        parameters.
        """
        params = params or {}
        if (not hasattr(self._provider, "autocomplete") or
            not callable(self._provider.autocomplete) or
            RE_GEO_URI.search(query) or
            RE_LAT_LON.search(query)):
            return []
        try:
            results = self._provider.autocomplete(query, x, y, params)
        except Exception:
            print("Autocomplete failed:", file=sys.stderr)
            traceback.print_exc()
            return []
        for result in results:
            result["provider"] = self.id
        return results

    def _format_distance(self, x1, y1, x2, y2):
        """Calculate and format a human readable distance string."""
        distance = poor.util.calculate_distance(x1, y1, x2, y2)
        bearing  = poor.util.calculate_bearing(x1, y1, x2, y2)
        return poor.util.format_distance_and_bearing(distance, bearing)

    def geocode(self, query, params=None, x=0, y=0):
        """
        Return a list of dictionaries of places matching `query`.

        `params` can be used to specify a dictionary of geocoder-specific
        parameters. If the current position as `x` and `y` are provided,
        the results will include correct distance and bearing.
        """
        params = params or {}
        # Parse coordinates if query is a geo URI.
        match = RE_GEO_URI.search(query)
        if match is not None:
            qy = float(match.group(1))
            qx = float(match.group(2))
            return [dict(title=_("Point from geo link"),
                         description=match.group(0),
                         x=qx,
                         y=qy,
                         distance=self._format_distance(x, y, qx, qy),
                         provider=self.id)]

        # Parse coordinates if query is "LAT,LON".
        match = RE_LAT_LON.search(query)
        if match is not None:
            qy = float(match.group(1))
            qx = float(match.group(3))
            return [dict(title=_("Point from coordinates"),
                         description=match.group(0),
                         x=qx,
                         y=qy,
                         distance=self._format_distance(x, y, qx, qy),
                         provider=self.id)]

        try:
            results = self._provider.geocode(query, params)
        except socket.timeout:
            return dict(error=True, message=_("Connection timed out"))
        except Exception:
            print("Geocoding failed:", file=sys.stderr)
            traceback.print_exc()
            return []
        for result in results:
            result["distance"] = self._format_distance(
                x, y, result["x"], result["y"])
            result["provider"] = self.id
        return results

    def _init_provider(self, path):
        """Initialize geocoding provider module from `path`."""
        name = "poor.geocoder.provider{:d}".format(random.randrange(10**12))
        loader = importlib.machinery.SourceFileLoader(name, path)
        self._provider = loader.load_module(name)

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("geocoders", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        return path, poor.util.read_json(path)
