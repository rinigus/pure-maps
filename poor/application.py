# -*- coding: utf-8 -*-

# Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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

"""An application to display maps and stuff."""

import poor
import random
import sys

__all__ = ("Application",)


class Application:

    """An application to display maps and stuff."""

    def __init__(self):
        """Initialize an :class:`Application` instance."""
        # some of the components are initialized separately
        # after handling of all licenses
        random.seed()
        self.history = poor.HistoryManager()
        self.magfield = poor.MagField()
        self.sun = poor.Sun()
        self._voice = {}

    def initialize(self):
        """Initialize all components that may depend on licenses."""
        self.basemap = poor.MapManager()
        self.geocoder = None
        self.guide = None
        self.router = None
        self.set_basemap(poor.conf.basemap)
        self.set_geocoder(poor.conf.geocoder)
        self.set_guide(poor.conf.guide)
        self.set_router(poor.conf.router)

    def get_attribution(self, type, providers):
        """Return attribution entries for given providers."""
        items = []
        cls = poor.util.get_provider_class(type)
        for provider in providers:
            with poor.util.silent(Exception):
                for item in cls(provider).attribution:
                    if item["text"] not in (x["text"] for x in items):
                        items.append(item)
        return items

    def quit(self):
        """Quit the application."""
        print("Quitting")
        print("Calling http.pool.terminate")
        poor.http.pool.terminate()
        print("Calling poor.conf.write")
        poor.conf.write()
        print("Calling self.history.write")
        self.history.write()
        print("Closing voice engines")
        for i in self._voice.keys(): self._voice[i].quit()
        print("All quit methods called")

    def set_basemap(self, basemap):
        """Set basemap from string `basemap`."""
        self.basemap.set_basemap(basemap)

    def set_geocoder(self, geocoder):
        """Set geocoding provider from string `geocoder`."""
        try:
            self.geocoder = poor.Geocoder(geocoder)
            poor.conf.set_geocoder(geocoder)
        except Exception as error:
            print("Failed to load geocoder '{}': {}"
                  .format(geocoder, str(error)),
                  file=sys.stderr)
            if self.geocoder is None:
                default = poor.conf.get_default("geocoder")
                if default != geocoder:
                    self.set_geocoder(default)

    def set_guide(self, guide):
        """Set place guide provider from string `guide`."""
        try:
            self.guide = poor.Guide(guide)
            poor.conf.set_guide(guide)
        except Exception as error:
            print("Failed to load guide '{}': {}"
                  .format(guide, str(error)),
                  file=sys.stderr)
            if self.guide is None:
                default = poor.conf.get_default("guide")
                if default != guide:
                    self.set_guide(default)

    def set_profile(self, profile):
        """Set current profile."""
        if poor.conf.profile == profile: return
        poor.conf.set_profile(profile)
        self.basemap = poor.MapManager()
        self.set_basemap(poor.conf.basemap)
        self.set_geocoder(poor.conf.geocoder)
        self.set_guide(poor.conf.guide)
        self.set_router(poor.conf.router)

    def set_router(self, router):
        """Set routing provider from string `router`."""
        try:
            self.router = poor.Router(router)
            poor.conf.set_router(router)
        except Exception as error:
            print("Failed to load router '{}': {}"
                  .format(router, str(error)),
                  file=sys.stderr)
            if self.router is None:
                default = poor.conf.get_default("router")
                if default != router:
                    self.set_router(default)

    def set_voice(self, engine, language, gender):
        self.voice(engine).set_voice(language, gender)

    def voice(self, engine):
        if engine not in self._voice:
            self._voice[engine] = poor.VoiceGenerator()
        return self._voice[engine]

    def voice_active(self, engine):
        return self.voice(engine).active

    def voice_current_engine(self, engine):
        return self.voice(engine).current_engine

    def voice_get_uri(self, engine, text):
        return self.voice(engine).get_uri(text)

    def voice_make(self, engine, text, preserve):
        self.voice(engine).make(text, preserve)
