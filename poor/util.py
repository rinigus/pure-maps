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

"""Miscellaneous helper functions."""

import collections
import contextlib
import functools
import glob
import poor.gpxpy.parser
import json
import locale
import math
import os
import poor
import random
import shutil
import stat
import subprocess
import sys
import time
import traceback
import urllib.parse

from poor.i18n import _


@contextlib.contextmanager
def atomic_open(path, mode="w", *args, **kwargs):
    """A context manager for atomically writing a file."""
    # This is a simplified version of atomic_open from gaupol.
    # https://github.com/otsaloma/gaupol/blob/master/aeidon/util.py
    path = os.path.realpath(path)
    suffix = random.randint(1, 10**9)
    temp_path = "{}.tmp{}".format(path, suffix)
    try:
        if os.path.isfile(path):
            # If the file exists, use the same permissions.
            # Note that all other file metadata, including
            # owner and group, is not preserved.
            with open(temp_path, "w") as f: pass
            st = os.stat(path)
            os.chmod(temp_path, stat.S_IMODE(st.st_mode))
        with open(temp_path, mode, *args, **kwargs) as f:
            yield f
            f.flush()
            os.fsync(f.fileno())
        try:
            # Requires Python 3.3 or later.
            # Can fail in the unlikely case that
            # paths are on different filesystems.
            os.replace(temp_path, path)
        except OSError:
            # Fall back on a non-atomic operation.
            shutil.move(temp_path, path)
    finally:
        with silent(Exception):
            os.remove(temp_path)

def calculate_bearing(x1, y1, x2, y2):
    """Calculate bearing in degrees from point 1 to point 2."""
    # This is the initial bearing on the great-circle path.
    # http://www.movable-type.co.uk/scripts/latlong.html
    x1, y1, x2, y2 = map(math.radians, (x1, y1, x2, y2))
    x = (math.cos(y1) * math.sin(y2) -
         math.sin(y1) * math.cos(y2) * math.cos(x2 - x1))
    y = math.sin(x2 - x1) * math.cos(y2)
    bearing = math.degrees(math.atan2(y, x))
    return (bearing + 360) % 360

def calculate_distance(x1, y1, x2, y2):
    """Calculate distance in meters from point 1 to point 2."""
    # Using the haversine formula.
    # http://www.movable-type.co.uk/scripts/latlong.html
    x1, y1, x2, y2 = map(math.radians, (x1, y1, x2, y2))
    a = (math.sin((y2 - y1)/2)**2 +
         math.sin((x2 - x1)/2)**2 * math.cos(y1) * math.cos(y2))
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return 6371000 * c

def calculate_segment_distance(x, y, x1, y1, x2, y2):
    """Calculate distance in meters from point to segment."""
    # This is not exactly correct, but maybe close enough,
    # given sufficiently short segments.
    med_dist_deg = math.sqrt((x - (x1 + x2)/2)**2 + (y - (y1 + y2)/2)**2)
    med_dist_m = calculate_distance(x, y, (x1 + x2)/2, (y1 + y2)/2)
    if med_dist_deg == 0 or med_dist_m == 0: return 0
    seg_dist_deg = math.sqrt(poor.polysimp.get_sq_seg_dist(x, y, x1, y1, x2, y2))
    return seg_dist_deg * (med_dist_m / med_dist_deg)

@functools.lru_cache(None)
def cpu_count():
    """Return the number of CPUs in the system."""
    # os.cpu_count doesn't return the true count.
    # http://stackoverflow.com/q/30119604
    count = len(glob.glob("/sys/devices/system/cpu/cpu[0123456789]*"))
    if count > 0: return count
    print("Failed to detect CPU count", file=sys.stderr)
    return max(2, os.cpu_count())

