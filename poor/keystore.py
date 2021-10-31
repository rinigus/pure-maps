# -*- coding: utf-8 -*-

# Copyright (C) 2018 Rinigus
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

import poor

from collections import namedtuple
from poor.i18n import _

__all__ = ("KeyStore",)

DEFAULTS = {
    # https://developer.foursquare.com
    "FOURSQUARE_CLIENT": "<FOURSQUARE_CLIENT>",
    "FOURSQUARE_SECRET": "<FOURSQUARE_SECRET>",

    # mapbox.com
    "MAPBOX_KEY": "<MAPBOX_KEY>",

    # http://open.mapquestapi.com
    "MAPQUEST_KEY": "<MAPQUEST_KEY>",

    # https://geocoder.opencagedata.com/api [old key]
    "OPENCAGE_KEY": "<OPENCAGE_KEY>",

    # https://docs.stadiamaps.com/
    "STADIAMAPS_KEY": "<STADIAMAPS_KEY>",

    # here.com
    "HERE_APIKEY": "<HERE_APIKEY>",
}

ApiKeyDesc = namedtuple('ApiKeyDesc', ['description', 'label'])

KEYDESC = {
    "FOURSQUARE_CLIENT": ApiKeyDesc(_("Foursquare Client ID. Register at https://developer.foursquare.com and create your own Client ID and Client Secret keys"),
                                    _("Foursquare Client ID")),
    "FOURSQUARE_SECRET": ApiKeyDesc(_("Foursquare Client Secret"),_("Foursquare Client Secret")),

    # mapbox.com
    "MAPBOX_KEY": ApiKeyDesc(_("Mapbox API key. Register at https://www.mapbox.com and create your own API key"),
                             _("Mapbox API key")),

    # http://open.mapquestapi.com
    "MAPQUEST_KEY": ApiKeyDesc(_("MapQuest API key. Register at https://developer.mapquest.com/ and create your own API key"),
                               _("MapQuest API key")),

    # https://geocoder.opencagedata.com/api [old key]
    "OPENCAGE_KEY": ApiKeyDesc(_("OpenCage API key. Register at https://opencagedata.com/ and create your own API key"),
                               _("OpenCage API key")),

    # https://docs.stadiamaps.com/
    "STADIAMAPS_KEY": ApiKeyDesc(_("Stadia Maps API key. Register at https://stadiamaps.com/ and create your own API key"),
                                 _("Stadia Maps API key")),

    # here.com
    "HERE_APIKEY": ApiKeyDesc(_("HERE API Key. Register at https://developer.here.com and create your own App API Key"),
                              _("HERE API Key")),
}

class KeyStore:

    """Holding API keys"""

    def __init__(self):
        """Initialize a :class:`KeyStore` instance."""
        plain = {key: "" for key in DEFAULTS}
        poor.conf.register_keys(plain)

    def get(self, key):
        """Return API key with the preference of the personal one"""
        return poor.conf.get("keys." + key) or DEFAULTS.get(key, "")

    def get_mapbox_key(self):
        """Return Mapbox access key with the preference of the personal one"""
        p = poor.conf.get("keys.MAPBOX_KEY")
        if p: return p
        p = DEFAULTS.get("MAPBOX_KEY", "")
        if p: return p
        return "EMPTY"

    def list(self):
        """Return a list of dictionaries of API key properties"""
        keys = list(DEFAULTS.keys())
        keys.sort()
        return [ { "id": k,
                   "description": KEYDESC[k].description,
                   "label": KEYDESC[k].label,
                   "value": poor.conf.get("keys." + k)
        } for k in keys ]

    def set(self, key, value):
        return poor.conf.set("keys." + key, value.strip())
