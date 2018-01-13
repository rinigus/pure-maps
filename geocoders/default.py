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
Geocoding using a priority list of providers.

This is an error tolerant geocoder that falls back on a another provider
if the first one tried does not work.
"""

import poor

providers = ["opencage", "photon"]

def geocode(query, params):
    """Return a list of dictionaries of places matching `query`."""
    for i, provider in enumerate(providers):
        geocoder = poor.Geocoder(provider)
        # 'geocode' returns an empty list or a dict(error=True)
        # in case of no results or an error.
        results = geocoder.geocode(query, params)
        if results and isinstance(results, list):
            if i > 0: providers.insert(0, providers.pop(i))
            return results
    # All providers failed.
    return []
