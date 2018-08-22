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

"""Standard paths to files."""

import os

__all__ = ("CACHE_HOME_DIR", "CONFIG_HOME_DIR", "DATA_DIR", "DATA_HOME_DIR", "LOCALE_DIR")

XDG_CACHE_HOME = os.path.expanduser(os.getenv("XDG_CACHE_HOME", "~/.cache"))
XDG_CONFIG_HOME = os.path.expanduser(os.getenv("XDG_CONFIG_HOME", "~/.config"))
XDG_DATA_HOME = os.path.expanduser(os.getenv("XDG_DATA_HOME", "~/.local/share"))

CACHE_HOME_DIR = os.path.join(XDG_CACHE_HOME, "harbour-pure-maps")
CONFIG_HOME_DIR = os.path.join(XDG_CONFIG_HOME, "harbour-pure-maps")
DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DATA_HOME_DIR = os.path.join(XDG_DATA_HOME, "harbour-pure-maps")
LOCALE_DIR = "/usr/share/harbour-pure-maps/locale"
