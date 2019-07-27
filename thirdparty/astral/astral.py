# -*- coding: utf-8 -*-

# Copyright 2009-2019, Simon Kennedy, sffjunkie+code@gmail.com

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""Calculations for the position of the sun and moon.

This is a simplified version of :mod:`astral` module that is
sufficient for Pure Maps. Below is the original documentation. Please
note that large fraction of the original functionality is removed.

The :mod:`astral` module provides the means to calculate dawn, sunrise,
solar noon, sunset, dusk and rahukaalam times, plus solar azimuth and
elevation, for specific locations or at a specific latitude/longitude. It can
also calculate the moon phase for a specific date.

The module provides 2 main classes :class:`Astral` and :class:`Location`.

:class:`Astral`
    Has 2 main responsibilities

    * Calculates the events in the UTC timezone.
    * Provides access to location data

:class:`Location`
    Holds information about a location and provides functions to calculate
    the event times for the location in the correct time zone.

For example ::

    >>> from astral import *
    >>> a = Astral()
    >>> location = a['London']
    >>> print('Information for %s' % location.name)
    Information for London
    >>> timezone = location.timezone
    >>> print('Timezone: %s' % timezone)
    Timezone: Europe/London
    >>> print('Latitude: %.02f; Longitude: %.02f' % (location.latitude,
    ... location.longitude))
    Latitude: 51.60; Longitude: 0.05
    >>> from datetime import date
    >>> d = date(2009,4,22)
    >>> sun = location.sun(local=True, date=d)
    >>> print('Dawn:    %s' % str(sun['dawn']))
    Dawn:    2009-04-22 05:12:56+01:00

The module currently provides 2 methods of obtaining location information;
:class:`AstralGeocoder` (the default, which uses information from within the
module) and :class:`GoogleGeocoder` (which obtains information from Google's
Map Service.)

To use the :class:`GoogleGeocoder` pass the class as the `geocoder` parameter
to :meth:`Astral.__init__` or by setting the `geocoder` property to an
instance of :class:`GoogleGeocoder`::

    >>> from astral import GoogleGeocoder
    >>> a = Astral(GoogleGeocoder)

or ::

    >>> from astral import GoogleGeocoder
    >>> a = Astral()
    >>> a.geocoder = GoogleGeocoder()

