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
import threading
import time
import urllib.parse

__all__ = ("TileSource",)

MIMETYPE_EXTENSIONS = {"image/jpeg": ".jpg", "image/png": ".png"}
RE_LOCALHOST = re.compile(r"://(127.0.0.1|localhost)\b")


class ConnectionPool:

    """A managed single-instance pool of per-host HTTP connections."""

    def __new__(cls, threads):
        """Return single instance."""
        if not hasattr(cls, "_instance"):
            cls._instance = object.__new__(cls)
        return cls._instance

    def __init__(self, threads):
        """Initialize a :class:`ConnectionPool` instance."""
        # Initialize properties only once.
        if hasattr(self, "_queue"): return
        self._lock = threading.Lock()
        self._queue = {}
        self._threads = threads

    def get(self, url):
        """Return an HTTP connection to `url`."""
        key = self._get_key(url)
        connection = self._queue[key].get()
        connection = connection or self._new(url)
        return connection

    def _get_key(self, url):
        """Return a dictionary key for `url`."""
        components = urllib.parse.urlparse(url)
        return "{}://{}".format(components.scheme, components.netloc)

    @poor.util.locked_method
    def init(self, url):
        """Initialize a queue of HTTP connections to `url`."""
        key = self._get_key(url)
        if key in self._queue: return
        self._queue[key] = queue.Queue()
        for i in range(self._threads):
            self._queue[key].put(None)

    def _new(self, url):
        """Initialize and return a new HTTP connection to `url`."""
        host = urllib.parse.urlparse(url).netloc
        timeout = poor.conf.download_timeout
        print("ConnectionPool._new: {}".format(host))
        if url.startswith("http:"):
            return http.client.HTTPConnection(host, timeout=timeout)
        if url.startswith("https:"):
            return http.client.HTTPSConnection(host, timeout=timeout)
        raise ValueError("Bad URL: {}".format(repr(url)))

    def put(self, url, connection):
        """Return `connection` to the pool of connections."""
        key = self._get_key(url)
        self._queue[key].task_done()
        self._queue[key].put(connection)


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
        # Initialize properties only once.
        if hasattr(self, "id"): return
        values = self._load_attributes(id)
        self.attribution = values["attribution"]
        self._blacklist = set()
        self.extension = values.get("extension", "")
        self._failures = {}
        self.format = values["format"]
        self.id = id
        self.max_age = values.get("max_age", None)
        self.name = values["name"]
        self._provider = None
        self.scale = values.get("scale", 1)
        self.smooth = values.get("smooth", False)
        self.source = values["source"]
        self.type = values.get("type", "basemap")
        self.url = values["url"]
        self.z = max(0, min(40, values.get("z", 0)))
        self._init_provider(values["format"])
        # Use two download threads as per OpenStreetMap tile usage policy.
        # http://wiki.openstreetmap.org/wiki/Tile_usage_policy
        self._pool = ConnectionPool(2)
        self._pool.init(self.url)
        agent = "poor-maps/{}".format(poor.__version__)
        self._headers = {"Connection": "Keep-Alive", "User-Agent": agent}

    def _add_to_blacklist(self, url):
        """Add `url` to list of tiles to not try to download."""
        self._blacklist.add(url)
        if len(self._blacklist) > 500:
            while len(self._blacklist) > 400:
                self._blacklist.pop()
        print("TileSource._add_to_blacklist: {:d}".format(len(self._blacklist)))

    def download(self, tile, retry=1):
        """Download map tile and return local file path or ``None``."""
        url = self.url.format(**tile)
        if url in self._blacklist:
            return None
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
        if (not poor.conf.allow_tile_download and
            not RE_LOCALHOST.search(url)):
            # If not allowing tiles to be downloaded, return a special tile to
            # make a distinction between prevented and queued downloads.
            if self.type == "basemap":
                return "icons/tile.png"
            return None
        try:
            connection = self._pool.get(url)
            connection.request("GET", url, headers=self._headers)
            response = connection.getresponse()
            # Always read response to avoid
            # http.client.ResponseNotReady: Request-sent.
            blob = response.read(1048576)
            if not self.extension:
                mimetype = response.getheader("Content-Type")
                if not mimetype in MIMETYPE_EXTENSIONS:
                    # Don't try to redownload tile
                    # if we don't know what to do with it.
                    self._add_to_blacklist(url)
                    raise Exception(
                        "Failed to detect tile mimetype -- "
                        "Content-Type header missing or unexpected value")
                path = path + MIMETYPE_EXTENSIONS[mimetype]
            if response.status != 200:
                if self.type == "overlay":
                    # Many overlays seem to use non-200
                    # (e.g. 302 or 404) for areas with no data.
                    self._add_to_blacklist(url)
                    return None
                raise Exception("Server responded {}: {}"
                                .format(repr(response.status),
                                        repr(response.reason)))

            directory = os.path.dirname(path)
            if not os.path.isdir(directory):
                poor.util.makedirs(directory)
            with open(path, "wb") as f:
                f.write(blob)
            return path
        except Exception as error:
            connection.close()
            connection = None
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

                # Keep track of the amount of failed downloads per URL
                # and avoid trying to endlessly redownload the same tile.
                self._failures.setdefault(url, 0)
                self._failures[url] += 1
                if self._failures[url] > 2:
                    print("Blacklisted after 3 failed attempts.",
                          file=sys.stderr)
                    self._add_to_blacklist(url)
                    del self._failures[url]
                return None
        finally:
            # Return persistent connection for reuse.
            self._pool.put(url, connection)
        if retry > 0:
            return self.download(tile, retry-1)
        return None

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

    def tile_key(self, tile):
        """Return a unique key to use to refer to given tile."""
        return os.path.join(self.id, self._provider.tile_path(tile, ""))

    def tile_path(self, tile, extension=None):
        """Return relative cache path to use for given tile."""
        extension = extension or self.extension
        return self._provider.tile_path(tile, extension)
