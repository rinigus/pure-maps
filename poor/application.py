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
        """Initialize a :class:`Application` instance."""
        self._download_queue = queue.Queue()
        self.geocoder = None
        self.guide = None
        self.history = poor.HistoryManager()
        self.narrative = poor.Narrative()
        self.router = None
        self._tilecollection = poor.TileCollection()
        self.tilesource = None
        self._timestamp = int(time.time()*1000)
        self._init_download_threads()
        self.set_tilesource(poor.conf.tilesource)
        self.set_geocoder(poor.conf.geocoder)
        self.set_guide(poor.conf.guide)
        self.set_router(poor.conf.router)
        self._purge_cache()

    def _init_download_threads(self):
        """Initialize map tile download threads."""
        # Use two download threads as per OpenStreetMap tile usage policy.
        # See also poor.TileSource._init_http_queue.
        # http://wiki.openstreetmap.org/wiki/Tile_usage_policy
        target = self._process_download_queue
        for i in range(2):
            threading.Thread(target=target, daemon=True).start()

    def _process_download_queue(self):
        """Monitor download queue and feed items for update."""
        while True:
            args, timestamp = self._download_queue.get()
            if timestamp == self._timestamp:
                # Only download tiles queued in the latest update.
                self._update_tile(*args, timestamp=timestamp)
            self._download_queue.task_done()

    def _purge_cache(self):
        """Remove all expired tiles from the cache directory."""
        threading.Thread(target=poor.cache.purge, daemon=True).start()

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

    def set_tilesource(self, tilesource):
        """Set map tile source from string `tilesource`."""
        try:
            self.tilesource = poor.TileSource(tilesource)
            poor.conf.tilesource = tilesource
            self._tilecollection.reset()
        except Exception as error:
            print("Failed to load tilesource '{}': {}"
                  .format(tilesource, str(error)),
                  file=sys.stderr)

            if self.tilesource is None:
                default = poor.conf.get_default("tilesource")
                if default != tilesource:
                    self.set_tilesource(default)

    def _update_tile(self, xmin, xmax, ymin, ymax, zoom, tile, timestamp):
        """Download missing tile and ask QML to render it."""
        path = self.tilesource.tile_path(tile)
        item = self._tilecollection.get(path)
        if item is not None:
            return pyotherside.send("show-tile", item.uid)
        path = self.tilesource.download(tile)
        if path is None: return
        # Abort if map moved out of view during download.
        if timestamp != self._timestamp: return
        uri = poor.util.path2uri(path)
        item = self._tilecollection.get_free(xmin, xmax, ymin, ymax, zoom)
        corners = self.tilesource.tile_corners(tile)
        item.xmin = min(corner[0] for corner in corners)
        item.xmax = max(corner[0] for corner in corners)
        item.ymin = min(corner[1] for corner in corners)
        item.ymax = max(corner[1] for corner in corners)
        item.zoom = zoom
        item.ready = True
        pyotherside.send("render-tile", dict(uid=item.uid,
                                             nex=corners[0][0],
                                             nwx=corners[3][0],
                                             swy=corners[2][1],
                                             nwy=corners[3][1],
                                             zoom=zoom,
                                             uri=uri))

    def update_tiles(self, xmin, xmax, ymin, ymax, zoom):
        """Download missing tiles and ask QML to render them."""
        zoom = int(zoom)
        self._timestamp = int(time.time()*1000)
        for tile in self.tilesource.list_tiles(xmin, xmax, ymin, ymax, zoom):
            args = (xmin, xmax, ymin, ymax, zoom, tile)
            self._download_queue.put((args, self._timestamp))
