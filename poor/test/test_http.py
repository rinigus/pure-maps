# -*- coding: utf-8 -*-

# Copyright (C) 2015 Osmo Salomaa
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

import poor.test
import threading
import time


class TestConnectionPool(poor.test.TestCase):

    def setup_method(self, method):
        self.pool = poor.http.ConnectionPool(2)
        self.http_url = "http://otsaloma.io/"
        self.https_url = "https://otsaloma.io/"

    def teardown_method(self, method):
        self.pool.terminate()

    def test_get__2(self):
        connection1 = self.pool.get(self.http_url)
        connection2 = self.pool.get(self.http_url)
        assert connection1 is not None
        assert connection2 is not None

    def test_get__http(self):
        connection = self.pool.get(self.http_url)
        assert connection is not None

    def test_get__https(self):
        connection = self.pool.get(self.https_url)
        assert connection is not None

    def test_get__terminate_blocking(self):
        kwargs = dict(target=self.pool.get, args=(self.http_url,))
        threading.Thread(**kwargs).start()
        threading.Thread(**kwargs).start()
        # The third of these calls should block, but gracefully exit
        # by raising an exception when terminate is called.
        threading.Thread(**kwargs).start()
        self.pool.terminate()
        time.sleep(3)

    def test_is_alive(self):
        assert self.pool.is_alive()
        self.pool.terminate()
        assert not self.pool.is_alive()

    def test_put(self):
        connection = self.pool.get(self.http_url)
        assert connection is not None
        self.pool.put(self.http_url, connection)
        connection = self.pool.get(self.http_url)
        assert connection is not None

    def test_reset(self):
        connection = self.pool.get(self.http_url)
        assert connection is not None
        self.pool.put(self.http_url, connection)
        self.pool.reset(self.http_url)
        connection = self.pool.get(self.http_url)
        assert connection is not None

    def test_terminate(self):
        self.pool.terminate()
        assert not self.pool.is_alive()


class TestModule(poor.test.TestCase):

    def test_get(self):
        url = "https://otsaloma.io/"
        blob = poor.http.get(url, encoding="utf_8")
        assert blob.strip().startswith("<!DOCTYPE html>")

    def test_get__error(self):
        url = "https://xxx.yyy.zzz/"
        self.assert_raises(Exception, poor.http.get, url)

    def test_get__non_200(self):
        url = "https://otsaloma.io/xxx/yyy/zzz"
        self.assert_raises(Exception, poor.http.get, url)

    def test_get_json(self):
        url = "https://otsaloma.io/pub/test.json"
        assert isinstance(poor.http.get_json(url), dict)

    def test_get_json__error(self):
        url = "https://otsaloma.io/pub/test.xml"
        self.assert_raises(Exception, poor.http.get_json, url)
