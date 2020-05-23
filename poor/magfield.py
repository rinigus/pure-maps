# -*- coding: utf-8 -*-

# Copyright (C) 2020 Rinigus
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

"""Calculates magnetic declination."""

from datetime import datetime, timedelta
from poor.geomag import WorldMagneticModel

__all__ = ("MagField")


class MagField:

    """Magnetic field calculations"""

    def __init__(self):
        self.wmm = WorldMagneticModel()
        self.clat, self.clon = None, None
        self.cdeclination = None
        self.ctime = datetime.utcnow()

    def declination(self, latitude, longitude, observer_elevation=0):
        now = datetime.utcnow()

        # check if we have data in cache
        if self.cdeclination is not None and \
           self.ctime > now and \
           abs(self.clat - latitude) < 0.1 and \
           abs(self.clon - longitude) < 0.1:
            return self.cdeclination

        # new calculation
        self.clat, self.clon = latitude, longitude
        self.cdeclination = self.wmm.calc_mag_field(latitude, longitude).declination
        self.ctime = now + timedelta(hours=24)

        print('Calculated magnetic declination', self.cdeclination)
        return self.cdeclination
