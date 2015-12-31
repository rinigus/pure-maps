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
Listing nearby places using Nominatim.

This is an error tolerant Nominatim guide that falls back on a another
provider if the first one tried does not work.
"""

import poor

providers = ["mapquest_nominatim", "openstreetmap_nominatim"]

def nearby(query, near, radius, params):
    """Return a list of dictionaries of places matching `query`."""
    geocoder = poor.Geocoder("nominatim")
    if isinstance(near, str):
        results = geocoder.geocode(near, dict(limit=1))
        near = (results[0]["x"], results[0]["y"])
    x, y = near
    for i, provider in enumerate(providers):
        guide = poor.Guide(provider)
        # 'nearby' returns an empty list or a dict(error=True)
        # in case of an error.
        results = guide.nearby(query, near, radius, params)
        if results and isinstance(results, list):
            if i > 0:
                providers.insert(0, providers.pop(i))
            return x, y, results
    return x, y, []
