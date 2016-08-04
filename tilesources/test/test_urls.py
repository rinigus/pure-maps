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

import imghdr
import os
import poor.test
import random


class TestModule(poor.test.TestCase):

    # XXX: Only test the default basemap tile source? Some of the other
    # tile sources tend to be broken for a short while every now and then,
    # which is probably not something we would need to react to.

    def request_url(self, name):
        directory = os.path.join(os.path.dirname(__file__), "..")
        path = os.path.join(directory, "{}.json".format(name))
        tilesource = poor.util.read_json(path)
        url = tilesource["url"].format(
            x=random.randint(2071, 2080),
            y=random.randint(1401, 1410),
            z=12)

        blob = poor.http.request_url(url)
        imgtype = imghdr.what("", h=blob)
        assert imgtype in ("jpeg", "png")

    def test_mapbox_streets_gl(self):
        self.request_url("mapbox_streets_gl_@1x")
        self.request_url("mapbox_streets_gl_@2x")
