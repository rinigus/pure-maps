# -*- coding: utf-8 -*-

# Copyright (C) 2016 Osmo Salomaa, 2018 Rinigus
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
Geocoding using Photon.

http://photon.komoot.de/
"""

import copy
import poor
import urllib.parse

URL = "http://photon.komoot.de/api/?q={query}&limit={limit}&lang={lang}"
cache = {}

def autocomplete(query, x, y, params):
    """Return a list of autocomplete dictionaries matching `query`."""
    if len(query) < 3: return []
    key = "autocomplete:{}".format(query)
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[key])
    results = geocode(query, params)
    cache[key] = copy.deepcopy(results)
    return results

def geocode(query, params):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    limit = params.get("limit", 10)
    lang = poor.util.get_default_language("en")
    lang = (lang if lang in ("de", "en", "it", "fr") else "en")
    url = URL.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)["features"]
    results = list(map(poor.AttrDict, results))
    results = [dict(
        address=parse_address_full(result),
        label=parse_address_full(result),
        poi_type=parse_type(result),
        postcode=parse_postcode(result),
        title=parse_title(result),
        description=parse_description(result),
        x=float(result.geometry.coordinates[0]),
        y=float(result.geometry.coordinates[1]),
    ) for result in results]
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results

def parse_address(props):
    """Parse address from geocoding result properties."""
    items = []
    with poor.util.silent(Exception):
        items.append(props.street)
    with poor.util.silent(Exception):
        items.append(props.housenumber)
    if not items:
        raise ValueError
    return " ".join(items)

def parse_address_full(result):
    """Parse full address from geocoding result."""
    description = parse_components(result.properties)
    title = parse_title(result)
    if description[0] != title:
        description.insert(0, title)
    return ", ".join(description).strip()

def parse_components(props):
    """Parse location components from geocoding result properties."""
    items = []
    with poor.util.silent(Exception):
        items.append(parse_address(props))
    with poor.util.silent(Exception):
        items.append(props.city)
    with poor.util.silent(Exception):
        items.append(props.state)
    with poor.util.silent(Exception):
        items.append(props.country)
    return items

def parse_description(result):
    """Parse description from geocoding result."""
    description = parse_components(result.properties)
    if description[0] == parse_title(result):
        del description[0]
    return ", ".join(description).strip()

def parse_postcode(result):
    with poor.util.silent(Exception):
        return result.properties.postcode
    return ""

def parse_title(result):
    """Parse title from geocoding result."""
    with poor.util.silent(Exception):
        return result.properties.name
    return parse_components(result.properties)[0]

def parse_type(result):
    """Parse OSM type from geocoding result"""
    items = []
    with poor.util.silent(Exception):
        if result.properties.osm_key not in ["amenity"]: 
            items.append(result.properties.osm_key.capitalize())
    with poor.util.silent(Exception):
        if result.properties.osm_value not in ["", "yes", "1"]: 
            items.append(result.properties.osm_value.capitalize())
    return ", ".join(items).strip()
