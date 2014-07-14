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

import bisect
import poor

__all__ = ("Narrative",)


class Maneuver:

    """A routing maneuver."""

    def __init__(self, **kwargs):
        """Initialize a :class:`Maneuver` instance."""
        self.icon = "alert"
        self.narrative = ""
        self.node = None
        self.x = None
        self.y = None
        for name in set(kwargs) & set(dir(self)):
            setattr(self, name, kwargs[name])


class Narrative:

    """Narration of routing maneuvers."""

    def __init__(self):
        """Initialize a :class:`Narrative` instance."""
        self.dist = []
        self.maneuver = []
        self.mode = "car"
        self.time = []
        self.x = []
        self.y = []

    def _get_closest_maneuver_node(self, x, y, node):
        """Return index of the maneuver node closest to coordinates."""
        # Only consider the immediate preceding and following
        # maneuver nodes from the given closest route node.
        nodes = sorted(set(x.node for x in self.maneuver if x))
        a = bisect.bisect_left(nodes, node)
        b = bisect.bisect_right(nodes, node)
        nodes = nodes[max(0, a-1):min(len(nodes), b+1)]
        min_index = 0
        min_sq_dist = 360**2
        for i in nodes:
            # This should be faster than haversine
            # and probably close enough.
            dist = (x - self.x[i])**2 + (y - self.y[i])**2
            if dist < min_sq_dist:
                min_index = i
                min_sq_dist = dist
        return min_index

    def _get_closest_node(self, x, y):
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

    def _get_distance_from_route(self, x, y, node):
        """Return distance in kilometers from the route polyline."""
        return min(self._get_distances_from_route(x, y, node))

    def _get_distances_from_route(self, x, y, node):
        """Return distances in kilometers from route segments."""
        if len(self.x) == 1:
            return poor.util.calculate_distance(
                x, y, self.x[node], self.y[node])
        dist = []
        if node > 0:
            x1, x2 = self.x[node-1:node+1]
            y1, y2 = self.y[node-1:node+1]
            dist.append(poor.util.calculate_segment_distance(
                x, y, x1, y1, x2, y2))
        if node < len(self.x) - 1:
            x1, x2 = self.x[node:node+2]
            y1, y2 = self.y[node:node+2]
            dist.append(poor.util.calculate_segment_distance(
                x, y, x1, y1, x2, y2))
        return dist

    def get_display(self, x, y):
        """Return a dictionary of status details to display."""
        if not self.ready: return None
        if self.mode == "transit":
            return self._get_display_transit(x, y)
        node = self._get_closest_node(x, y)
        seg_dists = self._get_distances_from_route(x, y, node)
        seg_dist = min(seg_dists)
        dest_dist, dest_time = self._get_display_destination(
            x, y, node, seg_dist)
        dest_dist = poor.util.format_distance(dest_dist, 2)
        dest_time = poor.util.format_time(dest_time)
        man = self._get_display_maneuver(x, y, node, seg_dists)
        man_dist, man_time, icon, narrative = man
        if man_time > 120:
            # Only show narrative near maneuver point.
            icon = narrative = None
        man_dist = poor.util.format_distance(man_dist, 2)
        man_time = poor.util.format_time(man_time)
        if seg_dist > 0.2:
            # Don't show the narrative or details calculated
            # from nodes along the route if far off route.
            dest_time = man_time = icon = narrative = None
        return dict(dest_dist=dest_dist,
                    dest_time=dest_time,
                    man_dist=man_dist,
                    man_time=man_time,
                    icon=icon,
                    narrative=narrative)

    def _get_display_destination(self, x, y, node, seg_dist):
        """Return destination details to display."""
        dest_dist = seg_dist + self.dist[node]
        dest_time = self.time[node]
        if node == len(self.x) - 1 or dest_dist < 0.2:
            # Use exact straight-line value at the very end.
            dest_dist = poor.util.calculate_distance(
                x, y, self.maneuver[node].x, self.maneuver[node].y)
        return dest_dist, dest_time

    def _get_display_maneuver(self, x, y, node, seg_dists):
        """Return maneuver details to display."""
        # For car, show narrative of the next maneuver point following the
        # closest route segment, but avoid considering the maneuver point
        # passed too soon in case the positioning jumps around a bit.
        if len(seg_dists) == 2:
            # If the segment following the closest node is closer than the one
            # preceding, use the maneuver data of the next node.
            s1, s2 = seg_dists
            if s2 < s1/2 and s1 > 0.01:
                node = node + 1
        seg_dist = min(seg_dists)
        maneuver = self.maneuver[node]
        man_dist = seg_dist + self.dist[node] - self.dist[maneuver.node]
        man_time = self.time[node] - self.time[maneuver.node]
        if node == maneuver.node or man_dist < 0.2:
            # Use exact straight-line value at the very end.
            man_dist = poor.util.calculate_distance(
                x, y, maneuver.x, maneuver.y)
        return man_dist, man_time, maneuver.icon, maneuver.narrative

    def _get_display_transit(self, x, y):
        """Return a dictionary of status details to display."""
        # For transit, show narrative of the closest node, since transit
        # maneuver points are not always points, but often stations or
        # platforms that cover a large area.
        node = self._get_closest_node(x, y)
        seg_dist = self._get_distance_from_route(x, y, node)
        dest_dist, dest_time = self._get_display_destination(
            x, y, node, seg_dist)
        dest_dist = poor.util.format_distance(dest_dist, 2)
        dest_time = poor.util.format_time(dest_time)
        mnode = self._get_closest_maneuver_node(x, y, node)
        if mnode > node + 1:
            # If the maneuver point is far and still ahead, we can calculate
            # distances and times from along the route, just as for cars.
            man_dist = seg_dist + self.dist[node] - self.dist[mnode]
            man_time = self.time[node] - self.time[mnode]
        else:
            # If the maneuver point is the very next one,
            # or already passed, use straight-line distance.
            man_dist = poor.util.calculate_distance(
                x, y, self.maneuver[mnode].x, self.maneuver[mnode].y)
            man_time = 0
        if node > mnode and man_dist > 0.5:
            # If closest maneuver point surely passed,
            # show narrative of the next maneuver.
            icon = self.maneuver[node].icon
            narrative = self.maneuver[node].narrative
        else:
            # If near a maneuver point,
            # show the corresponding narrative.
            icon = self.maneuver[mnode].icon
            narrative = self.maneuver[mnode].narrative
        man_dist = poor.util.format_distance(man_dist, 2)
        man_time = poor.util.format_time(man_time)
        return dict(dest_dist=dest_dist,
                    dest_time=dest_time,
                    man_dist=man_dist,
                    man_time=man_time,
                    icon=icon,
                    narrative=narrative)

    @property
    def ready(self):
        """Return ``True`` if narrative is in steady state and ready for use."""
        return (self.x and
                len(self.x) ==
                len(self.y) ==
                len(self.dist) ==
                len(self.time) ==
                len(self.maneuver))

    def set_maneuvers(self, maneuvers):
        """
        Set maneuver points and corresponding narrative.

        Keys "x", "y" and "duration" are required for each item in `maneuvers`
        and keys "icon", "narrative" and "passive" are optional. Duration
        refers to the leg following the maneuver, other data is associated with
        the maneuver point itself.
        """
        prev_maneuver = None
        for i in reversed(range(len(maneuvers))):
            if "passive" in maneuvers[i]:
                if maneuvers[i]["passive"]: continue
            maneuver = Maneuver(**maneuvers[i])
            maneuver.node = self._get_closest_node(maneuver.x, maneuver.y);
            self.maneuver[maneuver.node] = maneuver
            # Assign maneuver to preceding nodes as well.
            for j in reversed(range(maneuver.node)):
                self.maneuver[j] = maneuver
            # Calculate time remaining to destination for each node
            # based on durations of individual legs following given maneuvers.
            if prev_maneuver is not None:
                dist = self.dist[maneuver.node] - self.dist[prev_maneuver.node]
                speed = dist / max(1, maneuvers[i]["duration"]) # km/s
                for j in reversed(range(maneuver.node, prev_maneuver.node)):
                    dist = self.dist[j] - self.dist[j+1]
                    self.time[j] = self.time[j+1] + dist/speed
            prev_maneuver = maneuver

    def set_mode(self, mode):
        """
        Set transport mode for route.

        `mode` should be "car" or "transit". This affects how maneuver
        notifications are handled. Currently only transit (public
        transportation) is handled differently and thus walking, bicycle, etc.
        can all be marked as "car".
        """
        self.mode = mode

    def set_route(self, x, y):
        """Set route from coordinates."""
        self.x = x
        self.y = y
        self.dist = [0] * len(x)
        self.time = [0] * len(x)
        self.maneuver = [None] * len(x)
        for i in list(reversed(range(len(x)-1))):
            dist = poor.util.calculate_distance(x[i], y[i], x[i+1], y[i+1])
            if dist < 0.001:
                # Consecutive duplicate points will cause problems for
                # calculations that determine when to show narrative related
                # to a maneuver point. We need to drop these.
                self.x.pop(i)
                self.y.pop(i)
                self.dist.pop(i)
                self.time.pop(i)
                self.maneuver.pop(i)
                continue
            self.dist[i] = self.dist[i+1] + dist
            # Calculate remaining time using 120 km/h, which will maximize
            # the advance at which maneuver notifications are shown.
            # See 'set_maneuvers' for the actual leg-specific times
            # that should in most cases overwrite these.
            self.time[i] = self.time[i+1] + (dist/120)*3600

    def unset(self):
        """Unset route and maneuvers."""
        self.dist = []
        self.maneuver = []
        self.mode = "car"
        self.time = []
        self.x = []
        self.y = []