def decode_epl(string, precision=5):
    """
    Decode Google Encoded polyline string representation.

    `precision` usually defaults to five, but note that it can vary!
    Return X and Y coordinates as separate lists.

    http://developers.google.com/maps/documentation/utilities/polylinealgorithm
    """
    # Copied and adapted from various sources, see e.g.
    # http://facstaff.unca.edu/mcmcclur/GoogleMaps/EncodePolyline/decode.js
    # http://seewah.blogspot.fi/2009/11/gpolyline-decoding-in-python.html
    # http://github.com/mapbox/polyline/blob/master/src/polyline.js
    i = x = y = 0
    xout = []
    yout = []
    while i < len(string):
        b = shift = result = 0
        while True:
            b = ord(string[i]) - 63
            i = i + 1
            result |= (b & 0x1f) << shift
            shift += 5
            if b < 0x20: break
        dy = ~(result >> 1) if result & 1 else result >> 1
        y += dy
        shift = result = 0
        while True:
            b = ord(string[i]) - 63
            i = i + 1
            result |= (b & 0x1f) << shift
            shift += 5
            if b < 0x20: break
        dx = ~(result >> 1) if result & 1 else result >> 1
        x += dx
        xout.append(x / 10**precision)
        yout.append(y / 10**precision)
    return xout, yout

def find_closest(xs, ys, x, y, subset=None):
    """Return index of the item closest to `x`, `y`."""
    # This is not exactly correct, but should be significantly
    # faster than using the haversine formula.
    min_index = 0
    min_dist = 360**2
    for i in subset or range(len(xs)):
        dist = (xs[i] - x)**2 + (ys[i] - y)**2
        if dist < min_dist:
            min_index = i
            min_dist = dist
    return min_index

def format_distance(meters, n=2, short=True):
    """Format `meters` to `n` significant digits and unit label."""
    if poor.conf.units == "american":
        feet = 3.28084 * meters
        return format_distance_american(feet, n, short)
    if poor.conf.units == "british":
        yards = 1.09361 * meters
        return format_distance_british(yards, n, short)
    return format_distance_metric(meters, n, short)

def format_distance_american(feet, n=2, short=True):
    """Format `feet` to `n` significant digits and unit label."""
    if (n > 1 and feet >= 1000) or feet >= 5280:
        distance = feet / 5280
        ndigits = n - get_ndigits(distance)
        distance = round(distance, ndigits)
        distance = "{{:.{:d}f}}".format(max(0, ndigits)).format(distance)
        units = _("mi") if short else _("miles")
        return "{distance} {units}".format(**locals())
    else:
        distance = feet
        ndigits = n - get_ndigits(distance)
        ndigits = min(0, ndigits)
        distance = round(distance, ndigits)
        distance = "{{:.{:d}f}}".format(max(0, ndigits)).format(distance)
        units = _("ft") if short else _("feet")
        return "{distance} {units}".format(**locals())

def format_distance_british(yards, n=2, short=True):
    """Format `yards` to `n` significant digits and unit label."""
    if (n > 1 and yards >= 400) or yards >= 1760:
        distance = yards / 1760
        ndigits = n - get_ndigits(distance)
        distance = round(distance, ndigits)
        distance = "{{:.{:d}f}}".format(max(0, ndigits)).format(distance)
        units = _("mi") if short else _("miles")
        return "{distance} {units}".format(**locals())
    else:
        distance = yards
        ndigits = n - get_ndigits(distance)
        ndigits = min(0, ndigits)
        distance = round(distance, ndigits)
        distance = "{{:.{:d}f}}".format(max(0, ndigits)).format(distance)
        units = _("yd") if short else _("yards")
        return "{distance} {units}".format(**locals())

def format_distance_metric(meters, n=2, short=True):
    """Format `meters` to `n` significant digits and unit label."""
    if meters >= 1000:
        distance = meters / 1000
        ndigits = n - get_ndigits(distance)
        distance = round(distance, ndigits)
        distance = "{{:.{:d}f}}".format(max(0, ndigits)).format(distance)
        units = _("km") if short else _("kilometers")
        return "{distance} {units}".format(**locals())
    else:
        distance = meters
        ndigits = n - get_ndigits(distance)
        ndigits = min(0, ndigits)
        distance = round(distance, ndigits)
        distance = "{{:.{:d}f}}".format(max(0, ndigits)).format(distance)
        units = _("m") if short else _("meters")
        return "{distance} {units}".format(**locals())