"""

import datetime
from time import time
from math import cos, sin, tan, acos, asin, atan2, floor, ceil
from math import radians, degrees, pow, sqrt
from numbers import Number

ustr = str

__all__ = ["Astral", "Location", "AstralGeocoder", "GoogleGeocoder", "AstralError"]

__version__ = "1.10.1"
__author__ = "Simon Kennedy <sffjunkie+code@gmail.com>"

SUN_RISING = 1
SUN_SETTING = -1

class AstralError(Exception):
    """Astral base exception class"""


def excel_datediff(start_date, end_date):
    """Return the same number of days between 2 dates as Excel does"""
    return end_date.toordinal() - start_date.toordinal() + 2


class Astral(object):
    def __init__(self):
        """Initialise the geocoder and set the default depression.

        Any keyword arguments are passed to the geocoder."""

        self._depression = 6  # Set default depression in degrees

    def sunrise_utc(self, date, latitude, longitude, observer_elevation=0):
        """Calculate sunrise time in the UTC timezone.

        :param date:       Date to calculate for.
        :type date:        :class:`datetime.date`
        :param latitude:   Latitude - Northern latitudes should be positive
        :type latitude:    float
        :param longitude:  Longitude - Eastern longitudes should be positive
        :type longitude:   float
        :param observer_elevation:  Elevation in metres to calculate sunrise for
        :type observer_elevation:   int

        :return: The UTC date and time at which sunrise occurs.
        :rtype: :class:`~datetime.datetime`
        """

        try:
            return self._calc_time(90 + 0.833, SUN_RISING, date, latitude, longitude, observer_elevation)
        except ValueError as exc:
            if exc.args[0] == "math domain error":
                raise AstralError(
                    ("Sun never reaches the horizon on this day, " "at this location.")
                )
            else:
                raise

    def sunset_utc(self, date, latitude, longitude, observer_elevation=0):
        """Calculate sunset time in the UTC timezone.

        :param date:       Date to calculate for.
        :type date:        :class:`datetime.date`
        :param latitude:   Latitude - Northern latitudes should be positive
        :type latitude:    float
        :param longitude:  Longitude - Eastern longitudes should be positive
        :type longitude:   float
        :param observer_elevation:  Elevation in metres to calculate sunset for
        :type observer_elevation:   int

        :return: The UTC date and time at which sunset occurs.
        :rtype: :class:`~datetime.datetime`
        """

        try:
            return self._calc_time(90 + 0.833, SUN_SETTING, date, latitude, longitude, observer_elevation)
        except ValueError as exc:
            if exc.args[0] == "math domain error":
                raise AstralError(
                    ("Sun never reaches the horizon on this day, " "at this location.")
                )
            else:
                raise

    def solar_elevation(self, dateandtime, latitude, longitude):
        """Calculate the elevation angle of the sun.

        :param dateandtime: The date and time for which to calculate
                            the angle.
        :type dateandtime:  :class:`~datetime.datetime`
        :param latitude:   Latitude - Northern latitudes should be positive
        :type latitude:    float
        :param longitude:  Longitude - Eastern longitudes should be positive
        :type longitude:   float

        :return: The elevation angle in degrees above the horizon.
        :rtype: float

        If `dateandtime` is a naive Python datetime then it is assumed to be
        in the UTC timezone.
        """

        if latitude > 89.8:
            latitude = 89.8

        if latitude < -89.8:
            latitude = -89.8

        if dateandtime.tzinfo is None:
            zone = 0
            utc_datetime = dateandtime
        else:
            raise RuntimeError("don't call with tzinfo, just provide UTC time")
            # zone = -dateandtime.utcoffset().total_seconds() / 3600.0
            # utc_datetime = dateandtime.astimezone(pytz.utc)

        timenow = (
            utc_datetime.hour
            + (utc_datetime.minute / 60.0)
            + (utc_datetime.second / 3600)
        )

        JD = self._julianday(dateandtime)
        t = self._jday_to_jcentury(JD + timenow / 24.0)
        theta = self._sun_declination(t)
        eqtime = self._eq_of_time(t)
        solarDec = theta  # in degrees

        solarTimeFix = eqtime - (4.0 * -longitude) + (60 * zone)
        trueSolarTime = (
            dateandtime.hour * 60.0
            + dateandtime.minute
            + dateandtime.second / 60.0
            + solarTimeFix
        )
        #    in minutes

        while trueSolarTime > 1440:
            trueSolarTime = trueSolarTime - 1440

        hourangle = trueSolarTime / 4.0 - 180.0
        # Thanks to Louis Schwarzmayr for the next line:
        if hourangle < -180:
            hourangle = hourangle + 360.0

        harad = radians(hourangle)

        csz = sin(radians(latitude)) * sin(radians(solarDec)) + cos(
            radians(latitude)
        ) * cos(radians(solarDec)) * cos(harad)

        if csz > 1.0:
            csz = 1.0
        elif csz < -1.0:
            csz = -1.0

        zenith = degrees(acos(csz))

        azDenom = cos(radians(latitude)) * sin(radians(zenith))

        if abs(azDenom) > 0.001:
            azRad = (
                (sin(radians(latitude)) * cos(radians(zenith))) - sin(radians(solarDec))
            ) / azDenom

            if abs(azRad) > 1.0:
                if azRad < 0:
                    azRad = -1.0
                else:
                    azRad = 1.0

            azimuth = 180.0 - degrees(acos(azRad))

            if hourangle > 0.0:
                azimuth = -azimuth
        else:
            if latitude > 0.0:
                azimuth = 180.0
            else:
                azimuth = 0.0

        if azimuth < 0.0:
            azimuth = azimuth + 360.0

        exoatmElevation = 90.0 - zenith

        if exoatmElevation > 85.0:
            refractionCorrection = 0.0
        else:
            te = tan(radians(exoatmElevation))
            if exoatmElevation > 5.0:
                refractionCorrection = (
                    58.1 / te
                    - 0.07 / (te * te * te)
                    + 0.000086 / (te * te * te * te * te)
                )
            elif exoatmElevation > -0.575:
                step1 = -12.79 + exoatmElevation * 0.711
                step2 = 103.4 + exoatmElevation * (step1)
                step3 = -518.2 + exoatmElevation * (step2)
                refractionCorrection = 1735.0 + exoatmElevation * (step3)
            else:
                refractionCorrection = -20.774 / te

            refractionCorrection = refractionCorrection / 3600.0

        solarzen = zenith - refractionCorrection

        solarelevation = 90.0 - solarzen

        return solarelevation

    def _proper_angle(self, value):
        if value > 0.0:
            value /= 360.0
            return (value - floor(value)) * 360.0
        else:
            tmp = ceil(abs(value / 360.0))
            return value + tmp * 360.0

    def _julianday(self, utcdatetime, timezone=None):
        if isinstance(utcdatetime, datetime.datetime):
            end_date = utcdatetime.date()
            hour = utcdatetime.hour
            minute = utcdatetime.minute
            second = utcdatetime.second
        else:
            end_date = utcdatetime
            hour = 0
            minute = 0
            second = 0

        if timezone:
            if isinstance(timezone, int):
                hour_offset = timezone
            else:
                offset = timezone.localize(utcdatetime).utcoffset()
                hour_offset = offset.total_seconds() / 3600.0
        else:
            hour_offset = 0

        start_date = datetime.date(1900, 1, 1)
        time_fraction = (hour * 3600.0 + minute * 60.0 + second) / (24.0 * 3600.0)
        date_diff = excel_datediff(start_date, end_date)
        jd = date_diff + 2415018.5 + time_fraction - (hour_offset / 24)

        return jd

    def _jday_to_jcentury(self, julianday):
        return (julianday - 2451545.0) / 36525.0

    def _jcentury_to_jday(self, juliancentury):
        return (juliancentury * 36525.0) + 2451545.0

    def _geom_mean_long_sun(self, juliancentury):
        l0 = 280.46646 + juliancentury * (36000.76983 + 0.0003032 * juliancentury)
        return l0 % 360.0

    def _geom_mean_anomaly_sun(self, juliancentury):
        return 357.52911 + juliancentury * (35999.05029 - 0.0001537 * juliancentury)

    def _eccentrilocation_earth_orbit(self, juliancentury):
        return 0.016708634 - juliancentury * (
            0.000042037 + 0.0000001267 * juliancentury
        )

    def _sun_eq_of_center(self, juliancentury):
        m = self._geom_mean_anomaly_sun(juliancentury)

        mrad = radians(m)
        sinm = sin(mrad)
        sin2m = sin(mrad + mrad)
        sin3m = sin(mrad + mrad + mrad)

        c = (
            sinm * (1.914602 - juliancentury * (0.004817 + 0.000014 * juliancentury))
            + sin2m * (0.019993 - 0.000101 * juliancentury)
            + sin3m * 0.000289
        )

        return c

    def _sun_true_long(self, juliancentury):
        l0 = self._geom_mean_long_sun(juliancentury)
        c = self._sun_eq_of_center(juliancentury)

        return l0 + c

    def _sun_true_anomoly(self, juliancentury):
        m = self._geom_mean_anomaly_sun(juliancentury)
        c = self._sun_eq_of_center(juliancentury)

        return m + c

    def _sun_rad_vector(self, juliancentury):
        v = self._sun_true_anomoly(juliancentury)
        e = self._eccentrilocation_earth_orbit(juliancentury)

        return (1.000001018 * (1 - e * e)) / (1 + e * cos(radians(v)))

    def _sun_apparent_long(self, juliancentury):
        true_long = self._sun_true_long(juliancentury)

        omega = 125.04 - 1934.136 * juliancentury
        return true_long - 0.00569 - 0.00478 * sin(radians(omega))

    def _mean_obliquity_of_ecliptic(self, juliancentury):
        seconds = 21.448 - juliancentury * (
            46.815 + juliancentury * (0.00059 - juliancentury * (0.001813))
        )
        return 23.0 + (26.0 + (seconds / 60.0)) / 60.0

    def _obliquity_correction(self, juliancentury):
        e0 = self._mean_obliquity_of_ecliptic(juliancentury)

        omega = 125.04 - 1934.136 * juliancentury
        return e0 + 0.00256 * cos(radians(omega))

    def _sun_rt_ascension(self, juliancentury):
        oc = self._obliquity_correction(juliancentury)
        al = self._sun_apparent_long(juliancentury)

        tananum = cos(radians(oc)) * sin(radians(al))
        tanadenom = cos(radians(al))

        return degrees(atan2(tananum, tanadenom))

    def _sun_declination(self, juliancentury):
        e = self._obliquity_correction(juliancentury)
        lambd = self._sun_apparent_long(juliancentury)

        sint = sin(radians(e)) * sin(radians(lambd))
        return degrees(asin(sint))

    def _var_y(self, juliancentury):
        epsilon = self._obliquity_correction(juliancentury)
        y = tan(radians(epsilon) / 2.0)
        return y * y

    def _eq_of_time(self, juliancentury):
        l0 = self._geom_mean_long_sun(juliancentury)
        e = self._eccentrilocation_earth_orbit(juliancentury)
        m = self._geom_mean_anomaly_sun(juliancentury)

        y = self._var_y(juliancentury)

        sin2l0 = sin(2.0 * radians(l0))
        sinm = sin(radians(m))
        cos2l0 = cos(2.0 * radians(l0))
        sin4l0 = sin(4.0 * radians(l0))
        sin2m = sin(2.0 * radians(m))

        Etime = (
            y * sin2l0
            - 2.0 * e * sinm
            + 4.0 * e * y * sinm * cos2l0
            - 0.5 * y * y * sin4l0
            - 1.25 * e * e * sin2m
        )

        return degrees(Etime) * 4.0

    def _hour_angle(self, latitude, declination, depression):
        latitude_rad = radians(latitude)
        declination_rad = radians(declination)
        depression_rad = radians(depression)

        n = cos(depression_rad)
        d = cos(latitude_rad) * cos(declination_rad)
        t = tan(latitude_rad) * tan(declination_rad)
        h = (n / d) - t

        HA = acos(h)
        return HA

    def _calc_time(self, depression, direction, date, latitude, longitude, observer_elevation=0):
        if not isinstance(latitude, Number) or not isinstance(longitude, Number):
            raise TypeError("Latitude and longitude must be a numbers")

        julianday = self._julianday(date)

        if latitude > 89.8:
            latitude = 89.8

        if latitude < -89.8:
            latitude = -89.8

        if observer_elevation > 0:
            adjustment = self._depression_adjustment(observer_elevation)
        else:
            adjustment = 0

        t = self._jday_to_jcentury(julianday)
        eqtime = self._eq_of_time(t)
        solarDec = self._sun_declination(t)

        hourangle = self._hour_angle(latitude, solarDec, depression + adjustment)
        if direction == SUN_SETTING:
            hourangle = -hourangle

        delta = -longitude - degrees(hourangle)
        timeDiff = 4.0 * delta
        timeUTC = 720.0 + timeDiff - eqtime

        timeUTC = timeUTC / 60.0
        hour = int(timeUTC)
        minute = int((timeUTC - hour) * 60)
        second = int((((timeUTC - hour) * 60) - minute) * 60)

        if second > 59:
            second -= 60
            minute += 1
        elif second < 0:
            second += 60
            minute -= 1

        if minute > 59:
            minute -= 60
            hour += 1
        elif minute < 0:
            minute += 60
            hour -= 1

        if hour > 23:
            hour -= 24
            date += datetime.timedelta(days=1)
        elif hour < 0:
            hour += 24
            date -= datetime.timedelta(days=1)

        dt = datetime.datetime(date.year, date.month, date.day, hour, minute, second)
        #dt = pytz.UTC.localize(dt)  # pylint: disable=E1120

        return dt

    # def _moon_phase_asfloat(self, date):
    #     jd = self._julianday(date)
    #     DT = pow((jd - 2382148), 2) / (41048480 * 86400)
    #     T = (jd + DT - 2451545.0) / 36525
    #     T2 = pow(T, 2)
    #     T3 = pow(T, 3)
    #     D = 297.85 + (445267.1115 * T) - (0.0016300 * T2) + (T3 / 545868)
    #     D = radians(self._proper_angle(D))
    #     M = 357.53 + (35999.0503 * T)
    #     M = radians(self._proper_angle(M))
    #     M1 = 134.96 + (477198.8676 * T) + (0.0089970 * T2) + (T3 / 69699)
    #     M1 = radians(self._proper_angle(M1))
    #     elong = degrees(D) + 6.29 * sin(M1)
    #     elong -= 2.10 * sin(M)
    #     elong += 1.27 * sin(2 * D - M1)
    #     elong += 0.66 * sin(2 * D)
    #     elong = self._proper_angle(elong)
    #     elong = round(elong)
    #     moon = ((elong + 6.43) / 360) * 28
    #     return moon

    def _depression_adjustment(self, elevation):
        """Calculate the extra degrees of depression due to the increase in elevation.

        :param elevation: Elevation above the earth in metres
        :type  elevation: float
        """

        if elevation <= 0:
            return 0

        r = 6356900 # radius of the earth
        a1 = r
        h1 = r + elevation
        theta1 = acos(a1 / h1)

        a2 = r * sin(theta1)
        b2 = r - (r * cos(theta1))
        h2 = sqrt(pow(a2, 2) + pow(b2, 2))
        alpha = acos(a2 / h2)

        return degrees(alpha)


# if __name__ == "__main__":
#     import argparse

#     options = argparse.ArgumentParser()
#     options.add_argument("-n", "--name", dest="name", help="Location name (free-form text)")
#     options.add_argument("--lat", dest="latitude", type=float, help="Location latitude (float)")
#     options.add_argument("--lng", dest="longitude", type=float, help="Location longitude (float)")
#     options.add_argument("-d", "--date", dest="date", help="Date to compute times for (yyyy-mm-dd)")
#     options.add_argument("-t", "--tzname", help="Timezone name")
#     args = options.parse_args()

#     loc = Location((args.name, None, args.latitude, args.longitude, args.tzname, 0))

#     kwargs = {}
#     if args.date is not None:
#         try:
#             kwargs["date"] = datetime.datetime.strptime(args.date, "%Y-%m-%d").date()
#         except:  # noqa: E0722
#             kwargs["date"] = datetime.date.today()

#     if args.tzname is None:
#         kwargs["local"] = False

#     sun = loc.sun(**kwargs)

#     sun_as_str = {}
#     for key, value in sun.items():
#         sun_as_str[key] = sun[key].strftime("%Y-%m-%dT%H:%M:%S")

#     print(json.dumps(sun_as_str))
