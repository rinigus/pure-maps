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

import os
import poor.test
import tempfile


class TestModule(poor.test.TestCase):

    def test_atomic_open__file_exists(self):
        text = "testing\ntesting\n"
        handle, path = tempfile.mkstemp()
        with poor.util.atomic_open(path, "w") as f:
            f.write(text)
        assert open(path, "r").read() == text
        os.remove(path)

    def test_atomic_open__new_file(self):
        text = "testing\ntesting\n"
        handle, path = tempfile.mkstemp()
        os.remove(path)
        with poor.util.atomic_open(path, "w") as f:
            f.write(text)
        assert open(path, "r").read() == text
        os.remove(path)

    def test_calculate_bearing(self):
        # From Helsinki to Lissabon.
        bearing = poor.util.calculate_bearing(24.94, 60.17, -9.14, 38.72)
        assert round(bearing) == 240

    def test_calculate_distance(self):
        # From Helsinki to Lissabon.
        dist = poor.util.calculate_distance(24.94, 60.17, -9.14, 38.72)
        assert round(dist/1000) == 3361

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

    def test_find_closest(self):
        xs = [24, 25, 26]
        ys = [60, 61, 62]
        index = poor.util.find_closest(xs, ys, 26, 60)
        assert index == 1

    def test_format_distance_american(self):
        assert poor.util.format_distance_american(123, 2) == "120 ft"
        assert poor.util.format_distance_american(6000, 1) == "1 mi"

    def test_format_distance_british(self):
        assert poor.util.format_distance_british(123, 2) == "120 yd"
        assert poor.util.format_distance_british(2000, 1) == "1 mi"

    def test_format_distance_metric(self):
        assert poor.util.format_distance_metric(123, 2) == "120 m"
        assert poor.util.format_distance_metric(1234, 1) == "1 km"

    def test_requirement_found(self):
        assert poor.util.requirement_found("sh")
        assert poor.util.requirement_found("/bin/sh")
        assert not poor.util.requirement_found("fgbklp")
        assert not poor.util.requirement_found("/bin/fgbklp")

    def test_round_distance__metric(self):
        assert poor.util.round_distance(1234.56, 1) == 1000
        assert poor.util.round_distance(1234.56, 2) == 1200
        assert poor.util.round_distance(123.456, 1) == 100
        assert poor.util.round_distance(123.456, 2) == 120
        assert poor.util.round_distance(12.3456, 1) == 10
        assert poor.util.round_distance(12.3456, 2) == 12
        assert poor.util.round_distance(1.23456, 1) == 1
        assert poor.util.round_distance(1.23456, 2) == 1

    def test_siground(self):
        assert poor.util.siground(123.456, 1) == 100
        assert poor.util.siground(123.456, 2) == 120
        assert poor.util.siground(123.456, 3) == 123
        assert poor.util.siground(123.456, 4) == 123.5
        assert poor.util.siground(123.456, 5) == 123.46
        assert poor.util.siground(123.456, 6) == 123.456
