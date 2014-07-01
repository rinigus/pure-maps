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

"""Narration of routing maneuvers."""

import poor

__all__ = ("Narrative",)


class Maneuver:

    """A routing maneuver."""

    def __init__(self, x, y):
        """Initialize a :class:`Maneuver` instance."""
        self.narrative = ""
        self.node = 0
        self.x = x
        self.y = y


class Narrative:

    """Narration of routing maneuvers."""

    def __init__(self):
        """Initialize a :class:`Narrative` instance."""
        self.dist = []
        self.maneuver = []
        self.x = []
        self.y = []

    def get_closest_node(self, x, y):
        """Return index of the route node closest to coordinates."""
        min_index = 0
        min_sq_dist = 360**2
        for i in range(len(self.x)):
            # This should be faster than haversine
            # and probably close enough.
            dist = (x - self.x[i])**2 + (y - self.y[i])**2
            if dist < min_sq_dist:
                min_index = i
                min_sq_dist = dist
        return min_index

    def get_display(self, x, y, speed):
        """Return a dictionary of maneuver details to display."""
        # Calculate advance in kilometers when to show narrative
        # of a particular maneuver based on speed and time.
        advance = speed * 3/60
        node = self.get_closest_node(x, y)
        dist = self.dist[node]
        if node == len(self.dist) - 1:
            # Use exact straight-line value at the very end.
            dist = poor.util.calculate_distance(
                x, y, self.x[node], self.y[node])
        dist_label = poor.util.format_distance(dist, 2, "km")
        if (self.maneuver[node] is not None and
            dist - self.dist[self.maneuver[node].node] < advance):
            maneuver = self.maneuvers[node]
            man_dist = dist - self.dist[self.maneuver[node].node]
            if node == maneuver.node:
                # Use exact straight-line value at the very end.
                man_dist = poor.util.calculate_distance(
                    x, y, maneuver.x, maneuver.y)
            man_dist_label = poor.util.format_distance(man_dist, 2, "km")
            narrative = maneuver.narrative
        else:
            man_dist = None
            man_dist_label = None
            narrative = None
        return dict(dist=dist,
                    dist_label=dist_label,
                    man_dist=man_dist,
                    man_dist_label=man_dist_label,
                    narrative=narrative)

    def set_maneuvers(self, x, y, narrative):
        """Set maneuver points and corresponding narrative."""
        for i in reversed(range(len(x))):
            maneuver = Maneuver(x[i], y[i])
            maneuver.node = self.get_closest_node(x[i], y[i])
            maneuver.narrative = narrative
            self.maneuver[maneuver.node] = maneuver
            # Assign maneuver to all preceding nodes as well.
            for j in reversed(range(maneuver.node)):
                self.maneuver[j] = maneuver

    def set_route(self, x, y):
        """Set route from coordinates."""
        self.x = x
        self.y = y
        self.dist = [0] * len(x)
        self.maneuver = [None] * len(x)
        for i in reversed(range(len(x)-1)):
            dist = poor.util.calculate_distance(x[i], y[i], x[i+1], y[i+1])
            self.dist[i] = self.dist[i+1] + dist
