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

HEADERS = {"Connection": "Keep-Alive",
           "User-Agent": "poor-maps/{}".format(poor.__version__)}

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
        if not key in self._queue:
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


pool = ConnectionPool(1)


def request_json(url, encoding="utf_8", retry=1, headers=None):
    """
    Request, parse and return JSON data at `url`.

    Try again `retry` times in some particular cases that imply
    a connection error. `headers` should be a dictionary of custom
    headers to add to the defaults :attr:`http.HEADERS`.
    """
    text = request_url(url, encoding, retry, headers)
    if not text.strip() and retry > 0:
        # A blank return is probably an error.
        pool.reset(url)
        text = request_url(url, encoding, retry-1, headers)
    try:
        if not text.strip():
            raise ValueError("Expected JSON, received blank")
        return json.loads(text)
    except Exception as error:
        print("Failed to parse JSON data: {}: {}"
              .format(error.__class__.__name__, str(error)),
              file=sys.stderr)
        raise # Exception

def request_url(url, encoding=None, retry=1, headers=None):
    """
    Request and return data at `url`.

    If `encoding` is ``None``, return bytes, otherwise decode data
    to text using `encoding`. Try again `retry` times in some particular
    cases that imply a connection error. `headers` should be a dictionary
    of custom headers to add to the defaults :attr:`http.HEADERS`.
    """
    print("Requesting {}".format(url))
    try:
        connection = pool.get(url)
        headall = HEADERS.copy()
        headall.update(headers or {})
        connection.request("GET", url, headers=headall)
        response = connection.getresponse()
        # Always read response to avoid
        # http.client.ResponseNotReady: Request-sent.
        blob = response.read()
        if response.status != 200:
            raise Exception("Server responded {}: {}"
                            .format(repr(response.status),
                                    repr(response.reason)))

        if encoding is None: return blob
        return blob.decode(encoding, errors="replace")
    except Exception as error:
        if not pool.is_alive(): raise
        connection.close()
        connection = None
        # These probably mean that the connection was broken.
        broken = (BrokenPipeError, http.client.BadStatusLine)
        if not isinstance(error, broken) or retry == 0:
            print("Failed to download data: {}: {}"
                  .format(error.__class__.__name__, str(error)),
                  file=sys.stderr)
            raise # Exception
    finally:
        pool.put(url, connection)
    assert retry > 0
    return request_url(url, encoding, retry-1, headers)
