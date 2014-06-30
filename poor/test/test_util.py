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


class TestModule(poor.test.TestCase):

    def test_calculate_bearing(self):
        # From Helsinki to Lissabon.
        bearing = poor.util.calculate_bearing(24.94, 60.17, -9.14, 38.72)
        assert round(bearing) == 240

    def test_calculate_distance(self):
        # From Helsinki to Lissabon.
        dist = poor.util.calculate_distance(24.94, 60.17, -9.14, 38.72)
        assert round(dist) == 3361

    def test_decode_epl(self):
        # Values from the official example.
        # http://developers.google.com/maps/documentation/utilities/polylinealgorithm
        x, y = poor.util.decode_epl("_p~iF~ps|U_ulLnnqC_mqNvxq`@")
        assert len(x) == 3
        assert len(y) == 3
        assert x[0] == -120.200
        assert x[1] == -120.950
        assert x[2] == -126.453
        assert y[0] ==   38.500
        assert y[1] ==   40.700
        assert y[2] ==   43.252

    def test_deg2num(self):
        xtile, ytile = poor.util.deg2num(24.94, 60.17, 14)
        assert xtile == 9327
        assert ytile == 4742

    def test_num2deg(self):
        x, y = poor.util.num2deg(9327, 4742, 14)
        assert abs(x - 24.939) < 0.001
        assert abs(y - 60.174) < 0.001
