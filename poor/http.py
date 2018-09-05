# -*- coding: utf-8 -*-

# Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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

# IMPLEMENTATION COMMENTS
#
# Connections are collected in pools, one queue of pools per each
# host. All requests are handled by one of the threads in a dedicated
# thread pool. This allows to use blocking HTTP requests for
# simplicity and, at the same time, ignore ongoing blocked connections
# when its time to stop the program.
#
# Turns out that calling connection close method can be either ignored
# or this call is ignored. For example, if the server has been
# suspended for one reason or another. As a result, the blocking call
# could result in blocking exit of all program if run in the main
# thread. By pushing all connection handling into daemon threads, the
# program is closed, as expected.


import http.client
import json
import poor
import queue
import re
import sys
import threading
import urllib.parse
from poor.attrdict import AttrDict

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

NTHREADS=4

class ConnectionPool:

    """A managed pool of persistent per-host HTTP connections."""

    def __init__(self, threads):
        """Initialize a :class:`ConnectionPool` instance."""
        self._alive = True
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
        """Mark pool as dead to stop all ongoing connections in threads. All inactive connections are closed."""
        if not self._alive: return
        # Mark as dead so that subsequent operations fail and current
        # connections will be dropped by the worker threads.
        self._alive = False
        # connection.close can sometimes block when its active in
        # another thread. Since we are terminating, closing of the
        # threads should take care of all active connections. here,
        # only passive connections are closed
        for key, q in self._queue.items():
            while not q.empty():
                with poor.util.silent(Exception):
                    connection = q.get_nowait()
                    if connection is not None:
                        print("Closing connection {}:{}".format(key, id(connection)))
                        connection.close()
                        q.task_done()
                        print("Connecttion {}:{} closed".format(key, id(connection)))


def _request_worker(task_queue, result_queue):
    """Worker for filling requests"""
    while True:
        task = task_queue.get()
        if task is None: break
        try:
            result = _request_real(method=task['method'], url=task['url'],
                                   body=task['body'], encoding=task['encoding'],
                                   retry=task['retry'],
                                   headers=task['headers'])
            result_queue.put({'result': result})
        except Exception as e:
            result_queue.put({'exception': e})
        task_queue.task_done()


class ThreadPool:
    """Pool of threads used to perform connections"""
    def __init__(self, threads):
        self._thread_queues = queue.LifoQueue()
        for i in range(threads):
            task = queue.Queue()
            result = queue.Queue()
            q = AttrDict( dict(task=task, result=result) )
            thread = threading.Thread( target=_request_worker,
                                       kwargs=dict(task_queue=q.task,
                                                   result_queue=q.result),
                                       daemon=True )
            thread.start()
            self._thread_queues.put(q)

    def request(self, method, url, body=None, encoding=None, retry=1, headers=None):
        task = dict(method=method, url=url, body=body,
                    encoding=encoding, retry=retry, headers=headers)
        while True:
            try:
                q = self._thread_queues.get(timeout=1)
                break
            except queue.Empty:
                if not pool.is_alive():
                    raise Exception("Connection pool closed")
        if q is None: raise Exception("No thread queue found")
        q.task.put(task)
        while True:
            try:
                result = q.result.get(timeout=1)
                q.result.task_done()
            except queue.Empty:
                if not pool.is_alive():
                    raise Exception("Connection pool closed")
                else: continue
            self._thread_queues.task_done()
            self._thread_queues.put(q)
            if 'exception' in result: raise result['exception']
            return result['result']


# keep at most the same number of connections to the same host as we have worker threads
pool = ConnectionPool(NTHREADS)
thread_pool = ThreadPool(NTHREADS)

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
    return thread_pool.request(method=method, url=url, body=body,
                               encoding=encoding, retry=retry, headers=headers)

def _request_real(method, url, body, encoding, retry, headers):
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
