# -*- coding: utf-8 -*-

# Copyright (C) 2021 Rinigus
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

"""
Geocoding using HERE.

https://developer.here.com/
"""

import copy
import poor
import random
import urllib.parse
from poor.i18n import _

URL = ("https://discover.search.hereapi.com/v1/discover?"
       "apiKey=" + poor.key.get("HERE_APIKEY") +
       "&q={query}"
       "&limit={limit}"
       "&language={lang}")

URL_AUTOSUGGEST = ("https://autosuggest.search.hereapi.com/v1/autosuggest?"
                   "apiKey=" + poor.key.get("HERE_APIKEY") +
                   "&q={query}"
                   "&language={lang}")

URL_REVERSE = ("https://revgeocode.search.hereapi.com/v1/revgeocode?"
               "apiKey=" + poor.key.get("HERE_APIKEY") +
               "&at={lat},{lon}"
               "&language={lang}")
cache = {}

def autocomplete(query, x=0, y=0, params={}):
    """Return a list of autocomplete dictionaries matching `query`."""
    query = query.strip()
    if len(query) < 3: return []
    query = urllib.parse.quote_plus(query)
    lang = poor.util.get_default_language("en")
    url = URL_AUTOSUGGEST.format(**locals())
    if x and y:
        url += "&at={:.3f},{:.3f}".format(y,x)
    else:
        # HERE requires reference point
        url += "&at={:.3f},{:.3f}".format(59,24)
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)["items"]
    results = list(map(poor.AttrDict, results))
    results = parse_results(results)
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

def geocode(query, x=0, y=0, params={}):
    """Return a list of dictionaries of places matching `query`."""
    if isinstance(query, str):
        query = urllib.parse.quote_plus(query)
        limit = params.get("limit", 20)
        lang = poor.util.get_default_language("en")
        #lang = (lang if lang in ("de", "en", "it", "fr") else "en")
        url = URL.format(**locals())
        if x and y:
            url += "&at={:.3f},{:.3f}".format(y,x)
        else:
            # HERE requires reference point
            url += "&at={:.3f},{:.3f}".format(59,24)
    else: # should be query type with reference
        url = query['href'] + "&apiKey=" + poor.key.get("HERE_APIKEY")
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)["items"]
    results = list(map(poor.AttrDict, results))
    results = parse_results(results)
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

def merge(d, t, delim="\n", categ=""):
    if t:
        if categ: t = categ.format(t)
        if d: return d + delim + t
        return t
    return d

def parse_results(results):
    res = []
    for result in results:
        # x=lng, y=lat
        x, y = parse_position(result)
        res.append(
            dict(
                address=parse_address(result),
                label=parse_label(result),
                poi_type=parse_type(result),
                postcode=parse_postcode(result),
                title=result.title,
                description=parse_description(result),
                phone=parse_contact(result, "phone"),
                link=parse_contact(result, "www"),
                email=parse_contact(result, "email"),
                text=parse_extras(result),
                x=x,
                y=y,
                query=result)
        )
    return res

def parse_address(result):
    with poor.util.silent(Exception):
        return result.address.label
    return ""

def parse_contact(result, key):
    with poor.util.silent(Exception):
        t = []
        for c in result.contacts:
            if key in c:
                t.extend([v.value for v in c[key]])
        if len(t) == 1:
            return t[0]
        return ", ".join(t)
    return ""

def parse_description(result):
    r = parse_type(result)
    if r == "PM:Query":
        return _("Search suggestion")
    return r

def parse_extras(result):
    """Parse description from geocoding result."""
    description = ""
    with poor.util.silent(Exception):
        t = ", ".join([c.name for c in result.foodTypes])
        description = merge(description, t, categ=_("Food types: {}"))
    with poor.util.silent(Exception):
        t = []
        for i in result.openingHours:
            if "isOpen" not in i or i.isOpen:
                t.extend(i.text)
        t = "; ".join(t)
        description = merge(description, t, categ=_("Opening hours: {}"))
    return description

def parse_label(result):
    a = parse_address(result)
    t = result.title
    if a:
        return "{}: {}".format(t,a)
    return t

def parse_position(result):
    # As many POIs share the same coordinates in HERE, add random
    # jitter to spread the points on a map. Used spread corresponds to
    # ~50 cm on equator
    ja = 5e-6
    jitter_x = random.uniform(-ja, ja)
    jitter_y = random.uniform(-ja, ja)
    with poor.util.silent(Exception):
        return float(result.access[0].lng)+jitter_x, float(result.access[0].lat)+jitter_y
    with poor.util.silent(Exception):
        return float(result.position.lng)+jitter_x, float(result.position.lat)+jitter_y
    return 0, 0

def parse_postcode(result):
    with poor.util.silent(Exception):
        return result.address.postalCode
    return ""

def parse_type(result):
    with poor.util.silent(Exception):
        if "href" in result: return "PM:Query"
        return ", ".join([c.name.capitalize() for c in result.categories])
    return ""

def reverse(x, y, radius, limit=1, params={}):
    """Return a list of dictionaries of places nearby given coordinates."""
    lon = x
    lat = y
    lang = poor.util.get_default_language("en")
    url = URL_REVERSE.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)["items"]
    results = list(map(poor.AttrDict, results))
    results = parse_results(results)
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results
