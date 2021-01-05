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

########################################################################
# This test is performed after other tests to avoid changes in poor.conf
# with the respect to used API keys

import importlib
import os
import poor.test
import tempfile


class TestConfigurationStore(poor.test.TestCase):

    def setup_method(self, method):
        importlib.reload(poor.config)
        poor.conf = poor.ConfigurationStore()
        handle, self.path = tempfile.mkstemp()

    def teardown_method(self, method):
        os.remove(self.path)

    def test_add(self):
        poor.conf.set("test", [1, 2, 3])
        assert poor.conf.test == [1, 2, 3]
        poor.conf.add("test", 4)
        assert poor.conf.test == [1, 2, 3, 4]

    def test_contains(self):
        poor.conf.set("test", [1, 2, 3])
        assert poor.conf.test == [1, 2, 3]
        assert poor.conf.contains("test", 1)
        assert not poor.conf.contains("test", 4)

    def test_get(self):
        assert poor.conf.get("zoom") == 3

    def test_get_default(self):
        assert poor.conf.get_default("zoom") == 3

    def test_get_default__nested(self):
        poor.config.DEFAULTS["foo"] = dict(bar=1)
        assert poor.conf.get_default("foo.bar") == 1

    def test_migrate__version_parse(self):
        poor.conf._migrate(dict(version="0.1"))
        poor.conf._migrate(dict(version="0.1.1"))
        poor.conf._migrate(dict(version="0.1.1.1"))
        poor.conf._migrate(dict(version="0.22"))
        poor.conf._migrate(dict(version="0.22.2"))
        poor.conf._migrate(dict(version="0.22.2.2"))
        poor.conf._migrate(dict(version="3.33"))
        poor.conf._migrate(dict(version="3.33.3"))
        poor.conf._migrate(dict(version="3.33.3.3"))

    def test_read(self):
        poor.conf.zoom = 99
        poor.conf.write(self.path)
        poor.conf.clear()
        assert not poor.conf
        poor.conf.read(self.path)
        assert poor.conf.zoom == 99

    def test_read__nested(self):
        poor.config.DEFAULTS["foo"] = dict(bar=1)
        poor.conf.set("foo.bar", 2)
        poor.conf.write(self.path)
        del poor.conf.foo
        assert "foo" not in poor.conf
        poor.conf.read(self.path)
        assert poor.conf.foo.bar == 2

    def test_register_router(self):
        poor.conf.register_router("foo", dict(type="car"))
        assert poor.conf.routers.foo.type == "car"
        assert poor.conf.get_default("routers.foo.type") == "car"

    def test_register_router__again(self):
        # Subsequent calls should not change values.
        poor.conf.register_router("foo", dict(type="car"))
        poor.conf.routers.foo.type = "bicycle"
        poor.conf.register_router("foo", dict(type="car"))
        assert poor.conf.routers.foo.type == "bicycle"
        assert poor.conf.get_default("routers.foo.type") == "car"

    def test_remove(self):
        poor.conf.set("test", [1, 2, 3])
        assert poor.conf.test == [1, 2, 3]
        poor.conf.remove("test", 3)
        assert poor.conf.test == [1, 2]

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
