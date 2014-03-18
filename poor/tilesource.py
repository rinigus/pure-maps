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
import json
import os
import poor
import queue
import re
import sys

__all__ = ("TileSource",)


class TileSource:

    """Map tile source with cached tile downloads."""

    def __init__(self, id):
        """Initialize a :class:`TileSource` instance."""
        values = self._load_attributes(id)
        self._headers = None
        self._http_queue = queue.Queue()
        self.attribution = values["attribution"]
        self.extension = values["extension"]
        self.format = values["format"]
        self.id = id
        self.name = values["name"]
        self.url = values["url"]
        self._init_http_connections()

    def _init_http_connections(self):
        """Initialize persistent HTTP connections."""
        # Use two download threads as per OpenStreetMap tile usage policy.
        # http://wiki.openstreetmap.org/wiki/Tile_usage_policy
        host = re.sub(r"/.*$", "", re.sub(r"^.*?://", "", self.url))
        timeout = poor.conf.download_timeout
        for i in range(2):
            httpc = http.client.HTTPConnection(host, timeout=timeout)
            self._http_queue.put(httpc)
        agent = "poor-maps/{}".format(poor.__version__)
        self._headers = {"Connection": "Keep-Alive",
                         "User-Agent": agent}

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("tilesources", "{}.json".format(id))
        path = os.path.join(poor.CONFIG_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        with open(path, "r", encoding="utf_8") as f:
            return(json.load(f))

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
        directory = poor.util.makedirs(directory)
        if directory is None: return
        try:
            httpc = self._http_queue.get()
            httpc.request("GET", url, headers=self._headers)
            response = httpc.getresponse()
            if response.status != 200:
                raise Exception("Server responded {}: {}"
                                .format(repr(response.status),
                                        repr(response.reason)))

            with open(path, "wb") as f:
                f.write(response.read(1048576))
        except Exception as error:
            print("Failed to download tile: {}"
                  .format(str(error)), file=sys.stderr)

            httpc.close()
            httpc.connect()
            return None
        finally:
            self._http_queue.task_done()
            self._http_queue.put(httpc)
        return path
