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
import datetime
import poor
import statistics

from poor.i18n import __

__all__ = ("Narrative",)


class Maneuver:

    """A routing maneuver."""

    def __init__(self, **kwargs):
        """Initialize a :class:`Maneuver` instance."""
        self.duration = 0
        self.icon = "flag"
        self.length = 0
        self.narrative = ""
        self.node = None
        self.verbal_alert = ""
        self.verbal_post = ""
        self.verbal_pre = ""
        self.x = None
        self.y = None
        for name in set(kwargs) & set(dir(self)):
            setattr(self, name, kwargs[name])

    @property
    def speed(self):
        """Return speed of the leg following maneuver in m/s."""
        return self.length / max(1, self.duration)


class Verbal:

    """A verbal routing instruction."""

    def __init__(self, **kwargs):
        """Initialize a :class:`Verbal` instance."""
        self.dist = 0
        self.generated = False
        self.importance = 0
        self.passed = False
        self.speed = 1
        self.text = 0
        self.time = 0
        for name in set(kwargs) & set(dir(self)):
            setattr(self, name, kwargs[name])

    def __repr__(self):
        return ("{}(dist={:.0f}-{:.0f}, time={:.0f}-{:.0f}, text={})"
                .format(self.__class__.__name__,
                        self.dist,
                        self.dist - self.length,
                        self.time,
                        self.time - self.duration,
                        repr(self.text)))

    @property
    def duration(self):
        """Return duration in seconds of spoken text."""
        # Actual TTS speeds are maybe about 12-16 characters per second.
        # Use a slightly underestimated speed here to avoid overlaps.
        return len(self.text) / 10

    @property
    def length(self):
        """Return length in meters driven during text spoken."""
        return self.speed * self.duration


