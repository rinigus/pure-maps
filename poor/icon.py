# -*- coding: utf-8 -*-

# Copyright (C) 2018 Rinigus
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

"""Icon finder"""

import glob
import os

__all__ = ("IconFinder",)

class IconFinder:

    """Finding icons in accordance with the FreeDesktop specifications"""

    def __init__(self):
        """Initialize a :class:`IconFinder` instance."""
        self.themes = set()
        xdg = os.getenv("XDG_DATA_DIRS")
        if xdg is not None:
            for b in os.path.expanduser(xdg).split(":"):
                d = os.path.join(b, "icons")
                if os.path.exists(d):
                    for t in glob.glob(d + "/*"):
                        self.themes.add(os.path.basename(t))
        self.themes = list(self.themes)
        self.themes.sort()
        self.set_theme()

    def set_theme(self, theme="Adwaita"):
        """Set current icon theme"""
        self.theme = theme

    def get_icon(self, icon):
        """Return icon filename"""
        from xdg.IconTheme import getIconPath
        return getIconPath(icon, theme=self.theme, extensions=["svg"])
