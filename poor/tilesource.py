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

"""Map tile source with cached tile downloads."""

import http.client
import os
import poor
import queue
import sys
import urllib.parse

__all__ = ("TileSource",)


class TileSource:

    """Map tile source with cached tile downloads."""

    def __new__(cls, id):
        """Return possibly existing instance for `id`."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        if not id in cls._instances:
            cls._instances[id] = object.__new__(cls)
        return cls._instances[id]

    def __init__(self, id):
        """Initialize a :class:`TileSource` instance."""
        if not hasattr(self, "id"):
            # Initialize properties only once.
            # __new__ returns objects usable as-is.
            values = self._load_attributes(id)
            self.attribution = values["attribution"]
            self.extension = values["extension"]
            self.format = values["format"]
            self._headers = None
            self._http_queue = queue.Queue()
            self.id = id
            self.name = values["name"]
            self.source = values["source"]
            self.url = values["url"]
            self._init_http_connections()

    def download(self, x, y, zoom):
        """Download map tile and return local file path or ``None``."""
        url = self.url.format(x=x, y=y, z=zoom)
        directory = os.path.join(poor.CACHE_HOME_DIR,
                                 self.id,
                                 str(zoom),
                                 str(x))

        basename = "{:d}{}".format(y, self.extension)
        path = os.path.join(directory, basename)
        if os.path.isfile(path):
            # Failed downloads can result in empty files.
            if os.stat(path).st_size > 0:
                return path
        try:
            httpc = self._http_queue.get()
            httpc.request("GET", url, headers=self._headers)
            response = httpc.getresponse()
            if response.status != 200:
                raise Exception("Server responded {}: {}"
                                .format(repr(response.status),
                                        repr(response.reason)))

            poor.util.makedirs(directory)
            with open(path, "wb") as f:
                f.write(response.read(1048576))
        except Exception as error:
            print("Failed to download tile: {}"
                  .format(str(error)), file=sys.stderr)

            httpc.close()
            httpc = self._init_http_connection()
            return None
        finally:
            self._http_queue.task_done()
            self._http_queue.put(httpc)
        return path

    def _init_http_connection(self):
        """Initialize and return a persistent HTTP connection."""
        host = urllib.parse.urlparse(self.url).netloc
        timeout = poor.conf.download_timeout
        return http.client.HTTPConnection(host, timeout=timeout)

    def _init_http_connections(self):
        """Initialize persistent HTTP connections."""
        # Use two download threads as per OpenStreetMap tile usage policy.
        # http://wiki.openstreetmap.org/wiki/Tile_usage_policy
        for i in range(2):
            httpc = self._init_http_connection()
            self._http_queue.put(httpc)
        agent = "poor-maps/{}".format(poor.__version__)
        self._headers = {"Connection": "Keep-Alive",
                         "User-Agent": agent}

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("tilesources", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        return poor.util.read_json(path)
