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

"""
Polyline simplification using Douglas-Peucker and radial distance.

http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm
"""

# Adapted from Vladimir Agafonkin's simplify.js.
# Copyright (C) 2012 Vladimir Agafonkin, BSD-licensed.
# http://mourner.github.io/simplify-js

import collections


def get_sq_dist(x1, y1, x2, y2):
    """Return square distance between points 1 and 2."""
    return (x2 - x1)**2 + (y2 - y1)**2

def get_sq_seg_dist(x, y, x1, y1, x2, y2):
    """Return square distance from point to segment."""
    px = x1
    py = y1
    dx = x2 - px
    dy = y2 - py
    if dx != 0 or dy != 0:
        t = ((x - px)*dx + (y - py)*dy) / (dx**2 + dy**2)
        if t > 1:
            px = x2
            py = y2
        elif t > 0:
            px += dx * t
            py += dy * t
    dx = x - px
    dy = y - py
    return dx**2 + dy**2

def simplify(x, y, tol=None, hq=False, max_length=None, nmax=None):
    """Simplify polyline using Douglas-Peucker and radial distance."""
    xin = x
    yin = y
    if len(x) < 2:
        return x, y
    if tol is not None:
        if not hq:
            x, y = simplify_radial_dist(x, y, tol)
        x, y = simplify_douglas_peucker(x, y, tol)
    if max_length is not None:
        max_length2 = max_length**2
        i = 1
        while i < len(x):
            dist = get_sq_dist(x[i], y[i], x[i-1], y[i-1])
            if dist > max_length2:
                x.insert(i, (x[i-1] + x[i])/2)
                y.insert(i, (y[i-1] + y[i])/2)
            else:
                i += 1
    if tol is not None and nmax is not None and len(x) > nmax:
        return simplify(xin, yin, tol*2, hq, max_length, nmax)
    return x, y

def simplify_douglas_peucker(x, y, tol):
    """Simplify polyline using Douglas-Peucker."""
    keep = [False] * len(x)
    stack = collections.deque((0, len(x)-1))
    tol2 = tol**2
    while stack:
        z = stack.pop()
        a = stack.pop()
        keep[a] = keep[z] = True
        max_i = None
        max_dist = -1
        for i in range(a+1, z):
            dist = get_sq_seg_dist(x[i], y[i], x[a], y[a], x[z], y[z])
            if dist > max_dist:
                max_i = i
                max_dist = dist
        if max_dist > tol2:
            stack.extend((a, max_i, max_i, z))
    xout = [x[i] for i in range(len(x)) if keep[i]]
    yout = [y[i] for i in range(len(y)) if keep[i]]
    return xout, yout

def simplify_qml(x, y, tol=None, hq=False, max_length=None, nmax=None):
    """Simplify polyline using Douglas-Peucker and radial distance."""
    # Return a dictionary, since PyOtherSide handles that better.
    x, y = simplify(x, y, tol, hq, max_length, nmax)
    return dict(x=x, y=y)

def simplify_radial_dist(x, y, tol):
    """Simplify polyline using radial distance."""
    prev = 0
    xout = [x[0]]
    yout = [y[0]]
    tol2 = tol**2
    for i in range(1, len(x)-1):
        if get_sq_dist(x[i], y[i], x[prev], y[prev]) > tol2:
            xout.append(x[i])
            yout.append(y[i])
            prev = i
    xout.append(x[len(x)-1])
    yout.append(y[len(y)-1])
    return xout, yout
