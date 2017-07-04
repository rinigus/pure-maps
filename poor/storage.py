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

"""Reading and writing map objects from and to JSON files."""

import os
import poor


def read_maneuvers(path=None):
    """Read a list of maneuvers from JSON file at `path`."""
    path = path or os.path.join(poor.CONFIG_HOME_DIR, "maneuvers.json")
    if os.path.isfile(path):
        with poor.util.silent(Exception, tb=True):
            return poor.util.read_json(path)
    return []

def read_pois(path=None):
    """Read a list of POIs from JSON file at `path`."""
    path = path or os.path.join(poor.CONFIG_HOME_DIR, "pois.json")
    if os.path.isfile(path):
        with poor.util.silent(Exception, tb=True):
            return poor.util.read_json(path)
    return []

def read_route(path=None):
    """Read a route dictionary from JSON file at `path`."""
    path = path or os.path.join(poor.CONFIG_HOME_DIR, "route.json")
    if os.path.isfile(path):
        with poor.util.silent(Exception, tb=True):
            return poor.util.read_json(path)
    return {}

def write_maneuvers(maneuvers, path=None):
    """Write a list of maneuvers to JSON file at `path`."""
    path = path or os.path.join(poor.CONFIG_HOME_DIR, "maneuvers.json")
    with poor.util.silent(Exception, tb=True):
        poor.util.write_json(maneuvers, path)

def write_pois(pois, path=None):
    """Write a list of POIs to JSON file at `path`."""
    path = path or os.path.join(poor.CONFIG_HOME_DIR, "pois.json")
    with poor.util.silent(Exception, tb=True):
        poor.util.write_json(pois, path)

def write_route(route, path=None):
    """Write a route dictionary to JSON file at `path`."""
    path = path or os.path.join(poor.CONFIG_HOME_DIR, "route.json")
    with poor.util.silent(Exception, tb=True):
        poor.util.write_json(route, path)
