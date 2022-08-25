# -*- coding: utf-8 -*-

# Copyright (C) 2014 Osmo Salomaa, 2019 Rinigus
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

"""Translating addresses and names into coordinates."""

import importlib.machinery
import os
import poor
import random
import re
import socket
import sys
import traceback

from poor.i18n import _
from poor.openlocationcode.openlocationcode import isFull as olc_isFull, decode as olc_decode, recoverNearest as olc_recoverNearest

__all__ = ("Geocoder",)

RE_GEO_URI = re.compile(r"\bgeo:(-?[\d.]+),(-?[\d.]+)\b", re.IGNORECASE)
RE_LAT_LON = re.compile(r"^\s*(-?\d+(\.\d+)?)[^\w\-]+(-?\d+(\.\d+)?)\s*")
RE_PLUS_CODE_SHORT = re.compile(r"(^|\s)([23456789CFGHJMPQRVWX]{4,6}\+[23456789CFGHJMPQRVWX]{2,3})(\s|$)?")


class Geocoder:

    """Translating addresses and names into coordinates."""

    def __new__(cls, id):
        """Return possibly existing instance for `id`."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        if id not in cls._instances:
            cls._instances[id] = object.__new__(cls)
        return cls._instances[id]

    def __init__(self, id):
        """Initialize a :class:`Geocoder` instance."""
        # Initialize properties only once.
        if hasattr(self, "id"): return
        path, values = self._load_attributes(id)
        self._attribution = values.get("attribution", {})
        self.id = id
        self.name = values["name"]
        self._provider = None
        self._init_provider(re.sub(r"\.json$", ".py", path))

    @property
    def attribution(self):
        """Return a list of attribution dictionaries."""
        return [{"text": k, "url": v} for k, v in self._attribution.items()]

    def autocomplete(self, query, x=0, y=0, center_x=0, center_y=0, params=None):
        """
        Return a list of autocomplete dictionaries matching `query`.

        `params` can be used to specify a dictionary of geocoder-specific
        parameters.
        """
        params = params or {}
        if (not hasattr(self._provider, "autocomplete") or
            not callable(self._provider.autocomplete) or
            RE_GEO_URI.search(query) or
            RE_LAT_LON.search(query) or
            olc_isFull(query.strip())):
            return []
        try:
            results = self._provider.autocomplete(query=query, x=center_x, y=center_y, params=params)
        except Exception:
            print("Autocomplete failed:", file=sys.stderr)
            traceback.print_exc()
            return []
        for result in results:
            result["provider"] = self.id
        return results

    def _format_distance(self, x1, y1, x2, y2):
        """Calculate and format a human readable distance string."""
        distance = poor.util.calculate_distance(x1, y1, x2, y2)
        bearing  = poor.util.calculate_bearing(x1, y1, x2, y2)
        return poor.util.format_distance_and_bearing(distance, bearing)

    def parse_plus_code(self, ref_location):
        """
        This has been seperated from func(geocode) for the possibility of adding a loop later.

        Photon: first result is true in most tests, could use a loop later.
        Since some locations are not provided by Photon, this will fail.
        Fail Example: 857W+J3 Portofino, Metropolitan City of Genoa, Italy
        Since 'Portofino, Metropolitan City of Genoa, Italy' does not yield any
        results in Photon, an IndexError will be raised.
        
        Will return None and pass it as the final return
        to avoid any unwanted errors or misbehaviour 
        """
        try:
            results = self.geocode(query=ref_location)[0] 
        except IndexError:
            results = None

        return results

    def geocode(self, query, x=0, y=0, center_x=0, center_y=0, params=None):
        """
        Return a list of dictionaries of places matching `query`.

        `params` can be used to specify a dictionary of geocoder-specific
        parameters. If the current position as `x` and `y` are provided,
        the results will include correct distance and bearing.
        """
        params = params or {}
        # check special string queries
        if isinstance(query, str):
            # Parse coordinates if query is a geo URI.
            match = RE_GEO_URI.search(query)
            if match is not None:
                qy = float(match.group(1))
                qx = float(match.group(2))
                return [dict(title=_("Point from geo link"),
                             description=match.group(0),
                             x=qx,
                             y=qy,
                             distance=self._format_distance(x, y, qx, qy),
                             provider=self.id)]

            # Parse coordinates if query is "LAT,LON".
            match = RE_LAT_LON.search(query)
            if match is not None:
                qy = float(match.group(1))
                qx = float(match.group(3))
                return [dict(title=_("Point from coordinates"),
                             description=match.group(0),
                             x=qx,
                             y=qy,
                             distance=self._format_distance(x, y, qx, qy),
                             provider=self.id)]

            # Parse if query is a Plus code(Full Code)
            qtrimmed = query.strip()
            if olc_isFull(qtrimmed):
                latlng = olc_decode(qtrimmed).latlng()
                return [dict(title=qtrimmed.upper(),
                             description=_("Point from Plus code"),
                             x=latlng[1],
                             y=latlng[0],
                             distance=self._format_distance(x, y, latlng[1], latlng[0]),
                             provider=self.id)]

            # Parse if query is a Plus Code(Short Code)
            match = RE_PLUS_CODE_SHORT.search(qtrimmed)
            """
            For some reason, 857W+J3 Portofino, Metropolitan City of Genoa, Italy
            and 857W+J3 Portofino, Italy
            Does not match and raises:       
                [W] unknown:93 - file:///usr/share/harbour-pure-maps/qml/MapErrorPage.qml:93:27: Unable to assign [undefined] to QString
                [W] unknown:116 - file:///usr/share/harbour-pure-maps/qml/MapErrorPage.qml:116:36: Unable to assign QQuickAnchorLine to double
                [W] unknown:0 - "Illegal point coordinates when read as QGeoCoordinate, point 0"
            Even though C53X+C9X Cicagna, Metropolitan City of Genoa, Italy
            Matches and fails gracfully. 
            Might want to look into it. Might be getting matched elsewhere.
            """
            if match is not None:
                short_code = match.group().strip()
                ref_location = qtrimmed.strip(short_code).strip()
                with poor.util.silent(Exception):
                    #Is it okay if everything is under this????
                    results = self.parse_plus_code(ref_location)
                    if results is not None:
                        ref_lat = results['y']
                        ref_lng = results['x']
                        plus_code = olc_recoverNearest(short_code, ref_lat, ref_lng)
                        latlng = olc_decode(plus_code).latlng()
                        return [dict(title=plus_code.upper(),
                                     description=_("Point from Plus code"),
                                     x=latlng[1],
                                     y=latlng[0],
                                     distance=self._format_distance(x, y, latlng[1], latlng[0]),
                                     provider=self.id)]


        try:
            results = self._provider.geocode(query=query, x=center_x, y=center_y, params=params)
        except socket.timeout:
            return dict(error=True, message=_("Connection timed out"))
        except Exception:
            print("Geocoding failed:", file=sys.stderr)
            traceback.print_exc()
            return []
        for result in results:
            result["distance"] = self._format_distance(
                x, y, result["x"], result["y"])
            result["provider"] = self.id
        return results

    def _init_provider(self, path):
        """Initialize geocoding provider module from `path`."""
        name = "poor.geocoder.provider{:d}".format(random.randrange(10**12))
        loader = importlib.machinery.SourceFileLoader(name, path)
        self._provider = loader.load_module(name)

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("geocoders", "{}.json".format(id))
        path = os.path.join(poor.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(poor.DATA_DIR, leaf)
        return path, poor.util.read_json(path)

    def reverse(self, x, y, radius, limit=1, params=None):
        """
        Return a closest object near given coordinates.

        `params` can be used to specify a dictionary of geocoder-specific
        parameters.
        """
        params = params or {}

        try:
            results = self._provider.reverse(x=x, y=y, radius=radius, limit=limit, params=params)
        except socket.timeout:
            return dict(error=True, message=_("Connection timed out"))
        except Exception:
            print("Geocoding failed:", file=sys.stderr)
            traceback.print_exc()
            return []
        results_filtered = []
        for result in results:
            if "distance" not in result:
                result["distance"] = poor.util.calculate_distance(x, y, result["x"], result["y"])
            if result["distance"] < radius:
                result["provider"] = self.id
                results_filtered.append(result)
        return results_filtered
