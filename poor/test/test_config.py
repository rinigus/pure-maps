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

import imp
import os
import poor.test
import tempfile


class TestConfigurationStore(poor.test.TestCase):

    def setup_method(self, method):
        imp.reload(poor.config)
        poor.conf = poor.ConfigurationStore()
        handle, self.path = tempfile.mkstemp()

    def teardown_method(self, method):
        os.remove(self.path)

    def test_get_default(self):
        zoom = poor.conf.get_default("zoom")
        assert zoom == 15

    def test_get_default__nested(self):
        poor.config.DEFAULTS["foo"] = poor.config.AttrDict()
        poor.config.DEFAULTS["foo"]["bar"] = 1
        bar = poor.conf.get_default("foo.bar")
        assert bar == 1

    def test_read(self):
        poor.conf.zoom = 99
        poor.conf.write(self.path)
        poor.conf.clear()
        assert not poor.conf
        poor.conf.read(self.path)
        assert poor.conf.zoom == 99

    def test_read__nested(self):
        poor.conf.set("foo.bar", 1)
        poor.conf.write(self.path)
        del poor.conf.foo
        assert not "foo" in poor.conf
        poor.conf.read(self.path)
        assert poor.conf.foo.bar == 1

    def test_register_router(self):
        poor.conf.register_router("foo", {"type": "car"})
        assert poor.conf.router.foo.type == "car"
        assert poor.conf.get_default("router.foo.type") == "car"
        poor.conf.router.foo.type = "bicycle"
        # Subsequent calls should not change values.
        poor.conf.register_router("foo", {"type": "car"})
        assert poor.conf.router.foo.type == "bicycle"
        assert poor.conf.get_default("router.foo.type") == "car"

    def test_set(self):
        poor.conf.set("zoom", 99)
        assert poor.conf.zoom == 99

    def test_set__nested(self):
        poor.conf.set("foo.bar", 1)
        assert poor.conf.foo.bar == 1

    def test_write(self):
        poor.conf.zoom = 99
        poor.conf.write(self.path)
        poor.conf.clear()
        assert not poor.conf
        poor.conf.read(self.path)
        assert poor.conf.zoom == 99
