# -*- coding: utf-8 -*-

# Copyright (C) 2018 Osmo Salomaa, 2018 Rinigus
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

"""Map data and style source."""

import json
import os
import poor

__all__ = ("Map",)


class Map:

    """Map data and style source."""

    def __new__(cls, id):
        """Return possibly existing instance for `id`."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        if id not in cls._instances:
            cls._instances[id] = object.__new__(cls)
        return cls._instances[id]

    def __init__(self, id):
        """Initialize a :class:`Map` instance."""
        # Initialize properties only once.
        if hasattr(self, "id"): return
        values = self._load_attributes(id)
        self._attribution = values.get("attribution", {})
        self.background_color = values.get("background_color", "#e6e6e6")
        self.first_label_layer = values.get("first_label_layer", "")
        self.id = id
        self.format = values["format"]
        self.logo = values.get("logo", "default")
        self.name = values["name"]
        self.style_dict = values.get("style_json", {})
        self.style_gui = values.get("style_gui", {})
        self.style_url = values.get("style_url", "")
        self.tile_size = values.get("tile_size", 256)
        self.tile_url = values.get("tile_url", "")
        self.url_suffix = values.get("url_suffix", "")

    @property
    def attribution(self):
        """Return a list of attribution dictionaries."""
        return [{"text": k, "url": v} for k, v in self._attribution.items()]

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("maps", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        return poor.util.read_json(path)

    @property
    def style_json(self):
        """Return style JSON definition for raster sources."""
        if self.style_dict:
            return json.dumps(self.style_dict, ensure_ascii=False)
        return json.dumps({
            "id": "raster",
            "glyphs": "mapbox://fonts/mapbox/{fontstack}/{range}.pbf",
            "sources": {
                "raster": {
                    "type": "raster",
                    "tiles": [self.tile_url],
                    "tileSize": self.tile_size,
                },
            },
            "layers": [
                {
                    "id": "background",
                    "type": "background",
                    "paint": {
                        "background-color": self.background_color,
                    },
                },
                {
                    "id": "raster",
                    "type": "raster",
                    "source": "raster",
                },
            ],
        }, ensure_ascii=False)
