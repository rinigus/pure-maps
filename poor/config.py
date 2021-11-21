# -*- coding: utf-8 -*-

# Copyright (C) 2014 Osmo Salomaa, 2018-2020 Rinigus
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
import pyotherside

__all__ = ("ConfigurationStore",)

_default_basemap = "MapTiler"
_default_geocoder = "photon"
_default_guide = "foursquare"
_default_router = "stadiamaps"
_default_profile = "online"

DEFAULTS = {
    "auto_center": False,
    "auto_complete_geo": True,
    "auto_rotate": False,
    "auto_rotate_when_navigating": True,
    "basemap_auto_light": "none",
    "basemap_auto_mode": True,
    "basemap_fallback": "OpenTopoMap", # should work without any API keys or API keys are always added
    "basemap_lang": "local",
    "basemap_light": "",
    "basemap_type": "",
    "basemap_vehicle": "",
    "compass_use": False,
    "center": [13.0, 49.0],
    "devel_coordinate_center": False,
    "devel_show_z": False,
    "follow_me_transport_mode": "foot",
    "font_provider": "mapbox",
    "route_page_show_destinations_help": True,
    # "always", "navigating" or "never".
    "keep_alive": "navigating",
    "keep_alive_background": "never",
    # "none", "car", "bicycle", "foot"
    "map_matching_when_idle": "none",
    "map_matching_when_navigating": False,
    "map_mode_auto_switch_time": 30,
    "map_mode_clean_on_start": False,
    "map_mode_clean_show_basemap": False,
    "map_mode_clean_show_center": False,
    "map_mode_clean_show_compass": False,
    "map_mode_clean_show_geocode": False,
    "map_mode_clean_show_menu_button": True,
    "map_mode_clean_show_meters": False,
    "map_mode_clean_show_navigate": False,
    "map_mode_clean_show_navigation_start_pause": False,
    "map_mode_clean_show_navigation_clear": False,
    "map_mode_clean_show_scale": False,
    "map_scale": 1.0,
    "map_scale_navigation_bicycle": 2.0,
    "map_scale_navigation_car": 2.0,
    "map_scale_navigation_foot": 1.0,
    "map_scale_navigation_transit": 1.0,
    "map_zoom_auto_time": 60.0,
    "map_zoom_auto_when_navigating": False,
    "map_zoom_auto_zero_speed_z": 16.0,
    "navigation_horizontal_accuracy": 15.0,
    "poi_list_show_bookmarked": False,
    "profile": _default_profile,
    "profiles": {
        "mixed": {
            "basemap": _default_basemap,
            "geocoder": _default_geocoder,
            "guide": _default_guide,
            "router": _default_router
        },
        "online": {
            "basemap": _default_basemap,
            "geocoder": _default_geocoder,
            "guide": _default_guide,
            "router": _default_router
        },
        "offline": {
            "basemap": "OSM Scout",
            "geocoder": "osmscout",
            "guide": "osmscout",
            "router": "osmscout"
        },
        "HERE": {
            "basemap": "HERE",
            "geocoder": "here",
            "guide": _default_guide,
            "router": "here"
        }
     },
    "reroute": True,
    "share_address": True,
    "share_googlemaps": False,
    "share_osm": True,
    "show_narrative": True,
    "show_navigation_sign": True,
    # "always", "exceeding", "never"
    "show_speed_limit": "always",
    "smooth_position_animation_when_navigating": False,
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
        self._emit()

    @property
    def basemap(self):
        """Return `basemap` corresponding to the current profile"""
        return self.profiles[self.profile].basemap

    def _coerce(self, value, ref):
        """Coerce type of `value` to match `ref`."""
        if isinstance(value, list) and ref:
            return [self._coerce(x, ref[0]) for x in value]
        return type(ref)(value)

    def contains(self, option, item):
        """Return ``True`` if the value of `option` contains `item`."""
        root, name = self._split_option(option)
        return item in root[name]

    def _emit(self):
        pyotherside.send('config.changed')

    @property
    def geocoder(self):
        """Return `geocoder` corresponding to the current profile"""
        return self.profiles[self.profile].geocoder

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
        if option in ("basemap", "geocoder", "guide", "router"):
            return copy.deepcopy(root["profiles"][self.profile][option])
        for section in option.split(".")[:-1]:
            root = root[section]
        name = option.split(".")[-1]
        return copy.deepcopy(root[name])

    def get_all(self):
        return self
    
    @property
    def guide(self):
        """Return `guide` corresponding to the current profile"""
        return self.profiles[self.profile].guide

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
        if version < (1, 10):
            for k in ["basemap", "geocoder", "guide", "router"]:
                if k in values: del values[k]
        return values

    def read(self, path=None):
        """Read values of options from JSON file at `path`."""
        path = path or os.path.join(poor.CONFIG_HOME_DIR, "pure-maps.json")
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

    def register_keys(self, values):
        """Add configuration `values` for keys if missing."""
        self._register({"keys": values})

    def register_licenses(self, values):
        """Add configuration `values` for licenses if missing."""
        self._register({"licenses": values})

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
        self._emit()

    @property
    def router(self):
        """Return `router` corresponding to the current profile"""
        return self.profiles[self.profile].router

    def set(self, option, value):
        """Set the value of `option`."""
        root, name = self._split_option(option, create=True)
        root[name] = copy.deepcopy(value)
        self._emit()

    def set_basemap(self, value):
        """Set basemap corresponding to the current profile"""
        self._set_profiled("basemap", value)

    def set_geocoder(self, value):
        """Set geocoder corresponding to the current profile"""
        self._set_profiled("geocoder", value)

    def set_guide(self, value):
        """Set guide corresponding to the current profile"""
        self._set_profiled("guide", value)

    def set_profile(self, value):
        """Set guide corresponding to the current profile"""
        if value not in DEFAULTS["profiles"]:
            print("Trying to set profile to unavailable value", value, ". Using the default profile instead")
            value = DEFAULTS["profile"]
            #raise ValueError("Profile not supported", value)
        self.set("profile", value)
        
    def set_router(self, value):
        """Set `router` corresponding to the current profile"""
        self._set_profiled("router", value)

    def _set_profiled(self, option, value):
        """Set the value of `option` in the current profile."""
        self.profiles[self.profile][option] = copy.deepcopy(value)

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
        self._emit()

    def write(self, path=None):
        """Write values of options to JSON file at `path`."""
        path = path or os.path.join(poor.CONFIG_HOME_DIR, "pure-maps.json")
        out = copy.deepcopy(self)
        # Make sure no obsolete top-level options remain.
        names = list(DEFAULTS.keys()) + ["guides", "routers"]
        for name in list(out.keys()):
            if name not in names:
                del out[name]
        out["version"] = poor.__version__
        with poor.util.silent(Exception, tb=True):
            poor.util.write_json(out, path)
