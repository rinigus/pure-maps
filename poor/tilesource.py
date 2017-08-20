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

import imghdr
import importlib.machinery
import os
import poor
import random
import re
import sys
import threading
import time
import urllib

__all__ = ("TileSource",)

MIMETYPE_EXTENSIONS = {"image/jpeg": ".jpg", "image/png": ".png"}
RE_LOCALHOST = re.compile(r"://(127.0.0.1|localhost)\b")


class TileSource:

    """Map tile source with cached tile downloads."""

    # Share a connection pool across different tile sources.
    # Use two download threads as per OpenStreetMap tile usage policy.
    # http://wiki.openstreetmap.org/wiki/Tile_usage_policy
    _pool = poor.http.ConnectionPool(2)

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
        self._active_urls = set()
        self.attribution = values["attribution"]
        self._blacklist = set()
        self.extension = values.get("extension", "")
        self._failures = {}
        self.format = values["format"]
        self.id = id
        self._lock = threading.Lock()
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
        if RE_LOCALHOST.search(self.url):
            # A tile server running on localhost is likely to be rendering
            # tiles from vector data and likely to be CPU-bound. Have the
            # download thread count equal the CPU core count to make full use
            # of processors in rendering.
            self._pool = poor.http.ConnectionPool(poor.util.cpu_count())

    @poor.util.locked_method
    def _add_to_blacklist(self, url):
        """Add `url` to list of tiles to not try to download."""
        self._blacklist.add(url)
        if len(self._blacklist) > 500:
            while len(self._blacklist) > 400:
                self._blacklist.pop()

    def _add_to_blacklist_maybe(self, url):
        """Add `url` to blacklist after repeated errors."""
        should_blacklist = False
        with self._lock:
            self._failures.setdefault(url, 0)
            self._failures[url] += 1
            if self._failures[url] > 2:
                should_blacklist = True
                print("Blacklisted after 3 failed attempts.",
                      file=sys.stderr)
                del self._failures[url]
        if should_blacklist:
            self._add_to_blacklist(url)

    def download(self, tile, retry=1):
        """Download map tile and return local file path or ``None``."""
        url = self.url.format(**tile)
        if url in self._blacklist:
            return None
        path = self.tile_path(tile)
        path = os.path.join(poor.CACHE_HOME_DIR, self.id, path)
        cached = self._tile_in_cache(path)
        if cached is not None:
            return cached
        if (not poor.conf.allow_tile_download and
            not RE_LOCALHOST.search(url)):
            # If not allowing tiles to be downloaded, return
            # a special tile to make a distinction between
            # prevented and queued downloads.
            if self.type == "basemap":
                return "icons/tile.png"
            return None
        try:
            connection = self._pool.get(url)
            with self._lock:
                # Ensure that only one thread downloads URL.
                if url in self._active_urls: return None
                self._active_urls.add(url)
            # Check again that another thread didn't download
            # the tile during the above preparations.
            cached = self._tile_in_cache(path)
            if cached is not None:
                return cached
            # Do relative requests (without scheme and netloc)
            # for better compatibility with different servers.
            components = urllib.parse.urlparse(url)
            components = ("", "") + components[2:]
            url_path = urllib.parse.urlunparse(components)
            connection.request("GET", url_path, headers=poor.http.HEADERS)
            response = connection.getresponse()
            # Always read response to avoid
            # http.client.ResponseNotReady: Request-sent.
            blob = response.read(10*1024*1024)
            if imghdr.what("", h=blob) is None:
                raise Exception("Non-image data received")
            if not self.extension:
                # XXX: Should we use the above imghdr result here?
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
            poor.util.makedirs(directory)
            with open(path, "wb") as f:
                f.write(blob)
            return path
        except Exception as error:
            if not self._pool.is_alive(): raise
            connection.close()
            connection = None
            broken = tuple(poor.http.BROKEN_CONNECTION_ERRORS)
            if not isinstance(error, broken) or retry == 0:
                print(url, file=sys.stderr)
                print("Failed to download tile: {}: {}"
                      .format(error.__class__.__name__, str(error)),
                      file=sys.stderr)

                # Keep track of the amount of failed downloads per URL
                # and avoid trying to endlessly redownload the same tile.
                self._add_to_blacklist_maybe(url)
                return None
            # If we haven't successfully returned a response,
            # nor reraised an Exception, we move on to try again.
            assert retry > 0
        finally:
            self._pool.put(url, connection)
            with self._lock:
                self._active_urls.discard(url)
        return self.download(tile, retry - 1)

    def _init_provider(self, format):
        """Initialize tile format provider module from `format`."""
        leaf = os.path.join("tilesources", "{}.py".format(format))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
            if not os.path.isfile(path):
                raise ValueError("Tile format %s implementation not found"
                                 .format(repr(format)))

        name = "poor.tilesource.format{:d}".format(random.randrange(10**12))
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

    def terminate(self):
        """Close all connections and terminate."""
        self._pool.terminate()

    def tile_corners(self, tile):
        """Return coordinates of NE, SE, SW, NW corners of given tile."""
        return self._provider.tile_corners(tile)

    def _tile_in_cache(self, path, fuzzy=True):
        """Return path if tile exists in cache or ``None``."""
        if not self.extension and fuzzy:
            # Test all handled extensions for cached files.
            # This requires that no erroneous duplicates exist.
            for candidate in (path + x for x in MIMETYPE_EXTENSIONS.values()):
                cached = self._tile_in_cache(candidate, fuzzy=False)
                if cached is not None:
                    return cached
        if not os.path.isfile(path):
            return None
        stat = os.stat(path)
        # Failed downloads can result in empty files.
        if stat.st_size == 0:
            return None
        # Check that suspiciously small files are actually images.
        if stat.st_size < 64:
            if imghdr.what(path) is None:
                return None
        if self.max_age is not None:
            # Redownload expired tiles.
            if stat.st_mtime < time.time() - self.max_age * 86400:
                return None
        return path

    def tile_key(self, tile):
        """Return a unique key to use to refer to given tile."""
        return os.path.join(self.id, self._provider.tile_path(tile, ""))

    def tile_path(self, tile, extension=None):
        """Return relative cache path to use for given tile."""
        extension = extension or self.extension
        return self._provider.tile_path(tile, extension)