def format_distance_and_bearing(meters, bearing, n=2, short=True):
    """Format `meters` and `bearing` to a human readable string."""
    distance = format_distance(meters, n, short)
    f = lambda x: x.format(distance=distance)
    bearing = (bearing + 360) % 360
    bearing = int(round(bearing/45) * 45)
    if bearing ==   0: return f(_("{distance} north"))
    if bearing ==  45: return f(_("{distance} north-east"))
    if bearing ==  90: return f(_("{distance} east"))
    if bearing == 135: return f(_("{distance} south-east"))
    if bearing == 180: return f(_("{distance} south"))
    if bearing == 225: return f(_("{distance} south-west"))
    if bearing == 270: return f(_("{distance} west"))
    if bearing == 315: return f(_("{distance} north-west"))
    if bearing == 360: return f(_("{distance} north"))
    raise ValueError("Unexpected bearing: {}".format(repr(bearing)))

def format_location_message(x, y, html=False, osm=True, gmaps=False):
    """Format coordinates of a point into a location message."""
    if osm: osm_url = short_osm(y,x)
    if gmaps: gm = 'http://maps.google.com/?q={y:.5f},{x:.5f}'.format(x=x, y=y)
    if html:
        r = ('<a href="geo:{y:.5f},{x:.5f}">geo:{y:.5f},{x:.5f}</a>'
             .format(x=x, y=y))
        if osm: r += ('<br><a href="{osm}">{osm}</a>'
                      .format(osm=osm_url))
        if gmaps: r += ('<br><a href="{gm}">{gm}</a>'
                      .format(gm=gm))
    else:
        r = ('geo:{y:.5f},{x:.5f}'
                .format(x=x, y=y))
        if osm: r += (' {osm}'
                      .format(osm=osm_url))
        if gmaps: r += (' {gm}'
                      .format(gm=gm))
    return r

def format_time(seconds):
    """Format `seconds` to format ``# h # min``."""
    seconds = 60 * round(seconds/60)
    hours = int(seconds/3600)
    minutes = round((seconds % 3600) / 60)
    if hours == 0:
        return _("{:d} min").format(minutes)
    return _("{:d} h {:d} min").format(hours, minutes)

def get_basemaps():
    """Return a list of dictionaries of basemap attributes."""
    return _get_providers("maps",
                          poor.conf.get_default("basemap"),
                          poor.conf.basemap)

def get_default_language(fallback="en"):
    """Return the system default language code or `fallback`."""
    return (locale.getdefaultlocale()[0] or fallback)[:2]

def get_default_locale(fallback="en_US"):
    """Return the system default locale code or `fallback`."""
    return (locale.getdefaultlocale()[0] or fallback)[:5]

def get_geocoders():
    """Return a list of dictionaries of geocoder attributes."""
    return _get_providers("geocoders",
                          poor.conf.get_default("geocoder"),
                          poor.conf.geocoder)

def get_guides():
    """Return a list of dictionaries of guide attributes."""
    return _get_providers("guides",
                          poor.conf.get_default("guide"),
                          poor.conf.guide)

def get_ndigits(x):
    """Return the amount of digits left of the decimal point in `x`."""
    return math.ceil(math.log10(abs(max(1, x)) + 1/1000000))

def get_provider_class(type):
    """Return provider class of given type."""
    if type == "geocoder":
        return poor.Geocoder
    if type == "guide":
        return poor.Guide
    if type == "map":
        return poor.Map
    if type == "router":
        return poor.Router
    raise ValueError("Bad type: {}".format(repr(type)))

