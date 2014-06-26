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
Geocoding using Nominatim.

This is an error tolerant Nominatim geocoder that falls back on a another
provider if the first one tried does not work. This is especially useful for
routers that take coordinates, and thus need pre-geocoding, but where the user
should not be bothered with which geocoder is used and thus cannot change it
in case of an error situation.
"""

import poor

providers = ["mapquest_nominatim", "openstreetmap_nominatim"]


def geocode(query):
    """Return a list of dictionaries of places matching `query`."""
    for i, provider in enumerate(providers):
        geocoder = poor.Geocoder(provider)
        # 'geocode' returns an empty list in case of an error.
        results = geocoder.geocode(query)
        if results:
            if i > 0:
                providers.insert(0, providers.pop(i))
            return results
    return []
