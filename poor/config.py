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
import json
import os
import poor
import sys

__all__ = ("ConfigurationStore",)

DEFAULTS = {
    "auto_center": False,
    "center": [24.941, 60.169],
    "download_timeout": 10,
    "tilesource": "openstreetmap",
    "zoom": 15,
}


class AttrDict(dict):

    """Dictionary with attribute access to keys."""

    def __init__(self, *args, **kwargs):
        """Initialize an :class:`AttrDict` instance."""
        dict.__init__(self, *args, **kwargs)
        self.__dict__ = self


class ConfigurationStore(AttrDict):

    """Attribute dictionary of configuration values."""

    def __init__(self):
        """Initialize a :class:`Configuration` instance."""
        AttrDict.__init__(self, copy.deepcopy(DEFAULTS))

    def _coerce(self, value, ref):
        """Coerce type of `value` to match `ref`."""
        if isinstance(value, list):
            return [self._coerce(x, ref[0]) for x in value]
        return type(ref)(value)

    def get_default(self, name):
        """Get the default value of option."""
        return copy.deepcopy(DEFAULTS[name])

    def read(self, path=None):
        """Read values of options from JSON file at `path`."""
        if path is None:
            path = os.path.join(poor.CONFIG_HOME_DIR, "poor-maps.json")
        if not os.path.isfile(path): return
        try:
            with open(path, "r", encoding="utf_8") as f:
                values = json.load(f)
        except Exception as error:
            return print("Failed to read file {}: {}"
                         .format(repr(path), str(error)),
                         file=sys.stderr)

        for name, value in values.items():
            # Ignore options commented out.
            if name.startswith("#"): continue
            try:
                # Be liberal, but careful in what to accept.
                self[name] = self._coerce(value, DEFAULTS[name])
            except Exception as error:
                print("Discarding bad option-value pair ({}, {}): {}"
                      .format(repr(name), repr(value), str(error)),
                      file=sys.stderr)

    def set(self, option, value):
        """Set the value of `option`."""
        self[option] = copy.deepcopy(value)

    def write(self, path=None):
        """Write values of options to JSON file at `path`."""
        if path is None:
            path = os.path.join(poor.CONFIG_HOME_DIR, "poor-maps.json")
        directory = os.path.dirname(path)
        directory = poor.util.makedirs(directory)
        if directory is None: return
        out = {}
        for name, value in self.items():
            if value == DEFAULTS[name]:
                # Comment out values still at default.
                name = "# {}".format(name)
            out[name] = value
        try:
            with open(path, "w", encoding="utf_8") as f:
                json.dump(out, f, ensure_ascii=False, indent=4, sort_keys=True)
        except Exception as error:
            print("Failed to write file {}: {}"
                  .format(repr(path), str(error)),
                  file=sys.stderr)
