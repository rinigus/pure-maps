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

__version__ = "0.4"

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

from poor.paths import *
from poor import util
from poor import polysimp
from poor import storage
from poor.config import *
conf = ConfigurationStore()
from poor.tilecollection import *
from poor.tilesource import *
from poor.geocoder import *
from poor.router import *
from poor.history import *
from poor.application import *

def main():
    """Initialize application."""
    import pyotherside
    conf.read()
    pyotherside.atexit(conf.write)
    global app
    app = Application()
    pyotherside.atexit(app.history.write)
