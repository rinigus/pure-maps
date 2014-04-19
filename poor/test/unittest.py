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

"""Base class for unit test cases."""

__all__ = ("TestCase",)


class TestCase:

    """Base class for unit test cases."""

    def setUp(self):
        """Compatibility alias for :meth:`setup_method`."""
        self.setup_method(None)

    def setup_method(self, method):
        """Set state for executing tests in `method`."""
        pass

    def tearDown(self):
        """Compatibility alias for :meth:`teardown_method`."""
        self.teardown_method(None)

    def teardown_method(self, method):
        """Remove state set for executing tests in `method`."""
        pass

    def test___init__(self):
        """Make sure that :meth:`setup_method` is always run."""
        pass
