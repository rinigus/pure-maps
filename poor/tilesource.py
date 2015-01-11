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
import importlib.machinery
import os
import poor
import queue
import re
import sys
import time
import urllib.parse

__all__ = ("TileSource",)

MIMETYPE_EXTENSIONS = {"image/jpeg": ".jpg", "image/png": ".png"}
RE_LOCALHOST = re.compile(r"://(127.0.0.1|localhost)\b")


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
            self._blacklist = []
            self.extension = values.get("extension", "")
            self.format = values["format"]
            self._headers = None
            self._http_queue = queue.Queue()
            self.id = id
            self.max_age = values.get("max_age", None)
            self.name = values["name"]
            self._provider = None
            self.source = values["source"]
            self.url = values["url"]
            self._init_provider(values["format"])
            self._init_http_queue()

    def download(self, tile, retry=1):
        """Download map tile and return local file path or ``None``."""
        url = self.url.format(**tile)
        if url in self._blacklist:
            return print("Not downloading blacklisted tile: {}"
                         .format(url), file=sys.stderr)

        path = self.tile_path(tile)
        path = os.path.join(poor.CACHE_HOME_DIR, self.id, path)
        if self._tile_exists(path):
            return path
        if not self.extension:
            # Test all handled extensions for cached files.
            # This requires that no erroneous duplicates exist.
            for candidate in (path + x for x in MIMETYPE_EXTENSIONS.values()):
                if self._tile_exists(candidate):
                    return candidate
        if not poor.conf.allow_tile_download:
            # If not allowing tiles to be downloaded, return a special tile to
            # make a distinction between prevented and queued downloads.
            if not RE_LOCALHOST.search(url):
                return "icons/tile.png"
        try:
            httpc = self._http_queue.get()
            if httpc is None:
                httpc = self._new_http_connection()
            httpc.request("GET", url, headers=self._headers)
            response = httpc.getresponse()
            if response.status != 200:
                raise Exception("Server responded {}: {}"
                                .format(repr(response.status),
                                        repr(response.reason)))

            if not self.extension:
                mimetype = response.getheader("Content-Type")
                if not mimetype in MIMETYPE_EXTENSIONS:
                    # Don't try to redownload tile
                    # if we don't know what to do with it.
                    self._blacklist.append(url)
                    raise Exception(
                        "Failed to detect tile mimetype -- "
                        "Content-Type header missing or unexpected value")
                path = path + MIMETYPE_EXTENSIONS[mimetype]
            directory = os.path.dirname(path)
            if not os.path.isdir(directory):
                poor.util.makedirs(directory)
            with open(path, "wb") as f:
                f.write(response.read(1048576))
            return path
        except Exception as error:
            httpc.close()
            httpc = None
            broken = (BrokenPipeError, http.client.BadStatusLine)
            if isinstance(error, broken) and retry > 0:
                # This probably means that the connection was broken.
                pass
            else:
                # Otherwise we probably have no reason to expect a different
                # outcome if we were to force an immediate retry.
                print(url)
                print("Failed to download tile: {}: {}"
                      .format(error.__class__.__name__, str(error)),
                      file=sys.stderr)
                return None
        finally:
            self._http_queue.task_done()
            self._http_queue.put(httpc)
        if retry > 0:
            return self.download(tile, retry-1)
        return None

    def _init_http_queue(self):
        """Initialize queue of HTTP connections."""
        # Use two download threads as per OpenStreetMap tile usage policy.
        # http://wiki.openstreetmap.org/wiki/Tile_usage_policy
        for i in range(2):
            try:
                self._http_queue.put(self._new_http_connection())
            except Exception:
                self._http_queue.put(None)
        agent = "poor-maps/{}".format(poor.__version__)
        self._headers = {"Connection": "Keep-Alive",
                         "User-Agent": agent}

    def _init_provider(self, format):
        """Initialize tile format provider module from `format`."""
        leaf = os.path.join("tilesources", "{}.py".format(format))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
            if not os.path.isfile(path):
                raise ValueError("Tile format %s implementation not found"
                                 .format(repr(format)))

        name = "poor.tilesource.format{:d}".format(int(1000*time.time()))
        loader = importlib.machinery.SourceFileLoader(name, path)
        self._provider = loader.load_module(name)

    def list_tiles(self, xmin, xmax, ymin, ymax, zoom):
        """Return a sequence of tiles within given bounding box."""
        return self._provider.list_tiles(xmin, xmax, ymin, ymax, zoom)

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("tilesources", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        return poor.util.read_json(path)

    def _new_http_connection(self):
        """Initialize and return a new persistent HTTP connection."""
        host = urllib.parse.urlparse(self.url).netloc
        timeout = poor.conf.download_timeout
        if self.url.startswith("http:"):
            return http.client.HTTPConnection(host, timeout=timeout)
        if self.url.startswith("https:"):
            return http.client.HTTPSConnection(host, timeout=timeout)
        raise ValueError("Bad URL: {}".format(repr(self.url)))

    def tile_corners(self, tile):
        """Return coordinates of NE, SE, SW, NW corners of given tile."""
        return self._provider.tile_corners(tile)

    def _tile_exists(self, path):
        """Return ``True`` if tile exists in cache and is good to use."""
        if not os.path.isfile(path):
            return False
        stat = os.stat(path)
        # Failed downloads can result in empty files.
        if stat.st_size == 0:
            return False
        if self.max_age is not None:
            # Redownload expired tiles.
            if stat.st_mtime < time.time() - self.max_age * 86400:
                return False
        return True

    def tile_path(self, tile, extension=None):
        """Return relative cache path to use for given tile."""
        extension = extension or self.extension
        return self._provider.tile_path(tile, extension)
