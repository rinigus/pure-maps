# -*- coding: utf-8 -*-

# Copyright (C) 2018 Rinigus
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

"""
Routing using GPX track
"""

import poor

CONF_DEFAULTS = {
    "file": "",
    "type": "car"
}

def route(fm, to, heading, params):
    """Find route and return its properties as a dictionary."""
    fname = poor.conf.routers.gpx.file
    ctype = poor.conf.routers.gpx.type
    x, y = poor.util.read_gpx(fname)
    maneuvers = [
        dict( x=x[0], y=y[0],
              icon="depart",
              narrative=""),
        dict( x=x[-1], y=y[-1],
              icon="arrive",
              narrative="")
    ]
    route = dict(x=x, y=y, maneuvers=maneuvers, mode=ctype)
    return route
