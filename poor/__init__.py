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

"""An application to display maps and stuff."""

__version__ = "1.1"

try:
    import pyotherside
except ImportError:
    import sys
    # Allow testing Python backend alone.
    print("PyOtherSide not found, continuing anyway!",
          file=sys.stderr)
    class pyotherside:
        def atexit(*args): pass
        def send(*args): pass
    sys.modules["pyotherside"] = pyotherside()

from poor.paths import CACHE_HOME_DIR
from poor.paths import CONFIG_HOME_DIR
from poor.paths import DATA_DIR
from poor.paths import DATA_HOME_DIR
from poor.paths import LOCALE_DIR
from poor import i18n
from poor import util
from poor import http
from poor import polysimp
from poor import storage
from poor.attrdict import AttrDict
from poor.config import ConfigurationStore
conf = ConfigurationStore()
from poor.map import Map
from poor.geocoder import Geocoder
from poor.guide import Guide
from poor.history import HistoryManager
from poor.router import Router
from poor.voice import VoiceGenerator
from poor.narrative import Narrative
from poor.application import Application

assert Application
assert AttrDict
assert CACHE_HOME_DIR
assert CONFIG_HOME_DIR
assert ConfigurationStore
assert DATA_DIR
assert DATA_HOME_DIR
assert Geocoder
assert Guide
assert HistoryManager
assert http
assert i18n
assert LOCALE_DIR
assert Map
assert Narrative
assert polysimp
assert Router
assert storage
assert util
assert VoiceGenerator

def main():
    """Initialize application."""
    conf.read()
    global app
    app = Application()
