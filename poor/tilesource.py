# -*- coding: utf-8-unix -*-

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

import json
import os
import poor
import sys
import urllib.request

__all__ = ("TileSource",)


class TileSource:

    """Map tile source with cached tile downloads."""

    def __init__(self, id):
        """Initialize a :class:`TileSource` object."""
        values = self._load_attributes(id)
        self.attribution = values["attribution"]
        self.extension = values["extension"]
        self.format = values["format"]
        self.id = id
        self.name = values["name"]
        self.opener = None
        self.url = values["url"]
        self._init_url_opener()

    def _init_url_opener(self):
        """Initialize the URL opener to use for downloading tiles."""
        self.opener = urllib.request.build_opener()
        agent = "poor-maps/{}".format(poor.__version__)
        self.opener.addheaders = [("User-agent", agent)]

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
        timeout = poor.conf.download_timeout
        try:
            with self.opener.open(url, timeout=timeout) as w:
                with open(path, "wb") as f:
                    f.write(w.read())
        except Exception as error:
            print("Failed to download tile: {}"
                  .format(str(error)), file=sys.stderr)

            return None
        return path
