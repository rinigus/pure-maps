# -*- coding: utf-8 -*-

# Copyright (C) 2019 Rinigus, 2019 Purism SPC
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

"""Sunrise and sunset calculations."""

from datetime import datetime, timedelta
from poor.astral.astral import Astral, AstralError

__all__ = ("Sun")


class Sun:

    """Sunrise and sunset calculations."""

    def __init__(self):
        """Initialize a :class:`Sun` instance."""
        self.astral = Astral()
        self.clat, self.clon = None, None
        self.clight = None
        self.ctime = datetime.utcnow()

    def day(self, latitude, longitude, observer_elevation=0):
        now = datetime.utcnow()

        # check if we have data in cache
        if self.clight is not None and \
           self.ctime > now and \
           abs(self.clat - latitude) < 0.25 and \
           abs(self.clon - longitude) < 0.25:
            return self.clight

        # new calculation
        light = None
        valid = None
        try:
            srise = self.astral.sunrise_utc(now, latitude, longitude, observer_elevation)
            sset = self.astral.sunset_utc(now, latitude, longitude, observer_elevation)
            rref, sref = now, now
            counter = 0
            while counter < 3 and (srise < now and sset < now) or (srise > now and sset > now):
                get_rise, get_set = None, None
                if srise < now and sset < now:
                    if srise < sset: get_rise = 1
                    else: get_set = 1
                if srise > now and sset > now:
                    if srise > sset: get_rise = -1
                    else: get_set = -1
                # print("Adjust:", srise, now, sset, get_rise, get_set)
                if get_rise is not None:
                    rref = rref + timedelta(days=get_rise)
                    srise = self.astral.sunrise_utc(rref, latitude, longitude, observer_elevation)
                if get_set is not None:
                    sref = sref + timedelta(days=get_set)
                    sset = self.astral.sunset_utc(sref, latitude, longitude, observer_elevation)
                counter += 1
            if counter >= 3:
                print("Please check the daylight algorithm. Coordinates:", latitude, longitude, " / time", now)
                print("Please file the bug at Pure Maps GitHub and send these data via private email")

            if srise < now and sset > now:
                light, valid = True, sset
            elif sset < now and srise > now:
                light, valid = False, srise
                
        except AstralError: 
            # print("Probably had issues with calculation of sunset/sunrise, using safer calculations")
            pass

        if light is None:
            print("Estimation of daylight using solar elevation")
            elevation = self.astral.solar_elevation(now, latitude, longitude)
            if (elevation < -0.833): # as used in astral
                light = False
            else:
                light = True
            valid = now + timedelta(hours=1)

        # print("It is a day:", light, " next check at:", valid)
        self.clat, self.clon = latitude, longitude
        self.clight = light
        self.ctime = valid
        return light
