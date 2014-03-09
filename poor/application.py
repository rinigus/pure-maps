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
import threading
import time

__all__ = ("Application",)


class Application:

    """An application to display maps and stuff."""

    def __init__(self):
        """Initialize a :class:`Application` instance."""
        print("Application.__init__...")
        self.thread_queue = []
        self.tilecollection = poor.TileCollection()
        self.tilesource = None
        self._init_tilesource()
        self._send_defaults()
        print("...Application.__init__")

    def _init_tilesource(self):
        """Initialize map tile source."""
        try:
            self.tilesource = poor.TileSource(poor.conf.tilesource)
        except Exception:
            poor.conf.tilesource = poor.conf.get_default("tilesource")
            self.tilesource = poor.TileSource(poor.conf.tilesource)

    def _send_defaults(self):
        """Send default configuration to QML."""
        print("Application._send_defaults...")
        pyotherside.send("set-center", *poor.conf.center)
        pyotherside.send("set-zoom-level", poor.conf.zoom)
        pyotherside.send("set-attribution", self.tilesource.attribution)

    def _update_tile(self, x, y, xmin, xmax, ymin, ymax, zoom):
        """Download missing tile and ask QML to render it."""
        path = self.tilesource.download(x, y, zoom)
        if path is None: return
        if len(self.thread_queue) > 1: return
        uri = poor.util.path2uri(path)
        tile = self.tilecollection.get_free(xmin, xmax, ymin, ymax, zoom)
        tile.x = x
        tile.y = y
        tile.zoom = zoom
        xcoord, ycoord = poor.util.num2deg(x, y, zoom)
        pyotherside.send("render-tile", tile.uid, xcoord, ycoord, zoom, uri)

    def _update_tiles(self, xmin, xmax, ymin, ymax, zoom):
        """Download missing tiles and ask QML to render them."""
        print("Application._update_tiles...")
        bbox = poor.util.bbox_deg2num(xmin, xmax, ymin, ymax, zoom)
        xmin, xmax, ymin, ymax = bbox
        download_threads = []
        for x, y in poor.util.prod_tiles(xmin, xmax, ymin, ymax):
            if len(self.thread_queue) > 1: break
            tile = self.tilecollection.get(x, y, zoom)
            if tile is not None:
                pyotherside.send("show-tile", tile.uid)
                continue
            # Use two simultaneous download threads as per
            # OpenStreetMap tile usage policy.
            # (Let's assume no one has stricter rules.)
            # http://wiki.openstreetmap.org/wiki/Tile_usage_policy
            while sum(x.is_alive() for x in download_threads) >= 2:
                time.sleep(0.1)
            if len(self.thread_queue) > 1: break
            args = (x, y, xmin, xmax, ymin, ymax, zoom)
            thread = threading.Thread(target=self._update_tile, args=args)
            download_threads.append(thread)
            thread.start()
        while sum(x.is_alive() for x in download_threads) > 0:
            time.sleep(0.1)
        self.thread_queue.pop(0)
        print("...Application._update_tiles")

    def update_tiles(self, xmin, xmax, ymin, ymax, zoom):
        """Download missing tiles and ask QML to render them."""
        print("Application.update_tiles...")
        print(self.thread_queue)
        # Queue a new update thread, but delay start until
        # previous threads have terminated.
        thread = threading.Thread(target=self._update_tiles,
                                  args=(xmin, xmax, ymin, ymax, zoom))

        del self.thread_queue[1:]
        self.thread_queue.append(thread)
        while (self.thread_queue and
               self.thread_queue[0] is not thread):
            time.sleep(0.1)
        thread.start()
        poor.conf.center[0] = (xmin + xmax) / 2
        poor.conf.center[1] = (ymin + ymax) / 2
        poor.conf.zoom = zoom
        print("...Application.update_tiles")
