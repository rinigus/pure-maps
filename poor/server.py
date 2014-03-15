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

"""A HTTP server that always returns 204 no content."""

import http.server

__all__ = ("NullHandler",)


class NullHandler(http.server.BaseHTTPRequestHandler):

    """A HTTP server that always returns 204 no content."""

    def do_GET(self):
        """Return HTTP GET response."""
        self.send_response(204)
        self.end_headers()

    def log_message(self, format, *args):
        """Don't print log messages."""
        pass
