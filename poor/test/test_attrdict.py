# -*- coding: utf-8 -*-

# Copyright (C) 2017 Osmo Salomaa
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


class TestAttrDict(poor.test.TestCase):

    def setup_method(self, method):
        self.dct = poor.AttrDict(a=1,
                                 b=[1, 2, 3],
                                 c=dict(a=1, b=2, c=3))

    def test___init____nested(self):
        assert isinstance(self.dct.c, poor.AttrDict)

    def test___coerce(self):
        self.dct.d = [dict(e=1), dict(f=1)]
        assert isinstance(self.dct.d[0], poor.AttrDict)
        assert isinstance(self.dct.d[1], poor.AttrDict)

    def test___delattr__(self):
        del self.dct.a
        assert not hasattr(self.dct, "a")
        assert "a" not in self.dct

    def test___getattr__(self):
        assert self.dct.a is self.dct["a"]
        assert self.dct.b is self.dct["b"]
        assert self.dct.c is self.dct["c"]

    def test___setattr__(self):
        self.dct.d = [100, 101]
        assert self.dct.d == [100, 101]
        assert self.dct["d"] == [100, 101]
        assert self.dct.d is self.dct["d"]

    def test___setattr____nested(self):
        self.dct.d = dict(e=1, f=dict(g=1))
        assert isinstance(self.dct.d, poor.AttrDict)
        assert isinstance(self.dct.d.f, poor.AttrDict)

    def test___setitem__(self):
        self.dct["d"] = 100
        assert self.dct["d"] == 100
        assert self.dct.d == 100

    def test_setdefault(self):
        self.dct.setdefault("d", 100)
        assert self.dct.d == 100
        self.dct.setdefault("d", 101)
        assert self.dct.d == 100

    def test_setdefault__nested(self):
        self.dct.setdefault("d", dict(e=1, f=dict(g=1)))
        assert isinstance(self.dct.d, poor.AttrDict)
        assert isinstance(self.dct.d.f, poor.AttrDict)

    def test_update(self):
        self.dct.update(a=100)
        assert self.dct.a == 100

    def test_update__nested(self):
        self.dct.update(d=dict(e=1, f=dict(g=1)))
        assert isinstance(self.dct.d, poor.AttrDict)
        assert isinstance(self.dct.d.f, poor.AttrDict)
