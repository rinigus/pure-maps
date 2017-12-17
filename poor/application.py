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
        self._download_queue = {}
        self.geocoder = None
        self.guide = None
        self.history = poor.HistoryManager()
        self.narrative = poor.Narrative()
        self.overlays = []
        self.router = None
        self.tilecollection = poor.TileCollection()
        self._timestamp = int(time.time() * 1000)
        self.set_basemap(poor.conf.basemap)
        self.add_overlays(*poor.conf.overlays)
        self.set_geocoder(poor.conf.geocoder)
        self.set_guide(poor.conf.guide)
        self.set_router(poor.conf.router)
        poor.cache.purge_async()

    def add_overlays(self, *overlays):
        """Add overlay providers from strings `overlays`."""
        for overlay in overlays:
            try:
                self.overlays.append(poor.TileSource(overlay))
                self.overlays.sort(key=lambda x: x.z)
                poor.conf.add("overlays", overlay)
                self.tilecollection.clear()
            except Exception as error:
                print("Failed to load overlay '{}': {}"
                      .format(overlay, str(error)),
                      file=sys.stderr)
                poor.conf.remove("overlays", overlay)

    def _drop_download_queues(self):
        """Remove download queues of no longer used tile sources."""
        current = [self.basemap.id] + [x.id for x in self.overlays]
        for id in list(self._download_queue.keys()):
            if not id in current:
                del self._download_queue[id]

    def _get_download_queue(self, id, create=False):
        """Return download queue for tile source `id`."""
        with poor.util.silent(KeyError):
            return self._download_queue[id]
        if not create: return None
        self._download_queue[id] = queue.Queue()
        # Initialize threads to process the queue. tilesource's own connection
        # pool limits the actual total amount of connections per host. This
        # thread count should just be greater than or equal to that.
        for i in range(4):
            target = self._process_download_queue
            threading.Thread(target=target, args=(id,), daemon=True).start()
        return self._download_queue[id]

    def _process_download_queue(self, id):
        """Monitor download queue of `id` and feed items for update."""
        while True:
            download_queue = self._get_download_queue(id)
            # Terminate thread if tile source no longer used.
            if download_queue is None: break
            args, timestamp = download_queue.get()
            if timestamp == self._timestamp:
                # Only download tiles queued in the latest update.
                self._update_tile(*args, timestamp=timestamp)
            download_queue.task_done()

    def quit(self):
        """Quit the application."""
        poor.http.pool.terminate()
        self.basemap.terminate()
        for overlay in self.overlays:
            overlay.terminate()
        poor.conf.write()
        self.history.write()
        self.narrative.quit()

    def remove_overlays(self, *overlays):
        """Remove overlay providers from strings `overlays`."""
        if not overlays:
            overlays = [x.id for x in self.overlays]
        for i in reversed(range(len(self.overlays))):
            if self.overlays[i].id in overlays:
                del self.overlays[i]
        for overlay in overlays:
            poor.conf.remove("overlays", overlay)
        self._drop_download_queues()
        self.tilecollection.clear()

    def set_basemap(self, basemap):
        """Set basemap from string `basemap`."""
        try:
            self.basemap = poor.TileSource(basemap)
            poor.conf.basemap = basemap
            self._drop_download_queues()
            self.tilecollection.clear()
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

    def _update_tile(self, tilesource, zoom, display_zoom, scale_factor, tile,
                     timestamp):
        """Download missing tile and ask QML to render it."""
        key = tilesource.tile_key(tile)
        item = self.tilecollection.get(key)
        if item is not None:
            return pyotherside.send("show-tile", item.uid)
        path = tilesource.download(tile)
        if path is None: return
        uri = poor.util.path2uri(path) if os.path.isabs(path) else path
        corners = tilesource.tile_corners(tile)
        xmin, xmax, ymin, ymax = self._bbox
        # Abort if map moved so that tile is no longer in view.
        if xmax <= corners[2][0] or xmin >= corners[0][0]: return
        if ymax <= corners[2][1] or ymin >= corners[0][1]: return
        item = self.tilecollection.get_free(
            key, path, xmin, xmax, ymin, ymax, display_zoom, corners)
        pyotherside.send("render-tile", dict(display_zoom=display_zoom,
                                             nex=corners[0][0],
                                             nwx=corners[3][0],
                                             nwy=corners[3][1],
                                             scale=scale_factor*tilesource.scale,
                                             half_zoom=tilesource.half_zoom,
                                             smooth=tilesource.smooth,
                                             swy=corners[2][1],
                                             type=tilesource.type,
                                             uid=item.uid,
                                             uri=uri,
                                             z=tilesource.z,
                                             zoom=zoom))

    def update_tiles(self, xmin, xmax, ymin, ymax, zoom, scale_factor):
        """Download missing tiles and ask QML to render them."""
        self.tilecollection.sort()
        self._bbox = [xmin, xmax, ymin, ymax]
        self._timestamp = int(time.time() * 1000)
        total_tiles = 0
        for tilesource in [self.basemap] + self.overlays:
            # For scales above one, get tile from a lower zoom level.
            offset = math.log2(scale_factor * tilesource.scale)
            tile_zoom = math.ceil(zoom - offset - 0.01)
            download_queue = self._get_download_queue(tilesource.id, create=True)
            for tile in tilesource.list_tiles(xmin, xmax, ymin, ymax, tile_zoom):
                args = (tilesource, tile_zoom, zoom, scale_factor, tile)
                download_queue.put((args, self._timestamp))
                total_tiles += 1
        # Keep a few screenfulls of tiles in memory.
        total_tiles = math.ceil(total_tiles / (1 + len(self.overlays)))
        size = (3 + len(self.overlays)) * total_tiles
        if self.tilecollection.size < size:
            self.tilecollection.grow(size)
