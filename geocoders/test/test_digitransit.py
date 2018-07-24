# -*- coding: utf-8 -*-

# Copyright (C) 2015 Osmo Salomaa
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


class TestModule(poor.test.TestCase):

    def setup_method(self, method):
        self.geocoder = poor.Geocoder("digitransit")

    def test_autocomplete(self):
        results = self.geocoder.autocomplete("apollonk", x=24.941, y=60.169)
        results = list(map(poor.AttrDict, results))
        assert results
        for result in results:
            assert result.label
            assert result.title
            assert result.x
            assert result.y

    def test_geocode(self):
        results = self.geocoder.geocode("kasarmitori, helsinki")
        results = list(map(poor.AttrDict, results))
        assert results
        for result in results:
            assert result.title
            assert result.x
            assert result.y
