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

"""Managed persistent HTTP connections."""

import http.client
import poor
import sys
import urllib.parse

connections = {}

HEADERS = {"Connection": "Keep-Alive",
           "User-Agent": "poor-maps/{}".format(poor.__version__)}


def get_connection(url, timeout=None):
    """Return HTTP connection to `url`."""
    try:
        host = urllib.parse.urlparse(url).netloc
        return connections[host]
    except KeyError:
        return new_connection(url, timeout)

def new_connection(url, timeout=None):
    """Return new HTTP connection to `url`."""
    host = urllib.parse.urlparse(url).netloc
    timeout = timeout or poor.conf.download_timeout
    connections[host] = http.client.HTTPConnection(host, timeout=timeout)
    return connections[host]

def remove_connection(url):
    """Remove connection to `url` from pool of managed connections."""
    host = urllib.parse.urlparse(url).netloc
    with poor.util.silent(KeyError):
        del connections[host]

def request_url(url, encoding=None):
    """
    Request and return data at `url`.

    If `encoding` is ``None``, return bytes, otherwise decode data
    to text using `encoding`.
    """
    print("Requesting {}".format(url))
    httpc = get_connection(url)
    try:
        httpc.request("GET", url, headers=HEADERS)
        response = httpc.getresponse()
        if response.status != 200:
            raise Exception("Server responded {}: {}"
                            .format(repr(response.status),
                                    repr(response.reason)))

        blob = response.read()
        if encoding is None: return blob
        return blob.decode(encoding, errors="replace")
    except Exception as error:
        print("Failed to download data: {}"
              .format(str(error)), file=sys.stderr)

        remove_connection(url)
        raise # Exception
