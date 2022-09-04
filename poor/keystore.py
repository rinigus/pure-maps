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

import copy
import poor

from collections import namedtuple
from poor.i18n import _
from .apikeys import Keys as ApiKeys

__all__ = ("KeyStore",)

HeaderDesc = namedtuple('HeaderDesc', ['description', 'title'])
LicenseDesc = namedtuple('LicenseDesc', ['text', 'title'])

# key has to start with the same prefix as used in the HEADERS, then
# underscore and folowed by any string
KEYNAMES = [
    # https://developer.foursquare.com
    "FOURSQUARE_CLIENT",
    "FOURSQUARE_SECRET",

    # here.com
    "HERE_APIKEY",

    # mapbox.com
    "MAPBOX_KEY",

    # maptiler.com
    "MAPTILER_KEY",

    # http://open.mapquestapi.com
    "MAPQUEST_KEY",

    # https://geocoder.opencagedata.com/api
    "OPENCAGE_KEY",

    # https://docs.stadiamaps.com/
    "STADIAMAPS_KEY"
]

HEADERS = {
    "FOURSQUARE": HeaderDesc(_('Register at <a href="https://developer.foursquare.com">https://developer.foursquare.com</a> and create your own Client ID and Client Secret keys'), "Foursquare"),
    "MAPBOX": HeaderDesc(_('Register at <a href="https://www.mapbox.com">https://www.mapbox.com</a> and create your own API key'), "Mapbox"),
    "MAPTILER": HeaderDesc(_('Register at <a href="https://maptiler.com">https://maptiler.com</a> and create your own API key'), "MapTiler"),
    "MAPQUEST": HeaderDesc(_('Register at <a href="https://developer.mapquest.com">https://developer.mapquest.com</a> and create your own API key'), "MapQuest"),
    "OPENCAGE": HeaderDesc(_('Register at <a href="https://opencagedata.com">https://opencagedata.com</a> and create your own API key'), "OpenCage"),
    "STADIAMAPS": HeaderDesc(_('Register at <a href="https://stadiamaps.com">https://stadiamaps.com</a> and create your own API key'), "Stadia Maps"),
    "HERE": HeaderDesc(_('Register at <a href="https://developer.here.com">https://developer.here.com</a> and create your own App API Key'), "HERE")
}

KEYDESC = {
    "FOURSQUARE_CLIENT": _("Foursquare Client ID"),
    "FOURSQUARE_SECRET": _("Foursquare Client Secret"),

    # mapbox.com
    "MAPBOX_KEY": _("Mapbox API key"),

    # maptiler.com
    "MAPTILER_KEY": _("MapTiler API key"),

    # http://open.mapquestapi.com
    "MAPQUEST_KEY": _("MapQuest API key"),

    # https://geocoder.opencagedata.com/api [old key]
    "OPENCAGE_KEY": _("OpenCage API key"),

    # https://docs.stadiamaps.com/
    "STADIAMAPS_KEY": _("Stadia Maps API key"),

    # here.com
    "HERE_APIKEY": _("HERE API Key"),
}

# List of keys that are made available only after end user license is
# accepted
LICENSES = {
    "HERE_APIKEY": LicenseDesc(
        _(
            '<p>Your Pure Maps installation has enabled support for HERE services.</p><br>'
            '<p>Please consult <a href="https://legal.here.com/en-gb/terms/here-end-user-terms">end-user terms</a>, '
            '<a href="https://legal.here.com/en-gb/terms/acceptable-use-policy">acceptable use policy</a>, '
            'and <a href="https://legal.here.com/en-gb/privacy">HERE Privacy policies</a>. '
            'In context of use of HERE and privacy policy, Pure Maps communicates with HERE using REST API.<p></br>'
            '<p>For <a href="{lruri}">legal reasons</a>, '
            'Pure Maps enables HERE search and routing in a dedicated "HERE Online" profile only. '
            'While not active anymore, see acceptable use policy of 2018 for details regarding '
            'use of HERE together with other providers under '
            '<a href="https://legal.here.com/en-gb/terms/acceptable-use-policy-2018">Layering and Modifications</a> '
            'section of the document.</p><br>'
            '<p>Please either accept the terms and the policy or decline them. If declined, '
            'HERE support will be inactive and '
            'can be enabled later by accepting the terms in Preferences under Licenses.</p>'
        ).format(lruri="https://knowledge.here.com/csm_kb?id=public_kb_csm_details&number=KB0017825"),
        _('HERE End-User Terms'))
}

class KeyStore:

    """Holding API keys"""

    def __init__(self):
        """Initialize a :class:`KeyStore` instance."""
        plain = {key: "" for key in KEYNAMES}
        poor.conf.register_keys(plain)
        licenses = {key: 0 for key in LICENSES}
        poor.conf.register_licenses(licenses)
        plain.update(ApiKeys)
        self.defaults = plain

    def license_accept(self, key):
        poor.conf.set("licenses." + key, 1)

    def license_decline(self, key):
        poor.conf.set("licenses." + key, -1)

    def get(self, key, skip_license_check=False):
        """Return API key with the preference of the personal one"""
        if not skip_license_check and key in LICENSES:
            if poor.conf.get("licenses." + key) <= 0:
                # license either declined or not accepted
                return ""
        return poor.conf.get("keys." + key).strip() or self.defaults.get(key, "").strip()

    def licenses(self):
        return [dict(id = key,
                     text = LICENSES[key].text,
                     title = LICENSES[key].title,
                     status = poor.conf.get("licenses." + key)) for key in LICENSES]

    def get_licenses_missing(self):
        missing = []
        for key in LICENSES:
            if not poor.conf.get("licenses." + key) and self.get(key, skip_license_check=True):
                missing.append(dict(id = key,
                                    text = LICENSES[key].text,
                                    title = LICENSES[key].title))
        return missing

    @property
    def has_here(self):
        return self.get("HERE_APIKEY")

    @property
    def has_mapbox(self):
        return self.mapbox_key

    @property
    def has_maptiler(self):
        return self.maptiler_key

    def list(self, headers=False):
        """Return a list of dictionaries of API key properties"""
        keys = copy.copy(KEYNAMES)
        keys.sort()
        head = None
        vals = []
        for k in keys:
            if head is None or k.split('_')[0] != head:
                head = k.split('_')[0]
                vals.append(dict(header = HEADERS[head].title,
                                 description = HEADERS[head].description))
            vals.append( dict( id=k,
                               label=KEYDESC[k],
                               value=poor.conf.get("keys." + k),
                               needs_license=(k in LICENSES),
                               license_accepted=(1 if k in LICENSES and poor.conf.get("licenses." + k)>0 else 0)
                               ) )
        return vals

    @property
    def mapbox_key(self):
        """Return Mapbox access key with the preference of the personal one"""
        return self.get("MAPBOX_KEY")

    @property
    def maptiler_key(self):
        """Return Mapbox access key with the preference of the personal one"""
        return self.get("MAPTILER_KEY")

    def set(self, key, value):
        return poor.conf.set("keys." + key, value.strip())
