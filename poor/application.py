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

"""An application to display maps and stuff."""

import math
import os
import poor
import pyotherside
import queue
import sys
import threading
import time

__all__ = ("Application",)


class Application:

    """An application to display maps and stuff."""

    def __init__(self):
        """Initialize an :class:`Application` instance."""
        self.basemap = None
        self._bbox = [-1, -1, -1, -1]
        self.geocoder = None
        self.guide = None
        self.history = poor.HistoryManager()
        self.narrative = poor.Narrative()
        self.overlays = []
        self.router = None
        self._timestamp = int(time.time() * 1000)
        self.set_basemap(poor.conf.basemap)
        self.set_geocoder(poor.conf.geocoder)
        self.set_guide(poor.conf.guide)
        self.set_router(poor.conf.router)

    def get_basemap(self):
        return self.basemap

    def quit(self):
        """Quit the application."""
        poor.http.pool.terminate()
        poor.conf.write()
        self.history.write()
        self.narrative.quit()

    def set_basemap(self, basemap):
        """Set basemap from string `basemap`."""
        try:
            leaf = os.path.join("tilesources", "{}.json".format(basemap))
            path = os.path.join(poor.DATA_HOME_DIR, leaf)
            if not os.path.isfile(path):
                path = os.path.join(poor.DATA_DIR, leaf)
            bmap = poor.util.read_json(path)
            if bmap["format"] == "slippy":
                styleJson = """
{
    "sources": {
        "raster": {
            "tiles": ["URL_SOURCE"],
            "type": "raster",
            "tileSize": TILE_SIZE
        }
    },
    "layers": [
        {
            "id": "raster",
            "type": "raster",
            "source": "raster",
            "layout": {
                "visibility": "visible"
            },
            "paint": {
                "raster-opacity": 1
            }
        }
    ],
    "id": "raster"
}"""
                styleJson = styleJson.replace("URL_SOURCE", bmap["url"])
                styleJson = styleJson.replace("TILE_SIZE", str(bmap["scale"]*256))
                bmap["styleJson"] = styleJson
                bmap["pixelRatio"] = 1
                bmap["styleReferenceLayer"] = ""
            elif bmap["format"] == "mapbox":
                pass
            else:
                raise ValueError("Unsupported tilesource format: {}".format(bmap["format"]))
            self.basemap = bmap
            poor.conf.basemap = basemap
        except Exception as error:
            print("Failed to load basemap '{}': {}"
                  .format(basemap, str(error)),
                  file=sys.stderr)
            if self.basemap is None:
                default = poor.conf.get_default("basemap")
                if default != basemap:
                    self.set_basemap(default)

    def set_geocoder(self, geocoder):
        """Set geocoding provider from string `geocoder`."""
        try:
            self.geocoder = poor.Geocoder(geocoder)
            poor.conf.geocoder = geocoder
        except Exception as error:
            print("Failed to load geocoder '{}': {}"
                  .format(geocoder, str(error)),
                  file=sys.stderr)
            if self.geocoder is None:
                default = poor.conf.get_default("geocoder")
                if default != geocoder:
                    self.set_geocoder(default)

    def set_guide(self, guide):
        """Set place guide provider from string `guide`."""
        try:
            self.guide = poor.Guide(guide)
            poor.conf.guide = guide
        except Exception as error:
            print("Failed to load guide '{}': {}"
                  .format(guide, str(error)),
                  file=sys.stderr)
            if self.guide is None:
                default = poor.conf.get_default("guide")
                if default != guide:
                    self.set_guide(default)

    def set_router(self, router):
        """Set routing provider from string `router`."""
        try:
            self.router = poor.Router(router)
            poor.conf.router = router
        except Exception as error:
            print("Failed to load router '{}': {}"
                  .format(router, str(error)),
                  file=sys.stderr)
            if self.router is None:
                default = poor.conf.get_default("router")
                if default != router:
                    self.set_router(default)
