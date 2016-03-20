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

__all__ = ("ConfigurationStore",)

DEFAULTS = {
    "allow_tile_download": True,
    "auto_center": False,
    "auto_rotate": False,
    "basemap": "mapbox_streets_@2x",
    "cache_max_age": 30, # days
    "center": [0.0, 0.0],
    "download_timeout": 10, # seconds
    "geocoder": "nominatim",
    "guide": "foursquare",
    # 'always', 'navigating' or 'never'.
    "keep_alive": "navigating",
    "overlays": [],
    "router": "mapquest_open",
    "show_routing_narrative": True,
    # 'metric', 'american' or 'british'.
    "units": "metric",
    "zoom": 15,
}


class AttrDict(dict):

    """Dictionary with attribute access to keys."""

    def __init__(self, *args, **kwargs):
        """Initialize an :class:`AttrDict` instance."""
        dict.__init__(self, *args, **kwargs)
        self.__dict__ = self


class ConfigurationStore(AttrDict):

    """
    Attribute dictionary of configuration values.

    Options to most methods can be given as a dotted string,
    e.g. 'routers.mycoolrouter.type'.
    """

    def __init__(self):
        """Initialize a :class:`Configuration` instance."""
        AttrDict.__init__(self, copy.deepcopy(DEFAULTS))

    def _coerce(self, value, ref):
        """Coerce type of `value` to match `ref`."""
        # XXX: No coercion is done if ref is an empty list!
        if isinstance(value, list) and ref:
            return [self._coerce(x, ref[0]) for x in value]
        return type(ref)(value)

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
        if not "basemap" in values and "tilesource" in values:
            # 'cache_max_age' added in 0.14, value changed in 0.18.
            # Upgrading from < 0.14 to 0.18 should set the old implicit
            # default of never removing tiles, valued as 36500.
            values.setdefault("cache_max_age", 36500)
            # 'tilesource' renamed to 'basemap' in 0.18.
            values["basemap"] = values.pop("tilesource")
        if values.get("geocoder", "").endswith("_nominatim"):
            # 'mapquest_nominatim' and 'openstreetmap_nominatim'
            # hidden in 0.22 in favor of 'nominatim'.
            values["geocoder"] = "nominatim"
        if values.get("guide", "").endswith("_nominatim"):
            # 'mapquest_nominatim' and 'openstreetmap_nominatim'
            # hidden in 0.22 in favor of 'nominatim'.
            values["guide"] = "nominatim"
        return values

    def read(self, path=None):
        """Read values of options from JSON file at `path`."""
        if path is None:
            path = os.path.join(poor.CONFIG_HOME_DIR, "poor-maps.json")
        if not os.path.isfile(path): return
        values = {}
        with poor.util.silent(Exception):
            values = poor.util.read_json(path)
        if not values: return
        values = self._uncomment(values)
        values = self._migrate(values)
        self._update(values)

    def _register(self, values, root=None, defaults=None):
        """Add entries for `values` if missing."""
        if root is None: root = self
        if defaults is None: defaults = DEFAULTS
        for name, value in values.items():
            if isinstance(value, dict):
                self._register(values[name],
                               root.setdefault(name, AttrDict()),
                               defaults.setdefault(name, {}))
                continue
            # Do not change values if they already exist.
            root.setdefault(name, copy.deepcopy(value))
            defaults.setdefault(name, copy.deepcopy(value))

    def register_guide(self, name, values):
        """
        Add configuration `values` for guide `name` if missing.

        Calling ``register_guide("foo", {"type": 1})`` will make type
        available as ``poor.conf.guides.foo.type``.
        """
        self._register({"guides": {name: values}})

    def register_router(self, name, values):
        """
        Add configuration `values` for router `name` if missing.

        Calling ``register_router("foo", {"type": 1})`` will make type
        available as ``poor.conf.routers.foo.type``.
        """
        self._register({"routers": {name: values}})

    def set(self, option, value):
        """Set the value of `option`."""
        root, name = self._split_option(option, create=True)
        root[name] = copy.deepcopy(value)

    def set_add(self, option, item):
        """Add `item` to `option` of type set."""
        root, name = self._split_option(option)
        if not item in root[name]:
            root[name].append(copy.deepcopy(item))

    def set_contains(self, option, item):
        """Return ``True`` if `option` of type set contains `item`."""
        root, name = self._split_option(option)
        return item in root[name]

    def set_remove(self, option, item):
        """Remove `item` from `option` of type set."""
        root, name = self._split_option(option)
        if item in root[name]:
            root[name].remove(item)

    def _split_option(self, option, create=False):
        """Split dotted option to dictionary and option name."""
        root = self
        for section in option.split(".")[:-1]:
            if create and not section in root:
                # Create missing hierarchies.
                root[section] = AttrDict()
            root = root[section]
        name = option.split(".")[-1]
        return root, name

    def _uncomment(self, values):
        """Uncomment names of options in `values`."""
        # Prior to 0.18 options at default value were commented out.
        # Uncomment these to avoid disruptive changes.
        values = copy.deepcopy(values)
        for name, value in list(values.items()):
            if name.startswith("#"):
                del values[name]
                name = name[1:].strip()
                if not name in values:
                    values[name] = value
            if isinstance(value, dict):
                values[name] = self._uncomment(value)
        return values

    def _update(self, values, root=None, defaults=None, path=()):
        """Load values of options after validation."""
        if root is None: root = self
        if defaults is None: defaults = DEFAULTS
        for name, value in values.items():
            if isinstance(value, dict):
                self._update(value,
                             root.setdefault(name, AttrDict()),
                             defaults.setdefault(name, {}),
                             (path + (name,)))
                continue
            try:
                if name in defaults:
                    # Be liberal, but careful in what to accept.
                    value = self._coerce(value, defaults[name])
                root[name] = copy.deepcopy(value)
            except Exception as error:
                full_name = ".".join(path + (name,))
                print("Discarding bad option-value pair ({}, {}): {}"
                      .format(repr(full_name), repr(value), str(error)),
                      file=sys.stderr)

    def write(self, path=None):
        """Write values of options to JSON file at `path`."""
        if path is None:
            path = os.path.join(poor.CONFIG_HOME_DIR, "poor-maps.json")
        out = copy.deepcopy(self)
        # Make sure no obsolete top-level options remain.
        names = list(DEFAULTS.keys()) + ["guides", "routers"]
        for name in list(out.keys()):
            if not name in names:
                del out[name]
        out["version"] = poor.__version__
        with poor.util.silent(Exception):
            poor.util.write_json(out, path)
