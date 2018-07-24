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

"""Attribute dictionary of configuration values."""

import copy
import os
import poor
import sys
import traceback

__all__ = ("ConfigurationStore",)

DEFAULTS = {
    "auto_center": False,
    "auto_rotate": False,
    "basemap": "mapbox_streets",
    "center": [13.0, 49.0],
    "geocoder": "opencage",
    "guide": "foursquare",
    # "always", "navigating" or "never".
    "keep_alive": "navigating",
    # "none", "car", "bicycle", "foot"
    "map_matching_when_idle": "none",
    "map_matching_when_navigating": False,
    "map_scale": 1.0,
    "reroute": True,
    "router": "mapquest_open",
    "show_narrative": True,
    "tilt_when_navigating": True,
    # "metric", "american" or "british".
    "units": "metric",
    # "male" or "female"
    "voice_gender": "male",
    "voice_navigation": False,
    "zoom": 3.0,
}


class ConfigurationStore(poor.AttrDict):

    """Attribute dictionary of configuration values."""

    def __init__(self):
        """Initialize a :class:`Configuration` instance."""
        poor.AttrDict.__init__(self, copy.deepcopy(DEFAULTS))

    def add(self, option, item):
        """Add `item` to the value of `option`."""
        root, name = self._split_option(option)
        if item in root[name]: return
        root[name].append(copy.deepcopy(item))

    def _coerce(self, value, ref):
        """Coerce type of `value` to match `ref`."""
        if isinstance(value, list) and ref:
            return [self._coerce(x, ref[0]) for x in value]
        return type(ref)(value)

    def contains(self, option, item):
        """Return ``True`` if the value of `option` contains `item`."""
        root, name = self._split_option(option)
        return item in root[name]

    def get(self, option):
        """Return the value of `option`."""
        root = self
        for section in option.split(".")[:-1]:
            root = root[section]
        name = option.split(".")[-1]
        return copy.deepcopy(root[name])

    def get_default(self, option):
        """Return the default value of `option`."""
        root = DEFAULTS
        for section in option.split(".")[:-1]:
            root = root[section]
        name = option.split(".")[-1]
        return copy.deepcopy(root[name])

    def _migrate(self, values):
        """Migrate configuration values from earlier versions."""
        values = copy.deepcopy(values)
        try:
            version = values.get("version", "0.0.0").strip()
            version = tuple(map(int, version.split(".")))[:2]
        except Exception:
            # Run all migrations if version malformed.
            traceback.print_exc()
            version = (0, 0)
        # See Poor Maps for examples of migrations and their unit tests.
        # https://github.com/otsaloma/poor-maps/blob/master/poor/config.py
        return values

    def read(self, path=None):
        """Read values of options from JSON file at `path`."""
        path = path or os.path.join(poor.CONFIG_HOME_DIR, "whogo-maps.json")
        if not os.path.isfile(path): return
        values = {}
        with poor.util.silent(Exception, tb=True):
            values = poor.util.read_json(path)
        if not values: return
        values = self._migrate(values)
        self._update(values)

    def _register(self, values, root=None, defaults=None):
        """Add entries for `values` if missing."""
        if root is None: root = self
        if defaults is None: defaults = DEFAULTS
        for name, value in values.items():
            if isinstance(value, dict):
                self._register(values[name],
                               root.setdefault(name, poor.AttrDict()),
                               defaults.setdefault(name, {}))
                continue
            # Do not change values if they already exist.
            root.setdefault(name, copy.deepcopy(value))
            defaults.setdefault(name, copy.deepcopy(value))

    def register_guide(self, name, values):
        """Add configuration `values` for guide `name` if missing."""
        self._register({"guides": {name: values}})

    def register_router(self, name, values):
        """Add configuration `values` for router `name` if missing."""
        self._register({"routers": {name: values}})

    def remove(self, option, item):
        """Remove `item` from the value of `option`."""
        root, name = self._split_option(option)
        if item not in root[name]: return
        root[name].remove(item)

    def set(self, option, value):
        """Set the value of `option`."""
        root, name = self._split_option(option, create=True)
        root[name] = copy.deepcopy(value)

    def _split_option(self, option, create=False):
        """Split dotted option to dictionary and option name."""
        root = self
        for section in option.split(".")[:-1]:
            if create and section not in root:
                # Create missing hierarchies.
                root[section] = poor.AttrDict()
            root = root[section]
        name = option.split(".")[-1]
        return root, name

    def _update(self, values, root=None, defaults=None, path=()):
        """Load values of options after validation."""
        if root is None: root = self
        if defaults is None: defaults = DEFAULTS
        for name, value in values.items():
            if isinstance(value, dict):
                self._update(value,
                             root.setdefault(name, poor.AttrDict()),
                             defaults.setdefault(name, {}),
                             path + (name,))
                continue
            try:
                if name in defaults:
                    # Be liberal, but careful in what to accept.
                    value = self._coerce(value, defaults[name])
                root[name] = copy.deepcopy(value)
            except Exception as error:
                full_name = ".".join(path + (name,))
                print("Discarding bad option-value pair {}, {}: {}"
                      .format(repr(full_name), repr(value), str(error)),
                      file=sys.stderr)

    def write(self, path=None):
        """Write values of options to JSON file at `path`."""
        path = path or os.path.join(poor.CONFIG_HOME_DIR, "whogo-maps.json")
        out = copy.deepcopy(self)
        # Make sure no obsolete top-level options remain.
        names = list(DEFAULTS.keys()) + ["guides", "routers"]
        for name in list(out.keys()):
            if name not in names:
                del out[name]
        out["version"] = poor.__version__
        with poor.util.silent(Exception, tb=True):
            poor.util.write_json(out, path)