def _get_providers(directory, default, active):
    """Return a list of dictionaries of provider attributes."""
    def matches(pid, ref):
        # Allow default and active to be either strings or lists of strings.
        return (pid in ref if isinstance(ref, list) else pid == ref)
    providers = []
    for parent in (poor.DATA_HOME_DIR, poor.DATA_DIR):
        for path in glob.glob("{}/{}/*.json".format(parent, directory)):
            pid = os.path.basename(path).replace(".json", "")
            # Local definitions override global ones.
            if pid in (x["pid"] for x in providers): continue
            provider = read_json(path)
            if provider.get("hidden", False): continue
            requires = provider.get("requires", [])
            if not all(map(requirement_found, requires)): continue
            provider["pid"] = pid
            provider["default"] = matches(pid, default)
            provider["active"] = matches(pid, active)
            providers.append(provider)
    providers.sort(key=lambda x: x["name"])
    return providers

def get_routers():
    """Return a list of dictionaries of router attributes."""
    return _get_providers("routers",
                          poor.conf.get_default("router"),
                          poor.conf.router)

def locked_method(function):
    """
    Decorator for methods to be run thread-safe.

    Requires class to have an instance variable '_lock'.
    """
    @functools.wraps(function)
    def wrapper(*args, **kwargs):
        with args[0]._lock:
            return function(*args, **kwargs)
    return wrapper

def makedirs(directory):
    """Create and return `directory` or raise :exc:`OSError`."""
    directory = os.path.abspath(directory)
    if os.path.isdir(directory):
        return directory
    try:
        os.makedirs(directory)
    except OSError as error:
        # Check again, in case another thread succeeded.
        if os.path.isdir(directory):
            return directory
        print("Failed to create directory {}: {}"
              .format(repr(directory), str(error)),
              file=sys.stderr)
        raise # OSError
    return directory

def short_osm(lat, lon, zoom=16):
    """Return a short link representing a location in OpenStreetmap.

    Provide coordinates and optional zoom level. e.g.:

    >>> short_osm(50.671530961990356, 6.09715461730957)
    http://osm.org/go/0GAjIv8h
    >>> short_osm(0, 0, 3)
    http://osm.org/go/wAAA--
    >>> short_osm(0, 0, 4)
    http://osm.org/go/wAAA
    """
    # OSM short link, from https://gist.github.com/mdornseif/5652824
    # osm_shortlink.py - MAximillian Dornseif 2013 - Public Domain
    # see http://wiki.openstreetmap.org/wiki/Shortlink
    # https://github.com/openstreetmap/openstreetmap-website/blob/master/lib/short_link.rb
    # and makeShortCode in
    # https://github.com/openstreetmap/openstreetmap-website/blob/master/app/assets/javascripts/application.js


    # array of 64 chars to encode 6 bits. this is almost like base64 encoding, but
    # the symbolic chars are different, as base64's + and / aren't very
    # URL-friendly.
    ARRAY = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_~'

    def _encode(lat, lon, z):
        """given a location and zoom, return a short string representing it."""
        x = int((lon + 180.0) * 2**32 / 360.0)
        y = int((lat +  90.0) * 2**32 / 180.0)
        code = _interleave(x, y)
        str = ''
        # add eight to the zoom level, which approximates an accuracy of
        # one pixel in a tile.
        for i in range(int(math.ceil((z + 8) / 3.0))):
            digit = (code >> (56 - 6 * i)) & 0x3f;
            str += ARRAY[digit]
        # append characters onto the end of the string to represent
        # partial zoom levels (characters themselves have a granularity
        # of 3 zoom levels).
        for i in range((z + 8) % 3):
            str += "-"
        return str

    def _interleave(x, y):
        """combine 2 32 bit integers to a 64 bit integer"""
        c = 0
        for i in range(31, 0, -1):
          c = (c << 1) | ((x >> i) & 1)
          c = (c << 1) | ((y >> i) & 1)
        return c

    return 'http://osm.org/go/' + _encode(lat, lon, zoom) + "?m"

