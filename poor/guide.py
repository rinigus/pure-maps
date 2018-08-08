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

"""Listing nearby places based on place type."""

import importlib.machinery
import os
import poor
import random
import re
import socket
import sys
import traceback

from poor.i18n import _

__all__ = ("Guide",)


class Guide:

    """Listing nearby places based on place type."""

    def __new__(cls, id):
        """Return possibly existing instance for `id`."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        if id not in cls._instances:
            cls._instances[id] = object.__new__(cls)
        return cls._instances[id]

    def __init__(self, id):
        """Initialize a :class:`Guide` instance."""
        # Initialize properties only once.
        if hasattr(self, "id"): return
        path, values = self._load_attributes(id)
        self._attribution = values.get("attribution", {})
        self.geocoder = poor.Geocoder(values.get("geocoder", "default"))
        self.id = id
        self.name = values["name"]
        self._path = path
        self._provider = None
        self._init_provider(id, re.sub(r"\.json$", ".py", path))

    @property
    def attribution(self):
        """Return a list of attribution dictionaries."""
        return [{"text": k, "url": v} for k, v in self._attribution.items()]

    def autocomplete_type(self, query, params=None):
        """
        Return a list of autocomplete dictionaries matching `query`.

        `params` can be used to specify a dictionary of guide-specific
        parameters.
        """
        params = params or {}
        if not self.autocomplete_type_supported: return []
        try:
            results = self._provider.autocomplete_type(query, params)
        except Exception:
            print("Autocomplete failed:", file=sys.stderr)
            traceback.print_exc()
            return []
        for result in results:
            result["provider"] = self.id
        return results

    @property
    def autocomplete_type_supported(self):
        """Return ``True`` if provider implements venue type autocompletion."""
        return (hasattr(self._provider, "autocomplete_type") and
                callable(self._provider.autocomplete_type))

    def _format_distance(self, x1, y1, x2, y2, distance):
        """Format distance in a human readable distance string."""
        bearing  = poor.util.calculate_bearing(x1, y1, x2, y2)
        return poor.util.format_distance_and_bearing(distance, bearing)

    def _init_provider(self, id, path):
        """Initialize place guide provider module from `path`."""
        name = "poor.guide.provider{:d}".format(random.randrange(10**12))
        loader = importlib.machinery.SourceFileLoader(name, path)
        self._provider = loader.load_module(name)
        if hasattr(self._provider, "CONF_DEFAULTS"):
            poor.conf.register_guide(id, self._provider.CONF_DEFAULTS)

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("guides", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        return path, poor.util.read_json(path)

    def nearby(self, query, near, radius, params=None):
        """
        Return a list of dictionaries of places matching `query`.

        `near` can be either a string (usually an address) or a two-element
        tuple or list of (x,y) coordinates. `radius` should be meters around
        `near` to search places for. `params` can be used to specify
        a dictionary of guide-specific parameters.
        """
        params = params or {}
        try:
            x, y, results = self._provider.nearby(query, near, radius, params)
        except socket.timeout:
            return dict(error=True, message=_("Connection timed out"))
        except Exception:
            print("Nearby failed:", file=sys.stderr)
            traceback.print_exc()
            return []
        for result in results:
            if "distance" not in result:
                result["distance"] = poor.util.calculate_distance(
                    x, y, result["x"], result["y"])
            result["provider"] = self.id
        for result in results:
            result["distance"] = self._format_distance(
                x, y, result["x"], result["y"], result["distance"])
        return results

    @property
    def settings_qml_uri(self):
        """Return URI to guide settings QML file or ``None``."""
        path = re.sub(r"\.json$", "_settings.qml", self._path)
        if not os.path.isfile(path): return None
        return poor.util.path2uri(path)
