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
import json
import poor
import sys
import urllib.parse

_connections = {}

HEADERS = {"Connection": "Keep-Alive",
           "User-Agent": "poor-maps/{}".format(poor.__version__)}


def _get_connection(url, timeout=None):
    """Return HTTP connection to `url`."""
    with poor.util.silent(KeyError):
        return _connections[_get_key(url)]
    return _new_connection(url, timeout)

def _get_connection_class(url):
    """Return HTTP connection class for `url`."""
    protocol = urllib.parse.urlparse(url).scheme
    if protocol == "http":
        return http.client.HTTPConnection
    if protocol == "https":
        return http.client.HTTPSConnection
    raise ValueError("Bad URL: {}".format(repr(url)))

def _get_key(url):
    """Return a dictionary key for `url`."""
    protocol = urllib.parse.urlparse(url).scheme
    host = urllib.parse.urlparse(url).netloc
    return "{}://{}".format(protocol, host)

def _new_connection(url, timeout=None):
    """Return new HTTP connection to `url`."""
    cls = _get_connection_class(url)
    host = urllib.parse.urlparse(url).netloc
    timeout = timeout or poor.conf.download_timeout
    _connections[_get_key(url)] = cls(host, timeout=timeout)
    return _connections[_get_key(url)]

def _remove_connection(url):
    """Close and remove connection to `url` from the pool."""
    with poor.util.silent(Exception):
        _connections.pop(_get_key(url)).close()

def request_json(url, encoding="utf_8", retry=1):
    """
    Request, parse and return JSON data at `url`.

    Try again `retry` times in some particular cases that imply
    a connection error.
    """
    text = request_url(url, encoding, retry)
    if not text.strip() and retry > 0:
        # A blank return is probably an error.
        _remove_connection(url)
        text = request_url(url, encoding, retry-1)
    try:
        if not text.strip():
            raise ValueError("Expected JSON, received blank")
        return json.loads(text)
    except Exception as error:
        print("Failed to parse JSON data: {}: {}"
              .format(error.__class__.__name__, str(error)),
              file=sys.stderr)
        raise # Exception

def request_url(url, encoding=None, retry=1):
    """
    Request and return data at `url`.

    If `encoding` is ``None``, return bytes, otherwise decode data
    to text using `encoding`. Try again `retry` times in some particular
    cases that imply a connection error.
    """
    print("Requesting {}".format(url))
    try:
        httpc = _get_connection(url)
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
        _remove_connection(url)
        broken = (BrokenPipeError, http.client.BadStatusLine)
        if isinstance(error, broken) and retry > 0:
            # This probably means that the connection was broken.
            return request_url(url, encoding, retry-1)
        print("Failed to download data: {}: {}"
              .format(error.__class__.__name__, str(error)),
              file=sys.stderr)
        raise # Exception
