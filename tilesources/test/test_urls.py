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

import glob
import imghdr
import os
import poor.test
import random


class TestModule(poor.test.TestCase):

    def test_urls(self):
        # Make sure all tilesource URLs still work by downloading
        # one tile and making sure the server doesn't raise an error
        # and that the returned data is an image file.
        directory = os.path.join(os.path.dirname(__file__), "..")
        for path in glob.glob(os.path.join(directory, "*.json")):
            tilesource = poor.util.read_json(path)
            # Don't test overlays as they can legitimately return
            # non-200 responses for areas with no data.
            type = tilesource.get("type", "basemap")
            if type == "overlay": continue
            url = tilesource["url"].format(
                x=random.randint(2071, 2080),
                y=random.randint(1401, 1410),
                z=12)

            blob = poor.http.request_url(url)
            imgtype = imghdr.what("", h=blob)
            assert imgtype in ("jpeg", "png")
