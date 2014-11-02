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

import importlib.machinery
import os
import poor.test

path = os.path.join(os.path.dirname(__file__), "..", "slippy.py")
loader = importlib.machinery.SourceFileLoader("slippy", path)
slippy = loader.load_module("slippy")


class TestModule(poor.test.TestCase):

    def test_deg2num(self):
        xtile, ytile = slippy.deg2num(24.94, 60.17, 14)
        assert xtile == 9327
        assert ytile == 4742

    def test_num2deg(self):
        x, y = slippy.num2deg(9327, 4742, 14)
        assert abs(x - 24.939) < 0.001
        assert abs(y - 60.174) < 0.001