class Narrative:

    """Narration of routing maneuvers."""

    def __init__(self):
        """Initialize a :class:`Narrative` instance."""
        self.dist = []
        self._last_node = 0
        self.language = "en"
        self.maneuver = []
        self.mode = "car"
        self.time = []
        self.verbals = []
        self.voice_generator = poor.VoiceGenerator()
        self.x = []
        self.y = []

    def _calculate_direction_ahead(self, node):
        """Return direction of the segment from `node` ahead."""
        return poor.util.calculate_bearing(
            self.x[node], self.y[node], self.x[node+1], self.y[node+1])

    def _calculate_length_ahead(self, node):
        """Return length of the segment from `node` ahead."""
        return poor.util.calculate_distance(
            self.x[node], self.y[node], self.x[node+1], self.y[node+1])

    def _format_verbal_alert(self, text, dist_offset, time_offset, speed):
        """Return `text` formatted as a verbal alert."""
        dist_offset = max(dist_offset, time_offset * speed)
        distance = poor.util.round_distance(dist_offset, n=1)
        distance = poor.util.format_distance(distance, short=False)
        return (__("In {distance}, {direction}", self.language)
                .format(distance=distance, direction=text))

    def _get_closest_maneuver_node(self, x, y, node):
        """Return index of the maneuver node closest to coordinates."""
        if self.maneuver[node].node == node: return node
        # Only consider the immediate preceding and following
        # maneuver nodes from the given closest route node.
        nodes = sorted(set(x.node for x in self.maneuver if x))
        a = bisect.bisect_left(nodes, node)
        b = bisect.bisect_right(nodes, node)
        nodes = nodes[max(0, a-1):min(len(nodes), b+1)]
        return poor.util.find_closest(self.x, self.y, x, y, nodes)

    def _get_closest_node(self, x, y):
        """Return index of the route node closest to coordinates."""
        return poor.util.find_closest(self.x, self.y, x, y)

    def _get_closest_segment_node(self, x, y):
        """Return index of a node of the segment closest to coordinates."""
        min_node = 0
        min_dist = 360**2
        eps1 = 0.00005**2
        eps2 = 0.0002**2
        eps3 = 0.005**2
        ahead = range(self._last_node, len(self.x) - 1)
        behind = reversed(range(0, self._last_node))
        for iterator in (ahead, behind):
            for i in iterator:
                # This should be faster than haversine
                # and probably close enough.
                dist = poor.polysimp.get_sq_seg_dist(
                    x, y, self.x[i], self.y[i], self.x[i+1], self.y[i+1])
                if dist < min_dist:
                    min_node = i
                    min_dist = dist
                # Try to terminate as soon as possible.
                # These conditions will fail if off route.
                if min_dist < eps1: break
                if min_dist < eps2 and dist > eps3: break
        self._last_node = min_node
        a, b = min_node, min_node + 1
        dist_a = (x - self.x[a])**2 + (y - self.y[a])**2
        dist_b = (x - self.x[b])**2 + (y - self.y[b])**2
        return (a if dist_a < dist_b else b)

    def _get_direction(self, x, y, node):
        """Return the direction of the route at `node`."""
        if node > 0:
            # The closest segment is right before or after the closest node.
            dist = (x - self.x[node])**2 + (y - self.y[node])**2
            dist_prev = (x - self.x[node-1])**2 + (y - self.y[node-1])**2
            if dist_prev < dist: node -= 1
        node = max(0, min(len(self.x) - 2, node))
        # If the closest route segment is very short, it could be a lane change
        # or something else unordinary, which we are unlikely to want to rotate
        # over. Find segments to cover a minimum distance and take the median
        # of their individual directions to dampen irrelevant variation.
        length = self._calculate_length_ahead(node)
        directions = [self._calculate_direction_ahead(node)]
        r = 1
        while length < 50 and node - r >= 0 and node + r < len(self.x) - 1:
            directions.append(self._calculate_direction_ahead(node - r))
            directions.append(self._calculate_direction_ahead(node + r))
            length += self._calculate_length_ahead(node - r)
            length += self._calculate_length_ahead(node + r)
            r += 1
        return statistics.median(directions)

    def get_display(self, x, y, accuracy=None, navigating=False):
        """Return a dictionary of status details to display."""
        if not self.ready: return None
        if self.mode == "transit":
            return self._get_display_transit(x, y)
        node = self._get_closest_segment_node(x, y)
        seg_dists = self._get_distances_from_route(x, y, node)
        seg_dist = min(seg_dists)
        dest_dist, dest_time = self._get_display_destination(
            x, y, node, seg_dist)
        progress  = (max(self.time) - dest_time) / max(self.time)
        dest_dist = poor.util.format_distance(dest_dist)
        dest_eta = (datetime.datetime.now()+datetime.timedelta(seconds=dest_time)).strftime("%H:%M")
        dest_time = poor.util.format_time(dest_time)
        man = self._get_display_maneuver(x, y, node, seg_dists)
        man_node, man_dist, man_time, icon, narrative = man
        voice_uri = (
            self._get_voice_uri(man_node, man_dist, man_time)
            if seg_dist < 100 and navigating else None)
        man_dist = poor.util.format_distance(man_dist)
        man_time = poor.util.format_time(man_time)
        if seg_dist > 100:
            # Don't show the narrative or details calculated
            # from nodes along the route if far off route.
            dest_time = man_time = icon = narrative = None
        # Don't provide route direction to auto-rotate by if off route.
        direction = self._get_direction(x, y, node) if seg_dist < 50 else None
        # Trigger rerouting if off route (usually after missed a turn).
        reroute = seg_dist > 100 + (accuracy or 40000000)
        return dict(total_dist=poor.util.format_distance(max(self.dist)),
                    total_time=poor.util.format_time(max(self.time)),
                    dest_dist=dest_dist,
                    dest_eta=dest_eta,
                    dest_time=dest_time,
                    man_dist=man_dist,
                    man_time=man_time,
                    progress=progress,
                    icon=icon,
                    narrative=narrative,
                    direction=direction,
                    voice_uri=voice_uri,
                    reroute=reroute)

    def _get_display_destination(self, x, y, node, seg_dist):
        """Return destination details to display."""
        dest_dist = seg_dist + self.dist[node]
        dest_time = self.time[node]
        if node == len(self.x) - 1 or dest_dist < 500:
            # Use exact straight-line value at the very end.
            dest_dist = poor.util.calculate_distance(
                x, y, self.maneuver[node].x, self.maneuver[node].y)
        return dest_dist, dest_time

    def _get_display_maneuver(self, x, y, node, seg_dists):
        """Return maneuver details to display."""
        # For car, show narrative of the next maneuver point following
        # the closest route segment, but avoid considering the maneuver point
        # passed too soon in case the positioning jumps around a bit.
        if len(seg_dists) == 2:
            # If the segment following the closest node is closer than
            # the one preceding, use the maneuver data of the next node.
            s1, s2 = seg_dists
            if s2 < s1/2 and s1 > 10:
                node = node + 1
        seg_dist = min(seg_dists)
        maneuver = self.maneuver[node]
        man_node = maneuver.node
        man_dist = seg_dist + self.dist[node] - self.dist[man_node]
        man_time = self.time[node] - self.time[man_node]
        if node == man_node or man_dist < 500:
            # Use exact straight-line value at the very end.
            man_dist = poor.util.calculate_distance(
                x, y, maneuver.x, maneuver.y)
        return man_node, man_dist, man_time, maneuver.icon, maneuver.narrative

    def _get_display_transit(self, x, y):
        """Return a dictionary of status details to display."""
        # For transit, show narrative of the closest node, since transit
        # maneuver points are not always points, but often stations or
        # platforms that cover a large area.
        node = self._get_closest_segment_node(x, y)
        seg_dist = self._get_distance_from_route(x, y, node)
        dest_dist, dest_time = self._get_display_destination(
            x, y, node, seg_dist)
        progress  = (max(self.time) - dest_time) / max(self.time)
        dest_dist = poor.util.format_distance(dest_dist)
        dest_eta = (datetime.datetime.now()+datetime.timedelta(seconds=dest_time)).strftime("%H:%M")
        dest_time = poor.util.format_time(dest_time)
        man_node  = self._get_closest_maneuver_node(x, y, node)
        if man_node > node + 1:
            # If the maneuver point is far and still ahead, we can calculate
            # distances and times from along the route, just as for cars.
            man_dist = seg_dist + self.dist[node] - self.dist[man_node]
            man_time = self.time[node] - self.time[man_node]
        else:
            # If the maneuver point is the very next one,
            # or already passed, use straight-line distance.
            man_dist = poor.util.calculate_distance(
                x, y, self.maneuver[man_node].x, self.maneuver[man_node].y)
            man_time = 0
        if node > man_node and man_dist > 500:
            # If closest maneuver point surely passed,
            # show narrative of the next maneuver.
            man_dist = poor.util.calculate_distance(
                x, y, self.maneuver[node].x, self.maneuver[node].y)
            icon = self.maneuver[node].icon
            narrative = self.maneuver[node].narrative
        else:
            # If near a maneuver point,
            # show the corresponding narrative.
            icon = self.maneuver[man_node].icon
            narrative = self.maneuver[man_node].narrative
        man_dist = poor.util.format_distance(man_dist)
        man_time = poor.util.format_time(man_time)
        # Don't provide route direction to auto-rotate by if off route.
        direction = self._get_direction(x, y, node) if seg_dist < 50 else None
        return dict(total_dist=poor.util.format_distance(max(self.dist)),
                    total_time=poor.util.format_time(max(self.time)),
                    dest_dist=dest_dist,
                    dest_eta=dest_eta,
                    dest_time=dest_time,
                    man_dist=man_dist,
                    man_time=man_time,
                    progress=progress,
                    icon=icon,
                    narrative=narrative,
                    direction=direction,
                    voice_uri=None,
                    reroute=False)

    def _get_distance_from_route(self, x, y, node):
        """Return distance in meters from the route polyline."""
        return min(self._get_distances_from_route(x, y, node))

    def _get_distances_from_route(self, x, y, node):
        """Return distances in meters from route segments."""
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

    def get_maneuvers(self, x, y):
        """Return a list of dictionaries of maneuver details."""
        node = self._get_closest_segment_node(x, y)
        man_node = self._get_closest_maneuver_node(x, y, node)
        maneuvers = filter(None, set(self.maneuver))
        maneuvers = sorted(maneuvers, key=lambda x: x.node)
        return [dict(
            active=(maneuver.node == man_node),
            icon=maneuver.icon,
            length=poor.util.format_distance(maneuver.length),
            narrative=maneuver.narrative,
            verbal_alert=maneuver.verbal_alert,
            verbal_post=maneuver.verbal_post,
            verbal_pre=maneuver.verbal_pre,
            x=maneuver.x,
            y=maneuver.y,
        ) for maneuver in maneuvers]

    def get_message_voice_uri(self, message):
        """Return WAV file URI for `message` or ``None``."""
        return self.voice_generator.get(__(message, self.language))

    def _get_next_maneuver(self, maneuver):
        """Return the maneuver after `maneuver` or ``None``."""
        for i in range(maneuver.node + 1, len(self.maneuver)):
            if self.maneuver[i].node > maneuver.node:
                return self.maneuver[i]
        return None

    def _get_previous_maneuver(self, maneuver):
        """Return the maneuver before `maneuver` or ``None``."""
        for i in range(maneuver.node - 1, -1, -1):
            if self.maneuver[i].node < maneuver.node:
                return self.maneuver[i]
        return None

    def _get_voice_uri(self, man_node, man_dist, man_time):
        """Return WAV file URI of verbal prompt or ``None``."""
        if not poor.conf.voice_navigation: return None
        if not self.voice_generator.active: return None
        dist = man_dist + self.dist[man_node]
        time = man_time + self.time[man_node]
        for prompt in self.verbals:
            # Generate a couple new WAV files ahead,
            # since some TTS engines can be slow.
            if prompt.passed: continue
            if prompt.generated: continue
            if prompt.time < time - 300: break
            self.voice_generator.make(prompt.text)
        # Generate and keep available standard messages.
        self.voice_generator.make(__("Rerouting", self.language))
        self.voice_generator.make(__("Rerouting failed", self.language))
        self.voice_generator.make(__("New route found", self.language))
        for i, prompt in reversed(list(enumerate(self.verbals))):
            if prompt.passed: continue
            # Avoid being consistently late playing voice directions
            # by accounting for the polling frequency and any delays
            # between the below code and actual playback start.
            if (dist < prompt.dist + 20 or
                time < prompt.time + 2):
                for j in range(i, -1, -1):
                    self.verbals[j].passed = True
                text = self.verbals[i].text
                message = text.encode("ascii", errors="replace")
                message = message.decode("ascii")
                print("About to play: {}".format(message))
                return self.voice_generator.get_uri(text)
        # No voice to play at the current location.
        return None

    def quit(self):
        """Clean up before quitting application."""
        self.voice_generator.quit()

    @property
    def ready(self):
        """Return ``True`` if narrative is in steady state and ready for use."""
        return (self.x and
                len(self.x) ==
                len(self.y) ==
                len(self.dist) ==
                len(self.time) ==
                len(self.maneuver))

    def _remove_overlapping_verbals(self):
        """Remove the least important of overlapping verbal prompts."""
        for i in list(range(len(self.verbals))):
            if i >= len(self.verbals) - 1: break
            end = self.verbals[i].time - self.verbals[i].duration
            next_start = self.verbals[i+1].time
            while end < next_start:
                iw = self.verbals[i].importance
                jw = self.verbals[i+1].importance
                remove = i if iw < jw else i + 1
                del self.verbals[remove]
                next_start = (self.verbals[i+1].time
                              if remove == i + 1 and i + 1 < len(self.verbals)
                              else -1)

    def set_maneuvers(self, maneuvers):
        """
        Set maneuver points and corresponding narrative.

        Keys "x", "y" and "duration" are required for each item in `maneuvers`
        and keys "icon", "narrative" and "passive" are optional. Duration
        (seconds) and length (meters) refers to the leg following the maneuver,
        other data is associated with the maneuver point itself.
        """
        next_maneuver = None
        verbals = []
        for i in reversed(range(len(maneuvers))):
            if maneuvers[i].get("passive", False): continue
            maneuver = Maneuver(**maneuvers[i])
            maneuver.node = self._get_closest_node(maneuver.x, maneuver.y)
            self.maneuver[maneuver.node] = maneuver
            # Assign maneuver to preceding nodes as well.
            for j in reversed(range(maneuver.node)):
                self.maneuver[j] = maneuver
            # Calculate time remaining to destination for each node
            # based on durations of individual legs following given maneuvers.
            if next_maneuver is not None:
                next_dist = self.dist[next_maneuver.node]
                maneuver.length = self.dist[maneuver.node] - next_dist
                for j in reversed(range(maneuver.node, next_maneuver.node)):
                    dist = self.dist[j] - self.dist[j+1]
                    self.time[j] = self.time[j+1] + dist/maneuver.speed
            next_maneuver = maneuver
            maneuvers[i]["maneuver"] = maneuver
            verbals.insert(0, maneuvers[i])
        self._set_verbals(verbals)

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
        self._last_node = 0
        for i in list(reversed(range(len(x) - 1))):
            dist = poor.util.calculate_distance(x[i], y[i], x[i+1], y[i+1])
            if dist < 1:
                # Consecutive duplicate points will cause problems for
                # calculations that determine when to show narrative related
                # to a maneuver point. We need to drop these.
                del self.x[i]
                del self.y[i]
                del self.dist[i]
                del self.time[i]
                del self.maneuver[i]
                continue
            self.dist[i] = self.dist[i+1] + dist
            # Calculate remaining time using 120 km/h, which will maximize
            # the advance at which maneuver notifications are shown.
            # See 'set_maneuvers' for the actual leg-specific times
            # that should in most cases overwrite these.
            self.time[i] = self.time[i+1] + (dist/1000/120) * 3600

    def _set_verbals(self, prompts):
        """Set verbal prompts for maneuver points."""
        self.verbals = []
        prompts = list(map(poor.AttrDict, prompts))
        for prompt in sorted(prompts, key=lambda x: x.maneuver.node):
            prompt.setdefault("verbal_pre", prompt.narrative)
            prompt.setdefault("verbal_alert", prompt.narrative)
            prev_man = self._get_previous_maneuver(prompt.maneuver)
            if prev_man is None: continue
            # Attributes of pre- and post-maneuver legs.
            # Units are meters, seconds and meters/second.
            pre_length = prev_man.length
            pre_duration = prev_man.duration
            pre_speed = max(1, prev_man.speed)
            post_length = prompt.maneuver.length
            post_duration = prompt.maneuver.duration
            post_speed = max(1, prompt.maneuver.speed)
            # For each prompt, assing both a distance (m) and a time (s) offset
            # before or after the associated maneuver that the prompt should be
            # played. This is to account for the speed not actually being
            # constant over the whole leg, for possible rounding issues with
            # short legs and for the practical maneuver need often being when
            # grouping lanes separate instead of the intersection center.
            if prompt.get("verbal_alert", "") and pre_duration > 1800:
                # Add advance alert, e.g. "In 1 km, turn right onto Broadway."
                dist_offset = min(500, pre_length - 30)
                time_offset = min(90, pre_duration - 3)
                item = Verbal()
                item.dist = self.dist[prompt.maneuver.node] + dist_offset
                item.time = self.time[prompt.maneuver.node] + time_offset
                item.text = self._format_verbal_alert(
                    prompt.verbal_pre, dist_offset, time_offset, pre_speed)
                item.speed = pre_speed
                item.importance = 1
                self.verbals.append(item)
            if prompt.get("verbal_alert", "") and pre_duration > 20:
                # Add advance alert, e.g. "In 100 m, turn right onto Broadway."
                dist_offset = min(100, pre_length - 30)
                time_offset = min(30, pre_duration - 3)
                item = Verbal()
                item.dist = self.dist[prompt.maneuver.node] + dist_offset
                item.time = self.time[prompt.maneuver.node] + time_offset
                item.text = self._format_verbal_alert(
                    prompt.verbal_pre, dist_offset, time_offset, pre_speed)
                item.speed = pre_speed
                item.importance = 4
                self.verbals.append(item)
            if prompt.get("verbal_pre", ""):
                # Add pre-maneuver prompt, e.g. "Turn right onto Broadway."
                dist_offset = min(50, pre_length - 10)
                time_offset = min(5, pre_duration - 1)
                item = Verbal()
                item.dist = self.dist[prompt.maneuver.node] + dist_offset
                item.time = self.time[prompt.maneuver.node] + time_offset
                item.text = prompt.verbal_pre
                item.speed = pre_speed
                item.importance = 3
                self.verbals.append(item)
            if prompt.get("verbal_post", "") and post_duration > 20:
                # Add post-maneuver prompt, e.g. "Continue for 100 m."
                dist_offset = min(50, post_length - 30)
                time_offset = min(5, post_duration - 3)
                item = Verbal()
                item.dist = self.dist[prompt.maneuver.node] - dist_offset
                item.time = self.time[prompt.maneuver.node] - time_offset
                item.text = prompt.verbal_post
                item.speed = post_speed
                item.importance = 2
                self.verbals.append(item)
        # Remove the least important of overlapping prompts.
        self._remove_overlapping_verbals()

    def set_voice(self, language, gender="male"):
        """Set TTS engine and voice to use for directions."""
        self.language = language
        self.voice_generator.set_voice(language, gender)

    def unset(self):
        """Unset route and maneuvers."""
        self.dist = []
        self._last_node = 0
        self.maneuver = []
        self.mode = "car"
        self.time = []
        self.verbals = []
        self.x = []
        self.y = []
