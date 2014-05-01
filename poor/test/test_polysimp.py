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

    def test_simplify__max_length(self):
        x = [0, 1, 8]
        y = [0, 0, 0]
        xout, yout = poor.polysimp.simplify(x, y, tol=1, max_length=4)
        assert xout == [0, 4, 8]
        assert yout == [0, 0, 0]

    def test_simplify__nmax(self):
        x = [0, 1, 1, 2, 2]
        y = [0, 0, 1, 1, 2]
        xout, yout = poor.polysimp.simplify(x, y, tol=0.1, nmax=2)
        assert xout == [0, 2]
        assert yout == [0, 2]

    def test_simplify__no(self):
        x = [0, 1, 1, 2, 2]
        y = [0, 0, 1, 1, 2]
        xout, yout = poor.polysimp.simplify(x, y, tol=0.1)
        assert xout == x
        assert yout == y

    def test_simplify__yes(self):
        x = [0, 2, 4, 6, 8]
        y = [0, 1, 0, 1, 0]
        xout, yout = poor.polysimp.simplify(x, y, tol=1.1)
        assert xout == [0, 8]
        assert yout == [0, 0]
