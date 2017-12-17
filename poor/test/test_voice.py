# -*- coding: utf-8 -*-

# Copyright (C) 2017 Osmo Salomaa
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

import os
import poor.test
import tempfile
import time


class TestVoiceGenerator(poor.test.TestCase):

    def setup_method(self, method):
        self.generator = poor.VoiceGenerator()

    def test_engines(self):
        for engine in self.generator.engines:
            if not engine.supports("en"): continue
            handle, fname = tempfile.mkstemp(dir=self.generator._tmpdir)
            engine("en").make_wav("just testing", fname)
            assert os.path.isfile(fname)
            assert os.path.getsize(fname) > 256

    def test_clean(self):
        self.generator.set_voice("en")
        self.generator.make("just testing")
        time.sleep(1)
        self.generator.clean()
        assert not os.listdir(self.generator._tmpdir)

    def test_get(self):
        self.generator.set_voice("en")
        if not self.generator.active: return
        self.generator.make("just testing")
        time.sleep(1)
        fname = self.generator.get("just testing")
        assert os.path.isfile(fname)
        assert os.path.getsize(fname) > 256

    def test_make(self):
        self.generator.set_voice("en")
        self.generator.make("just testing")
        time.sleep(1)

    def test_quit(self):
        self.generator.set_voice("en")
        self.generator.make("just testing")
        time.sleep(1)
        self.generator.quit()
        assert not os.path.isdir(self.generator._tmpdir)

    def test_set_voice(self):
        self.generator.set_voice("en")
        self.generator.set_voice("en", "male")
        self.generator.set_voice("en", "female")
        self.generator.set_voice("en_US")
        self.generator.set_voice("en_XX")