def path2uri(path):
    """Convert local filepath to URI."""
    return "file://{}".format(urllib.parse.quote(path))

def popen(*args):
    """Run command `args` without waiting for it to complete."""
    subprocess.Popen(args)

def read_gpx(path):
    """Read and join tracks from GPX file at `path`."""
    try:
        with open(path, "r", encoding="utf_8") as f:
            gpx = poor.gpxpy.parser.GPXParser(f).parse()
            x, y = [], []
            for track in gpx.tracks:
                for segment in track.segments:
                    for point in segment.points:
                        x.append(point.longitude)
                        y.append(point.latitude)
    except Exception as error:
        print("Failed to read file {}: {}"
              .format(repr(path), str(error)),
              file=sys.stderr)
        raise # Exception
    return x, y
    
def read_json(path):
    """Read data from JSON file at `path`."""
    try:
        with open(path, "r", encoding="utf_8") as f:
            data = json.load(f, object_pairs_hook=collections.OrderedDict)
    except Exception as error:
        print("Failed to read file {}: {}"
              .format(repr(path), str(error)),
              file=sys.stderr)
        raise # Exception
    # Translatable field names are prefixed with an underscore,
    # e.g. "_description". Translate the values of these fields
    # and drop the underscore from the field name.
    def translate(value):
        if isinstance(value, list):
            return list(map(translate, value))
        return _(value)
    if isinstance(data, dict):
        for key in [x for x in data if x.startswith("_")]:
            data[key[1:]] = translate(data.pop(key))
    return data

def requirement_found(name):
    """
    Return ``True`` if `name` can be found on the system.

    `name` can be either a command, in which case it needs to be found in $PATH
    and it needs to be executable, or it can be a full absolute path to a file
    or a directory, in which case it needs to exist.
    """
    if os.path.isabs(name):
        return os.path.exists(name)
    return shutil.which(name) is not None

def round_distance(meters, n=2):
    """Round `meters` to `n` significant digits in native units."""
    mile = 1609.34
    yard = 0.9144
    foot = 0.3048
    if poor.conf.units == "american":
        if meters >= mile:
            return siground(meters/mile, n) * mile
        n = min(n, math.ceil(math.log10(meters/foot)))
        return siground(meters/foot, n) * foot
    elif poor.conf.units == "british":
        if meters >= mile:
            return siground(meters/mile, n) * mile
        n = min(n, math.ceil(math.log10(meters/yard)))
        return siground(meters/yard, n) * yard
    else: # Metric
        if meters >= 1000:
            return siground(meters/1000, n) * 1000
        n = min(n, math.ceil(math.log10(meters)))
        return siground(meters, n)

def siground(x, n):
    """Round `x` to `n` significant digits."""
    mult = 10**(n - math.floor(math.log10(x)) - 1)
    return round(x * mult) / mult

@contextlib.contextmanager
def silent(*exceptions, tb=False):
    """Try to execute body, ignoring `exceptions`."""
    try:
        yield
    except exceptions:
        if tb: traceback.print_exc()

def sleep(seconds):
    """Wait for the given amount of seconds."""
    time.sleep(seconds)
    return True

def sorted_by_distance(items, x, y):
    """Return `items` sorted by distance from given coordinates."""
    for item in items:
        item["__dist"] = calculate_distance(item["x"], item["y"], x, y)
    items = sorted(items, key=lambda z: z["__dist"])
    for item in items:
        del item["__dist"]
    return items

def write_json(data, path):
    """Write `data` to JSON file at `path`."""
    try:
        makedirs(os.path.dirname(path))
        with atomic_open(path, "w", encoding="utf_8") as f:
            json.dump(data, f, ensure_ascii=False, indent=4, sort_keys=True)
    except Exception as error:
        print("Failed to write file {}: {}"
              .format(repr(path), str(error)),
              file=sys.stderr)
        raise # Exception
