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

import contextlib
import functools
import glob
import json
import math
import os
import poor
import random
import shutil
import stat
import subprocess
import sys
import traceback
import urllib.parse


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
         math.sin(y1) * math.cos(y2) * math.cos(x2-x1))

    y = math.sin(x2-x1) * math.cos(y2)
    bearing = math.degrees(math.atan2(y, x))
    return (bearing + 360) % 360

def calculate_distance(x1, y1, x2, y2):
    """Calculate distance in meters from point 1 to point 2."""
    # Using the haversine formula.
    # http://www.movable-type.co.uk/scripts/latlong.html
    x1, y1, x2, y2 = map(math.radians, (x1, y1, x2, y2))
    a = (math.sin((y2-y1)/2)**2 + math.sin((x2-x1)/2)**2 *
         math.cos(y1) * math.cos(y2))

    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return 6371000 * c

def calculate_segment_distance(x, y, x1, y1, x2, y2):
    """Calculate distance in meters from point to segment."""
    # This is not exactly correct, but maybe close enough,
    # given sufficiently short segments.
    med_dist_deg = math.sqrt((x - (x1+x2)/2)**2 + (y - (y1+y2)/2)**2)
    med_dist_m = calculate_distance(x, y, (x1+x2)/2, (y1+y2)/2)
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

def format_bearing(bearing):
    """Format `bearing` to a human readable string."""
    bearing = (bearing + 360) % 360
    bearing = int(round(bearing/45)*45)
    if bearing ==   0: return "north"
    if bearing ==  45: return "north-east"
    if bearing ==  90: return "east"
    if bearing == 135: return "south-east"
    if bearing == 180: return "south"
    if bearing == 225: return "south-west"
    if bearing == 270: return "west"
    if bearing == 315: return "north-west"
    if bearing == 360: return "north"
    raise ValueError("Unexpected bearing: {}"
                     .format(repr(bearing)))

def format_distance(meters, n=2):
    """Format `meters` to `n` significant digits and unit label."""
    if poor.conf.units == "american":
        feet = 3.28084 * meters
        return format_distance_american(feet, n)
    if poor.conf.units == "british":
        yards = 1.09361 * meters
        return format_distance_british(yards, n)
    return format_distance_metric(meters, n)

def format_distance_american(feet, n=2):
    """Format `feet` to `n` significant digits and unit label."""
    if (n > 1 and feet >= 1000) or feet >= 5280:
        distance = feet/5280
        units = "mi"
    else:
        # Let's not use units less than a foot.
        distance = feet
        units = "ft"
    ndigits = n - math.ceil(math.log10(abs(max(1, distance)) + 1/1000000))
    if units == "ft":
        ndigits = min(0, ndigits)
    distance = round(distance, ndigits)
    fstring = "{{:.{:d}f}} {{}}".format(max(0, ndigits))
    return fstring.format(distance, units)

def format_distance_british(yards, n=2):
    """Format `yards` to `n` significant digits and unit label."""
    if (n > 1 and yards >= 400) or yards >= 1760:
        distance = yards/1760
        units = "mi"
    else:
        # Let's not use units less than a yard.
        distance = yards
        units = "yd"
    ndigits = n - math.ceil(math.log10(abs(max(1, distance)) + 1/1000000))
    if units == "yd":
        ndigits = min(0, ndigits)
    distance = round(distance, ndigits)
    fstring = "{{:.{:d}f}} {{}}".format(max(0, ndigits))
    return fstring.format(distance, units)

def format_distance_metric(meters, n=2):
    """Format `meters` to `n` significant digits and unit label."""
    if meters >= 1000:
        distance = meters/1000
        units = "km"
    else:
        # Let's not use units less than a meter.
        distance = meters
        units = "m"
    ndigits = n - math.ceil(math.log10(abs(max(1, distance)) + 1/1000000))
    if units == "m":
        ndigits = min(0, ndigits)
    distance = round(distance, ndigits)
    fstring = "{{:.{:d}f}} {{}}".format(max(0, ndigits))
    return fstring.format(distance, units)

