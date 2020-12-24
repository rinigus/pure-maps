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

"""Finding routes between addresses and/or coordinates."""

import copy
import importlib.machinery
import os
import poor
import random
import re
import socket
import sys
import traceback

from poor.i18n import _

__all__ = ("Router",)


class Router:

    """Finding routes between addresses and/or coordinates."""

    def __new__(cls, id):
        """Return possibly existing instance for `id`."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        if id not in cls._instances:
            cls._instances[id] = object.__new__(cls)
        return cls._instances[id]

    def __init__(self, id):
        """Initialize a :class:`Router` instance."""
        # Initialize properties only once.
        if hasattr(self, "id"): return
        path, values = self._load_attributes(id)
        self._attribution = values.get("attribution", {})
        self.geocoder = poor.Geocoder(values.get("geocoder", "default"))
        self.id = id
        self.name = values["name"]
        self._path = path
        self.auto_route = values.get("auto_route", True)
        self._can_reroute = values.get("can_reroute", True)
        self.offline = values.get("offline", False)
        self.from_needed = values.get("from_needed", True)
        self.to_needed = values.get("to_needed", True)
        self._provider = None
        self._init_provider(id, re.sub(r"\.json$", ".py", path))

    @property
    def attribution(self):
        """Return a list of attribution dictionaries."""
        return [{"text": k, "url": v} for k, v in self._attribution.items()]

    @property
    def can_reroute(self):
        """Return whether the router allows rerouting."""
        return self._can_reroute

    def _init_provider(self, id, path):
        """Initialize routing provider module from `path`."""
        name = "poor.router.provider{:d}".format(random.randrange(10**12))
        loader = importlib.machinery.SourceFileLoader(name, path)
        self._provider = loader.load_module(name)
        if hasattr(self._provider, "CONF_DEFAULTS"):
            poor.conf.register_router(id, self._provider.CONF_DEFAULTS)

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("routers", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        return path, poor.util.read_json(path)

    def _process_route(self, route):
        if "maneuvers" in route:
            mnew = []
            for m in route["maneuvers"]:
                sign = m.get("sign", None)
                street = m.get("street", None)
                if (street is None or len(street)==0) and sign is not None:
                    if "exit_toward" in sign and sign["exit_toward"] is not None and len(sign["exit_toward"]) > 0:
                        street = "⇨ " + ("; ".join(sign["exit_toward"]))
                    elif "exit_branch"  in sign and sign["exit_branch"] is not None and len(sign["exit_branch"]) > 0:
                        street = "⇨ " + ("; ".join(sign["exit_branch"]))
                    elif "exit_number"  in sign and sign["exit_number"] is not None and len(sign["exit_number"]) > 0:
                        street = _("Exit: ") + ("; ".join(sign["exit_number"]))
                    elif "exit_name"  in sign and sign["exit_name"] is not None and len(sign["exit_name"]) > 0:
                        street = _("Exit: ") + ("; ".join(sign["exit_name"]))
                elif street is not None and len(street)>0:
                    street = "; ".join(street)
                mn = copy.deepcopy(m)
                mn["street"] = street
                mnew.append(mn)
            route["maneuvers"] = mnew

    @property
    def results_qml_uri(self):
        """Return URI to router results QML file."""
        path = re.sub(r"\.json$", "_results.qml", self._path)
        return poor.util.path2uri(path)

    def route(self, locations, heading=None, params=None):
        """Find route and return its properties as a dictionary.

        `locations` is a list of either strings (usually addresses) or
        two-element tuples or lists of (x,y) coordinates. `heading` is
        the initial direction as an angle with zero being north,
        increasing clockwise, with 360 being north again. `heading` is
        mostly useful for rerouting, to avoid suggesting U-turns, and
        will be ``None`` in non-rerouting context. `params` can be
        used to specify a dictionary of router-specific parameters.

        """
        params = params or {}
        try:
            route = self._provider.route(locations, heading, params)
        except socket.timeout:
            return dict(error=True, message=_("Connection timed out"))
        except Exception:
            print("Routing failed:", file=sys.stderr)
            traceback.print_exc()
            return {}
        if isinstance(route, dict):
            route["provider"] = self.id
            self._process_route(route)
        if isinstance(route, list):
            for alternative in route:
                if isinstance(alternative, dict):
                    alternative["provider"] = self.id
                    self._process_route(alternative)
        return route

    @property
    def settings_qml_uri(self):
        """Return URI to router settings QML file or ``None``."""
        path = re.sub(r"\.json$", "_settings.qml", self._path)
        if not os.path.isfile(path): return None
        return poor.util.path2uri(path)
