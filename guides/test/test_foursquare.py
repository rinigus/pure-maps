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
        self.guide = poor.Guide("foursquare")

    def test_autocomplete_type(self):
        results = self.guide.autocomplete_type("rest")
        results = list(map(poor.AttrDict, results))
        assert results
        for result in results:
            assert result.label

    def test_nearby(self):
        results = self.guide.nearby("restaurant", "tapiola, espoo", 1000)
        results = list(map(poor.AttrDict, results))
        assert results
        for result in results:
            assert result.title
            assert result.x
            assert result.y
