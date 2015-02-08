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

    def test_get(self):
        assert poor.conf.get("zoom") == 15

    def test_get_default(self):
        assert poor.conf.get_default("zoom") == 15

    def test_get_default__nested(self):
        poor.config.DEFAULTS["foo"] = poor.config.AttrDict()
        poor.config.DEFAULTS["foo"]["bar"] = 1
        assert poor.conf.get_default("foo.bar") == 1

    def test_migrate__basemap(self):
        # 'tilesource' renamed to 'basemap' in 0.18.
        values = {"tilesource": "openstreetmap"}
        values = poor.conf._migrate(values)
        assert values["basemap"] == "openstreetmap"
        assert not "tilesource" in values

    def test_migrate__cache_max_age(self):
        # 'cache_max_age' added in 0.14, value changed in 0.18.
        # Upgrading from < 0.14 to 0.18 should set the old implicit
        # default of never removing tiles, valued as 36500.
        values = {"tilesource": "openstreetmap"}
        values = poor.conf._migrate(values)
        assert values["cache_max_age"] == 36500

    def test_read(self):
        poor.conf.zoom = 99
        poor.conf.write(self.path)
        poor.conf.clear()
        assert not poor.conf
        poor.conf.read(self.path)
        assert poor.conf.zoom == 99

    def test_read__nested(self):
        poor.conf.register_router("foo", {"type": "car"})
        poor.conf.write(self.path)
        del poor.conf.routers["foo"]
        assert not "foo" in poor.conf.routers
        poor.conf.read(self.path)
        assert poor.conf.routers.foo.type == "car"

    def test_register_router(self):
        poor.conf.register_router("foo", {"type": "car"})
        assert poor.conf.routers.foo.type == "car"
        assert poor.conf.get_default("routers.foo.type") == "car"

    def test_register_router__again(self):
        # Subsequent calls should not change values.
        poor.conf.register_router("foo", {"type": "car"})
        poor.conf.routers.foo.type = "bicycle"
        poor.conf.register_router("foo", {"type": "car"})
        assert poor.conf.routers.foo.type == "bicycle"
        assert poor.conf.get_default("routers.foo.type") == "car"

    def test_set(self):
        poor.conf.set("zoom", 99)
        assert poor.conf.zoom == 99

    def test_set__nested(self):
        poor.conf.set("foo.bar", 1)
        assert poor.conf.foo.bar == 1

    def test_set_add(self):
        poor.conf.set("items", [1,2,3])
        assert poor.conf.items == [1,2,3]
        poor.conf.set_add("items", 4)
        assert poor.conf.items == [1,2,3,4]

    def test_set_contains(self):
        poor.conf.set("items", [1,2,3])
        assert poor.conf.items == [1,2,3]
        assert poor.conf.set_contains("items", 1)
        assert not poor.conf.set_contains("items", 4)

    def test_set_remove(self):
        poor.conf.set("items", [1,2,3])
        assert poor.conf.items == [1,2,3]
        poor.conf.set_remove("items", 3)
        assert poor.conf.items == [1,2]

    def test_uncomment(self):
        # Prior to 0.18 options at default value were commented out.
        # Uncomment these to avoid disruptive changes.
        values = {"# cache_max_age": 36500}
        values = poor.conf._uncomment(values)
        assert values["cache_max_age"] == 36500
        assert len(list(values.keys())) == 1

    def test_write(self):
        poor.conf.zoom = 99
        poor.conf.write(self.path)
        poor.conf.clear()
        assert not poor.conf
        poor.conf.read(self.path)
        assert poor.conf.zoom == 99
