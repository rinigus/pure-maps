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

"""
Listing nearby places using Foursquare.

http://developer.foursquare.com/docs/venues/explore
"""

import copy
import html
import itertools
import poor
import urllib.parse

CONF_DEFAULTS = {"sort_by_distance": False}

CLIENT_ID = "BP3KCWJXGQDXWVMYSVLWWRITMVZTG5XANJ43D2ZD0D5JMKCX"

URL = ("https://api.foursquare.com/v2/venues/explore"
       "?client_id={CLIENT_ID}"
       "&client_secret=JTINTTCK4S5V4RTZ40IJB0GIKDX1XT0LJVNRH2EZXNVLNZ2T"
       "&v=20140912"
       "&m=foursquare"
       "&query={query}"
       "&ll={y:.5f},{x:.5f}"
       "&limit=50"
       "&radius={radius:.0f}"
       "&sortByDistance={sort_by_distance}")

cache = {}

def nearby(query, near, radius, params):
    """Return X, Y and a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    sort_by_distance = str(int(poor.conf.guides.foursquare.sort_by_distance))
    x, y = prepare_point(near)
    url = URL.format(CLIENT_ID=CLIENT_ID, **locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    output = poor.http.request_json(url)
    results = [dict(title=item["venue"]["name"],
                    description=parse_description(item),
                    text=parse_text(item),
                    link=parse_link(item),
                    x=float(item["venue"]["location"]["lng"]),
                    y=float(item["venue"]["location"]["lat"]),
                    ) for item in
               itertools.chain.from_iterable(
                   group["items"] for group in
                   output["response"].get("groups", []))]

    if results and results[0]:
        cache[url] = copy.deepcopy((x, y, results))
    return x, y, results

def parse_description(item):
    """Parse description from search result `item`."""
    description = []
    with poor.util.silent(Exception):
        rating = float(item["venue"]["rating"])
        description.append("{:.1f}/10".format(rating))
    with poor.util.silent(Exception):
        description.append(item["venue"]["categories"][0]["name"])
    with poor.util.silent(Exception):
        description.append(item["venue"]["location"]["address"])
    description = ", ".join(description)
    with poor.util.silent(Exception):
        quote = item["tips"][0]["text"]
        description += "\n“{}”".format(quote)
    return description

def parse_link(item):
    """Parse hyperlink from search result `item`."""
    return ("http://foursquare.com/v/{}?ref={}"
            .format(item["venue"]["id"], CLIENT_ID))

def parse_text(item):
    """Parse blurb text from search result `item`."""
    lines = []
    with poor.util.silent(Exception):
        name = html.escape(item["venue"]["name"])
        lines.append('<font color="Theme.highlightColor">'
                     '<big>{}</big></font>'
                     .format(name))

    subtitle = []
    with poor.util.silent(Exception):
        rating = float(item["venue"]["rating"])
        subtitle.append('<font color="Theme.highlightColor">'
                        '<big>{:.1f}</big></font>'
                        '<small>&nbsp;/&nbsp;10</small>'
                        .format(rating))

    with poor.util.silent(Exception):
        category = html.escape(item["venue"]["categories"][0]["name"])
        subtitle.append("<small>{}</small>".format(category))
    lines.append("&nbsp;&nbsp;".join(subtitle))
    with poor.util.silent(Exception):
        quote = html.escape(item["tips"][0]["text"])
        lines.append("<small>“{}”</small>".format(quote))
    return "<br>".join(lines)

def prepare_point(point):
    """Return geocoded coordinates for `point`."""
    # Foursquare does geocoding too, but not that well.
    if isinstance(point, (list, tuple)):
        return point[0], point[1]
    geocoder = poor.Geocoder("default")
    results = geocoder.geocode(point, dict(limit=1))
    return results[0]["x"], results[0]["y"]