def format_filesize(bytes, n=2):
    """Format `bytes` to `n` significant digits and unit label."""
    if bytes > 1024**3:
        size = bytes/1024**3
        units = "GB"
    else:
        # Let's not use units less than a megabyte.
        size = bytes/1024**2
        units = "MB"
    ndigits = n - math.ceil(math.log10(abs(max(1, size)) + 1/1000000))
    if units == "MB":
        ndigits = min(0, ndigits)
    size = round(size, ndigits)
    fstring = "{{:.{:d}f}} {{}}".format(max(0, ndigits))
    return fstring.format(size, units)

def format_location_message(x, y, html=False):
    """Format coordinates of a point into a location message."""
    if html:
        return ('<a href="geo:{y:.5f},{x:.5f}">geo:{y:.5f},{x:.5f}</a><br>'
                '<a href="http://maps.google.com/?q={y:.5f},{x:.5f}">'
                'http://maps.google.com/?q={y:.5f},{x:.5f}</a>'
                .format(x=x, y=y))
    else:
        return ('geo:{y:.5f},{x:.5f} '
                'http://maps.google.com/?q={y:.5f},{x:.5f}'
                .format(x=x, y=y))

def format_time(seconds):
    """Format `seconds` to format ``# h # min``."""
    hours = int(seconds/3600)
    minutes = round((seconds % 3600) / 60)
    if hours == 0:
        return "{:d} min".format(minutes)
    return "{:d} h {:d} min".format(hours, minutes)

def get_basemaps():
    """Return a list of dictionaries of basemap attributes."""
    return list(filter(lambda x: x.get("type", "basemap") == "basemap",
                       _get_providers("tilesources", poor.conf.basemap)))

def get_geocoders():
    """Return a list of dictionaries of geocoder attributes."""
    return _get_providers("geocoders", poor.conf.geocoder)

def get_guides():
    """Return a list of dictionaries of guide attributes."""
    return _get_providers("guides", poor.conf.guide)

def get_overlays():
    """Return a list of dictionaries of overlay attributes."""
    return list(filter(lambda x: x.get("type", "basemap") == "overlay",
                       _get_providers("tilesources", *poor.conf.overlays)))

def _get_providers(directory, *active):
    """Return a list of dictionaries of provider attributes."""
    providers = []
    for parent in (poor.DATA_HOME_DIR, poor.DATA_DIR):
        for path in glob.glob("{}/{}/*.json".format(parent, directory)):
            pid = os.path.basename(path).replace(".json", "")
            # Local definitions override global ones.
            if pid in (x["pid"] for x in providers): continue
            with silent(Exception, tb=True):
                provider = read_json(path)
                provider["pid"] = pid
                provider["active"] = pid in active
                if not provider.get("hidden", False):
                    providers.append(provider)
    providers.sort(key=lambda x: x["name"])
    return providers

def get_routers():
    """Return a list of dictionaries of router attributes."""
    return _get_providers("routers", poor.conf.router)

def get_tilesources():
    """Return a list of dictionaries of tilesource attributes."""
    return _get_providers("tilesources")

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
        if os.path.isdir(directory):
            return directory
        print("Failed to create directory {}: {}"
              .format(repr(directory), str(error)),
              file=sys.stderr)
        raise # OSError
    return directory

def path2uri(path):
    """Convert local filepath to URI."""
    return "file://{}".format(urllib.parse.quote(path))

def popen(*args):
    """Run command `args` without waiting for it to complete."""
    subprocess.Popen(args)

def read_json(path):
    """Read data from JSON file at `path`."""
    try:
        with open(path, "r", encoding="utf_8") as f:
            return json.load(f)
    except Exception as error:
        print("Failed to read file {}: {}"
              .format(repr(path), str(error)),
              file=sys.stderr)
        raise # Exception

@contextlib.contextmanager
def silent(*exceptions, tb=False):
    """Try to execute body, ignoring `exceptions`."""
    try:
        yield
    except exceptions:
        if tb: traceback.print_exc()

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
