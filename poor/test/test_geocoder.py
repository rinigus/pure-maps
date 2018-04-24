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

import poor.test


class TestGeocoder(poor.test.TestCase):

    def test___new____no(self):
        a = poor.Geocoder("digitransit")
        b = poor.Geocoder("opencage")
        assert a is not b

    def test___new____yes(self):
        a = poor.Geocoder("digitransit")
        b = poor.Geocoder("digitransit")
        assert a is b

    def test_geocode__geo_uri(self):
        geocoder = poor.Geocoder("default")
        point = geocoder.geocode("geo:60.169,24.941")
        assert point[0]["x"] == 24.941
        assert point[0]["y"] == 60.169

    def test_geocode__geo_uri_negative(self):
        geocoder = poor.Geocoder("default")
        point = geocoder.geocode("geo:-60.169,-24.941")
        assert point[0]["x"] == -24.941
        assert point[0]["y"] == -60.169

    def test_geocode__lat_lon_comma(self):
        geocoder = poor.Geocoder("default")
        point = geocoder.geocode("60.169,24.941")
        assert point[0]["x"] == 24.941
        assert point[0]["y"] == 60.169

    def test_geocode__lat_lon_comma_negative(self):
        geocoder = poor.Geocoder("default")
        point = geocoder.geocode("-60.169,-24.941")
        assert point[0]["x"] == -24.941
        assert point[0]["y"] == -60.169

    def test_geocode__lat_lon_space(self):
        geocoder = poor.Geocoder("default")
        point = geocoder.geocode("60.169 24.941")
        assert point[0]["x"] == 24.941
        assert point[0]["y"] == 60.169

    def test_geocode__lat_lon_space_negative(self):
        geocoder = poor.Geocoder("default")
        point = geocoder.geocode("-60.169 -24.941")
        assert point[0]["x"] == -24.941
        assert point[0]["y"] == -60.169
