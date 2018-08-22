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
import queue
import re
import sys
import threading
import urllib.parse

BROKEN_CONNECTION_ERRORS = [
    BrokenPipeError,
    ConnectionResetError,
    http.client.BadStatusLine,
]

HEADERS = {
    "Connection": "Keep-Alive",
    "User-Agent": "pure-maps/{}".format(poor.__version__),
}

RE_LOCALHOST = re.compile(r"://(127.0.0.1|localhost)\b")


class ConnectionPool:

    """A managed pool of persistent per-host HTTP connections."""

    def __init__(self, threads):
        """Initialize a :class:`ConnectionPool` instance."""
        self._alive = True
        self._all_connections = set()
        self._lock = threading.Lock()
        self._queue = {}
        self._threads = threads

    @poor.util.locked_method
    def _allocate(self, url):
        """Initialize a queue of HTTP connections to `url`."""
        key = self._get_key(url)
        if key in self._queue: return
        self._queue[key] = queue.LifoQueue()
        for i in range(self._threads):
            self._queue[key].put(None)

    def get(self, url):
        """Return an HTTP connection to `url`."""
        key = self._get_key(url)
        if key not in self._queue:
            self._allocate(url)
        while True:
            # Make sure no Queue.get call is left blocking
            # once the connection pool has been terminated.
            if not self._alive:
                raise Exception("Pool terminated, get aborted")
            with poor.util.silent(queue.Empty):
                connection = self._queue[key].get(timeout=1)
                break
        if connection is None:
            connection = self._new(url)
        return connection

    def _get_key(self, url):
        """Return a dictionary key for the host of `url`."""
        components = urllib.parse.urlparse(url)
        return "{}:{}".format(components.scheme, components.netloc)

    def is_alive(self):
        """Return ``True`` if pool is in use."""
        return self._alive

    def _new(self, url):
        """Initialize and return a new HTTP connection to `url`."""
        components = urllib.parse.urlparse(url)
        print("Establishing connection to {}".format(components.netloc))
        cls = {
            "http":  http.client.HTTPConnection,
            "https": http.client.HTTPSConnection,
        }[components.scheme]
        # Use a longer timeout for localhost connections where connection
        # problems are unlikely, but inefficient software and hardware
        # can make e.g. a routing query take a long time.
        # https://github.com/otsaloma/poor-maps/issues/23
        timeout = (600 if RE_LOCALHOST.search(url) else 15)
        connection = cls(components.netloc, timeout=timeout)
        self._all_connections.add(connection)
        return connection

    def put(self, url, connection):
        """Return `connection` to the pool of connections."""
        if not self._alive: return
        key = self._get_key(url)
        self._queue[key].task_done()
        self._queue[key].put(connection)

    def reset(self, url):
        """Close and re-establish HTTP connection to `url`."""
        if not self._alive: return
        connection = self.get(url)
        with poor.util.silent(Exception):
            connection.close()
        self.put(url, None)

    @poor.util.locked_method
    def terminate(self):
        """Close all connections and terminate."""
        if not self._alive: return
        for connection in self._all_connections:
            with poor.util.silent(Exception):
                connection.close()
        # Mark as dead so that subsequent operations fail.
        self._alive = False


pool = ConnectionPool(10)


def get(url, encoding=None, retry=1, headers=None):
    """Make a HTTP GET request at `url` and return response."""
    return _request("GET",
                    url,
                    body=None,
                    encoding=encoding,
                    retry=retry,
                    headers=headers)

def get_json(url, encoding="utf_8", retry=1, headers=None):
    """Make a HTTP GET request at `url` and return response parsed as JSON."""
    return _request_json("GET",
                         url,
                         body=None,
                         encoding=encoding,
                         retry=retry,
                         headers=headers)

def post(url, body, encoding=None, retry=1, headers=None):
    """Make a HTTP POST request at `url` and return response."""
    return _request("POST",
                    url,
                    body=body,
                    encoding=encoding,
                    retry=retry,
                    headers=headers)

def post_json(url, body, encoding="utf_8", retry=1, headers=None):
    """Make a HTTP POST request at `url` and return response parsed as JSON."""
    return _request_json("POST",
                         url,
                         body=body,
                         encoding=encoding,
                         retry=retry,
                         headers=headers)

def _request(method, url, body=None, encoding=None, retry=1, headers=None):
    """
    Make a HTTP request at `url` using `method`.

    `method` should be the name of a HTTP method, e.g. "GET" or "POST". `body`
    should be ``None`` for methods that don't expect data (e.g. GET) or the
    data to send (usually a string) for methods that do expect data (e.g. POST).
    If `encoding` is ``None``, return bytes, otherwise decode response data to
    text using `encoding`. Try again `retry` times in some particular cases
    that imply a connection error. `headers` should be a dictionary of custom
    headers to add to the defaults :attr:`http.HEADERS`.
    """
    print("{} {}".format(method, url))
    try:
        connection = pool.get(url)
        # Do relative requests (without scheme and netloc)
        # for better compatibility with different servers.
        components = urllib.parse.urlparse(url)
        components = ("", "") + components[2:]
        path = urllib.parse.urlunparse(components)
        headall = HEADERS.copy()
        headall.update(headers or {})
        if isinstance(body, str):
            # UTF-8 is likely to work in most cases,
            # otherwise caller can encode and give bytes.
            body = body.encode("utf_8")
        connection.request(method, path, body, headers=headall)
        response = connection.getresponse()
        # Always read response to avoid
        # http.client.ResponseNotReady: Request-sent.
        blob = response.read()
        if not 200 <= response.status <= 299:
            raise Exception("Server responded {}: {}".format(
                repr(response.status), repr(response.reason)))
        if encoding is None: return blob
        return blob.decode(encoding, errors="replace")
    except Exception as error:
        if not pool.is_alive(): raise
        connection.close()
        connection = None
        broken = tuple(BROKEN_CONNECTION_ERRORS)
        if not isinstance(error, broken) or retry == 0:
            name = error.__class__.__name__
            print("{} failed: {}: {}"
                  .format(method, name, str(error)),
                  file=sys.stderr)
            raise # Exception
        # If we haven't successfully returned a response,
        # nor reraised an Exception, we move on to try again.
        assert retry > 0
    finally:
        pool.put(url, connection)
    return _request(method, url, body, encoding, retry-1, headers)

def _request_json(method, url, body=None, encoding="utf_8", retry=1, headers=None):
    """
    Make a HTTP request, return response parsed as JSON.

    `method` should be the name of a HTTP method, e.g. "GET" or "POST". `body`
    should be ``None`` for methods that don't expect data (e.g. GET) or the
    data to send (usually a string) for methods that do expect data (e.g. POST).
    If `encoding` is ``None``, return bytes, otherwise decode response data to
    text using `encoding`. Try again `retry` times in some particular cases
    that imply a connection error. `headers` should be a dictionary of custom
    headers to add to the defaults :attr:`http.HEADERS`.
    """
    text = _request(method, url, body, encoding, retry, headers)
    if not text.strip() and retry > 0:
        # A blank return is probably an error.
        pool.reset(url)
        text = _request(method, url, body, encoding, retry, headers)
    try:
        if not text.strip():
            raise ValueError("Expected JSON, received blank")
        return json.loads(text)
    except Exception as error:
        name = error.__class__.__name__
        print("Failed to parse JSON data: {}: {}"
              .format(name, str(error)),
              file=sys.stderr)
        raise # Exception
