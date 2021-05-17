# -*- coding: utf-8 -*-

# Copyright (C) 2018 Osmo Salomaa, 2018-2019 Rinigus, 2019 Purism SPC
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

import collections
import copy
import json
import os
import poor
import pyotherside

__all__ = ("Map","MapManager")


class Map:

    """Map data and style source."""

    def __new__(cls, id, values=None):
        """Return possibly existing instance for `id`."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        if id not in cls._instances:
            cls._instances[id] = object.__new__(cls)
        return cls._instances[id]

    def __init__(self, id, values = None):
        """Initialize a :class:`Map` instance."""
        # Initialize properties only once.
        if hasattr(self, "id"): return
        if values is None: values = self._load_attributes(id)
        self._attribution = values.get("attribution", {})
        self.background_color = values.get("background_color", "#e6e6e6")
        self.first_label_layer = values.get("first_label_layer", "")
        self.first_route_layer = values.get("first_route_layer", self.first_label_layer)
        self.id = id
        self.format = values["format"]
        self.keys = values.get("keys", [])
        self.fingerprint = values.get("fingerprint", {})
        self.lang = values.get("lang", "local")
        self.lang_key = values.get("lang_key", None)
        self.light = values.get("light", "day")
        self.logo = values.get("logo", "default")
        self.name = values["name"]
        self.style_dict = values.get("style_json", {})
        self.style_gui = values.get("style_gui", {})
        self.style_json_orig = None
        self.style_json_processed = None
        self.style_url = values.get("style_url", "")
        self.tile_size = values.get("tile_size", 256)
        self.tile_url = values.get("tile_url", "")
        self.type = values.get("type", "")
        self.url_suffix = values.get("url_suffix", "")
        self.vehicle = values.get("vehicle", "")
        for k in self.keys:
            v = poor.key.get(k)
            self.style_url = self.style_url.replace("#" + k + "#", v)
            self.tile_url = self.tile_url.replace("#" + k + "#", v)

    @property
    def attribution(self):
        """Return a list of attribution dictionaries."""
        return [{"text": k, "url": v} for k, v in self._attribution.items()]

    def complies(self, lang="", light="", type="", vehicle=""):
        """Return True if the applied restrictions are met"""
        return \
            (lang=='' or ((isinstance(self.lang, str) and lang==self.lang) or \
                          (isinstance(self.lang, dict) and lang in self.lang))) and \
            (light=='' or light==self.light) and \
            (type=='' or type==self.type or (type=="preview" and self.type=="traffic")) and \
            (vehicle=='' or self.vehicle==vehicle)

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("maps", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        return poor.util.read_json(path)

    def process_style(self, style, lang=None):
        if self.format != "mapbox-gl":
            return None
        if self.style_json_orig is None and (style is None or len(style)==0):
            return None
        if isinstance(style, str) and self.style_json_processed != style:
            import json
            sj = json.loads(style)
            for k,v in self.fingerprint.items():
                if k not in sj or v != sj[k]:
                    return None
            self.style_json_orig = style
        if not isinstance(self.lang, dict) or self.lang_key is None or lang not in self.lang:
            return None
        self.style_json_processed = self.style_json_orig.replace(self.lang_key, self.lang[lang])
        return self.style_json_processed

    def style_json(self, lang=None):
        """Return style JSON definition for raster sources or sources with defined style."""
        def process(s):
            if isinstance(self.lang, dict) and self.lang_key is not None:
                if lang in self.lang: r = self.lang[lang]
                elif "local" in self.lang: r = self.lang["local"]
                elif "en" in self.lang: r = self.lang["en"]
                else: r = self.lang.values()[0]
                s = s.replace(self.lang_key, r)
            return s
        if self.style_dict:
            return process(json.dumps(self.style_dict, ensure_ascii=False))
        glyphs = "mapbox://fonts/mapbox/{fontstack}/{range}.pbf"
        if poor.conf.font_provider == "osmscout":
            glyphs = "http://127.0.0.1:8553/v1/mbgl/glyphs?stack={fontstack}&range={range}"
        return json.dumps({
            "id": "raster",
            "glyphs": glyphs,
            "sources": {
                "raster": {
                    "type": "raster",
                    "tiles": [process(self.tile_url)],
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


class MapManager:

    """Collection of maps"""

    bias = {} # keeps bias available for all MapnManager instances
    fallback = {
        'hybrid': ['satellite', 'default'],
        'guidance': ['traffic', 'preview', 'default'],
        'preview': ['traffic', 'default'],
        'satellite': ['hybrid', 'default'],
        'terrain': ['default'],
        'traffic': ['preview', 'default'],
    }

    def __new__(cls):
        """Return possibly existing instance for current profile."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        profile = poor.conf.profile
        if profile not in cls._instances:
            cls._instances[profile] = object.__new__(cls)
        return cls._instances[profile]

    def __init__(self):
        """Initialize a :class:`MapManager` instance."""
        if hasattr(self, "profile"): return
        self.basemap = None
        self.basemap_types = set()
        self.current_lang = None
        self.current_map = None
        # load map descriptions
        maps = poor.util.get_basemaps()
        maps.sort(key=lambda x: x["pid"])
        self._providers = collections.defaultdict(list)
        for m in maps:
            provider = m.get("provider", m["name"])
            self._providers[provider].append(Map(m["pid"], values=m))

    @property
    def attribution(self):
        return self.current_map.attribution

    def _find_map(self):
        # fill restrictions
        restrictions = self._restrictions()
        for k,v in MapManager.bias.items():
            if restrictions[k]=='' and \
               (poor.conf.basemap_auto_mode or k not in ['type', 'vehicle']) and \
               (poor.conf.basemap_auto_light!='none' or k not in ['light']):
                restrictions[k] = v
        # find suitable replacements for type if needed
        reqtype = restrictions.get('type', '')
        if reqtype != '' and \
           reqtype not in self.basemap_types and \
           reqtype in MapManager.fallback:
            for k in MapManager.fallback[reqtype]:
                if k in self.basemap_types:
                    restrictions['type'] = k
                    break
        # find specific map
        while True:
            for m in self._providers[self.basemap]:
                if m.complies(**restrictions):
                    if self.current_map is None or self.current_map.id != m.id or \
                       self.current_lang is None or self.current_lang != poor.conf.basemap_lang:
                        self.current_map = m
                        self.current_lang = poor.conf.basemap_lang
                        pyotherside.send('basemap.changed')
                    return
            if len(restrictions.keys()) > 0:
                restrictions.popitem(last=True)
            else:
                break
        # nothing was found
        self.current_map = None
        raise ValueError('Error: could not find any map with provider %s' % self.basemap)

    @property
    def first_label_layer(self):
        return self.current_map.first_label_layer

    @property
    def first_route_layer(self):
        return self.current_map.first_route_layer

    @property
    def format(self):
        return self.current_map.format

    def list(self):
        providers = []
        default = poor.conf.get_default("basemap")
        for i in self._providers:
            provider = {
                "pid": i,
                "active": (i == self.basemap),
                "default": (i == default),
                "name": i
            }
            providers.append(provider)
        providers.sort(key=lambda x: x["name"])
        return providers

    @property
    def logo(self):
        return self.current_map.logo

    def options(self):
        def filler(v, l):
            if isinstance(v, set):
                for i in v:
                    if i not in l: l.append(i)
            else:
                if v not in l: l.append(v)
        restrictions = self._restrictions()
        enabled = collections.defaultdict(list)
        possible = collections.defaultdict(list)
        res = copy.copy(restrictions)
        keys = list(restrictions.keys())
        while True:
            k, v = restrictions.popitem(last=True)
            for m in self._providers[self.basemap]:
                if m.complies(**restrictions):
                    filler(getattr(m, k), enabled[k])
                filler(getattr(m, k), possible[k])
            if len(restrictions.keys()) == 0:
                break
        result = {}
        for k in keys:
            result[k] = []
            for v in possible[k]:
                if v == '': continue
                n = { 'name': v }
                n['enabled'] = (v in enabled[k])
                if isinstance(res[k],list):
                    act = (v in res[k])
                else:
                    act = (v == res[k])
                n['active'] = act
                n['current'] = (self.current_map is not None and getattr(self.current_map,k)==v)
                result[k].append(n)
        return result

    def process_style(self, style=None):
        return self.current_map.process_style(style=style, lang=poor.conf.basemap_lang)

    @property
    def providers(self):
        p = [i for i in self._providers.keys()]
        p.sort()
        return p

    def reset_bias(self, key):
        del MapManager.bias[key]
        self.update()

    def _restrictions(self):
        return collections.OrderedDict(
            [ ("type", poor.conf.basemap_type),
              ("light", poor.conf.basemap_light),
              ("lang", poor.conf.basemap_lang),
              ("vehicle", poor.conf.basemap_vehicle) ] )

    def set_basemap(self, id):
        if self.basemap == id: return
        self.basemap = id
        if self.basemap not in self._providers.keys():
            self.basemap = poor.conf.get_default("basemap")
        self.basemap_types = set([i.type for i in self._providers[self.basemap]])
        self._find_map()
        poor.conf.set_basemap(self.basemap)

    def set_bias(self, bias):
        for k, v in bias.items():
            MapManager.bias[k] = v
        self.update()

    @property
    def style_json(self):
        return self.current_map.style_json(lang=poor.conf.basemap_lang)

    @property
    def style_url(self):
        return self.current_map.style_url

    @property
    def style_gui(self):
        return self.current_map.style_gui

    def update(self):
        self._find_map()

    @property
    def url_suffix(self):
        return self.current_map.url_suffix
