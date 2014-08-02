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

"""
Listing nearby places using OpenStreetMap Nominatim.

http://wiki.openstreetmap.org/wiki/Nominatim
http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy
"""

import poor

def nearby(query, near, radius, params):
    """Return a list of dictionaries of places matching `query`."""
    geocoder = poor.Geocoder("openstreetmap_nominatim")
    if isinstance(near, str):
        results = geocoder.geocode(near, dict(limit=1))
        near = (results[0]["x"], results[0]["y"])
    x, y = near
    x_m_per_deg = poor.util.calculate_distance(x, y, x+1, y)
    y_m_per_deg = poor.util.calculate_distance(x, y, x, y+1)
    results = geocoder.geocode(query,
                               dict(xmin=x-radius/x_m_per_deg,
                                    xmax=x+radius/x_m_per_deg,
                                    ymin=y-radius/y_m_per_deg,
                                    ymax=y+radius/y_m_per_deg,
                                    bounded=True,
                                    limit=50))

    results = poor.util.sorted_by_distance(results, x, y)
    return x, y, results
