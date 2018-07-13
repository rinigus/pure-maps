# -*- coding: utf-8 -*-

# Copyright (C) 2017 Osmo Salomaa
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

"""Text-to-speech (TTS) engines and voice directions support."""

import atexit
import os
import poor
import re
import queue
import shutil
import subprocess
import tempfile
import threading

__all__ = ("VoiceGenerator",)


class VoiceEngine:

    """Base class for text-to-speech (TTS) engines."""

    commands = []
    voices = {}

    def __init__(self, language, gender="male"):
        """Initialize a :class:`VoiceEngine` instance."""
        commands = list(filter(poor.util.requirement_found, self.commands))
        self.command = commands[0] if commands else None
        self.gender = gender
        self.language = language

    def call(self, args, **kwargs):
        """Run command `args` and return process return value."""
        try:
            message = " ".join(args)
            message = message.encode("ascii", errors="replace")
            message = message.decode("ascii")
            print(message, end=" ")
            rvalue = subprocess.call(args, **kwargs)
            print(str(rvalue))
            return rvalue
        except Exception as error:
            print("1:\n{}".format(str(error)))
            return 1

    def make_wav(self, text, fname):
        """Generate voice output to WAV file `fname`."""
        raise NotImplementedError

    @classmethod
    def supports(cls, language):
        """Return ``True`` if `language` is supported."""
        commands = filter(poor.util.requirement_found, cls.commands)
        return any(commands) and language in cls.voices

    def transform_text(self, text):
        """Return `text` transformed for input to TTS engine."""
        if self.language.startswith("en"):
            # XXX: Work around English TTS engines having trouble with
            # non-English characters. This is mostly relevant for languages
            # for which we don't have TTS engines, leaving users with a mix
            # of English narrative and non-English street names.
            text = text.replace("ä", "ae")
            text = text.replace("ö", "oe")
            text = text.replace("å", "aa")
            text = text.replace("æ", "ae")
            text = text.replace("ø", "oe")
        return text

    @property
    def voice_name(self):
        """Return name of the voice to use."""
        voices = self.voices[self.language]
        other = "female" if self.gender == "male" else "male"
        return voices.get(self.gender, voices.get(other, None))


class VoiceEngineEspeak(VoiceEngine):

    """Text-to-speech (TTS) using eSpeak."""

    commands = ["espeak", "harbour-espeak"]
    voices = {
        "ca":    {"male": "catalan"},
        "cz":    {"male": "czech"},
        "de":    {"male": "german"},
        "en":    {"male": "english-us"},
        "en_US": {"male": "english-us"},
        "es":    {"male": "spanish"},
        "fr":    {"male": "french"},
        "hi":    {"male": "hindi"},
        "it":    {"male": "italian"},
        "ru":    {"male": "russian_test"},
        "sl":    {"male": "slovak"},
        "sv":    {"male": "swedish"},
    }

    def make_wav(self, text, fname):
        """Generate voice output to WAV file `fname`."""
        text = self.transform_text(text)
        with open(fname, "w") as f:
            return self.call([self.command,
                              "--stdout",
                              "-v", self.voice_name,
                              text], stdout=f) == 0


class VoiceEngineFlite(VoiceEngine):

    """Text-to-speech (TTS) using CMU Flite (festival-lite)."""

    commands = ["flite", "harbour-flite"]
    voices = {
        "en":    {"male": "kal16", "female": "slt"},
        "en_US": {"male": "kal16", "female": "slt"},
    }

    def make_wav(self, text, fname):
        """Generate voice output to WAV file `fname`."""
        text = self.transform_text(text)
        return self.call([self.command,
                          "-t", text,
                          "-o", fname,
                          "-voice", self.voice_name]) == 0


class VoiceEngineMimic(VoiceEngine):

    """Text-to-speech (TTS) using Mimic (The Mycroft TTS Engine)."""

    commands = ["mimic", "harbour-mimic"]
    voices = {
        "en":    {"male": "ap", "female": "slt"},
        "en_US": {"male": "ap", "female": "slt"},
    }

    def make_wav(self, text, fname):
        """Generate voice output to WAV file `fname`."""
        text = self.transform_text(text)
        return self.call([self.command,
                          "-t", text,
                          "-o", fname,
                          "-voice", self.voice_name]) == 0


class VoiceEnginePicoTTS(VoiceEngine):

    """Text-to-speech (TTS) using PicoTTS."""

    commands = ["pico2wave", "harbour-pico2wave"]
    voices = {
        "de":    {"female": "de-DE"},
        "en":    {"female": "en-US"},
        "en_GB": {"female": "en-GB"},
        "en_US": {"female": "en-US"},
        "es":    {"female": "es-ES"},
        "fr":    {"female": "fr-FR"},
        "it":    {"female": "it-IT"},
    }

    def make_wav(self, text, fname):
        """Generate voice output to WAV file `fname`."""
        text = self.transform_text(text)
        return self.call([self.command,
                          "-w", fname,
                          "-l", self.voice_name,
                          text]) == 0


class VoiceEngineMimicEnUsPirate(VoiceEngine):

    """Text-to-speech (TTS) using Mimic (The Mycroft TTS Engine) tuned for en_US-x-pirate locale"""

    commands = ["mimic", "harbour-mimic"]
    voices = {
        "en-US-x-pirate": {"male": "awb", "female": "slt"},
    }
    phonemes = { "Arrr": "aa r ah0 r r .",
                 "Cap'n": "k ae1 p n",
                 "head'n": "hh eh1 d ah0 n",
                 "th'": "dh" }

    def make_wav(self, text, fname):
        """Generate voice output to WAV file `fname`."""
        text = self.transform_text(text)
        # preprocess to catch few words in Pirate's dictionary
        for word, ph in self.phonemes.items():
            if word == "th'":
                text = text.replace(" %s " % word, ' <phoneme ph="%s">phonemes-given</phoneme> ' % ph)
            else:
                text = re.sub(r"\b%s\b" % word, '<phoneme ph="%s">phonemes-given</phoneme>' % ph, text)
        return self.call([self.command,
                          '-ssml',
                          "-t", text,
                          "-o", fname,
                          "-voice", self.voice_name]) == 0


def voice_worker(task_queue, result_queue, engine, tmpdir):
    """Worker thread to generate WAV files in `task_queue`."""
    while True:
        text = task_queue.get()
        if text is None: break
        handle, fname = tempfile.mkstemp(suffix=".wav", dir=tmpdir)
        success = engine.make_wav(text, fname)
        if not success: fname = None
        result_queue.put((text, fname))
        task_queue.task_done()


class VoiceGenerator:

    """Threaded generator for voice directions."""

    # TTS engines in order of preference.
    engines = [
        VoiceEngineMimic,
        VoiceEngineFlite,
        VoiceEnginePicoTTS,
        VoiceEngineEspeak,
        VoiceEngineMimicEnUsPirate,
    ]

    def __init__(self):
        """Initialize a :class:`VoiceGenerator` instance."""
        self._cache = {}
        self._engine = None
        self._result_queue = None
        self._task_queue = None
        self._tmpdir = tempfile.mkdtemp(prefix="whogo-maps-")
        self._worker_thread = None
        # Normally quit is called from Application,
        # but e.g. when running unit tests we need atexit.
        atexit.register(self.quit)

    @property
    def active(self):
        """Return ``True`` when a TTS engine is selected."""
        return self._engine is not None

    def clean(self):
        """Terminate the worker thread and purge generated files."""
        self._clean_worker()
        for text in list(self._cache):
            self._purge(text)

    def _clean_outdated_cache(self):
        """Remove oldest generated WAV files from cache."""
        # Minimizes RAM use on Sailfish OS where /tmp is in RAM.
        items = list(self._cache.items())
        items = [x for x in items if x[1] is not None]
        items.sort(key=lambda x: os.path.getmtime(x[1]))
        for text, fname in items[:-100]:
            self._purge(text)

    def _clean_worker(self):
        """Terminate the worker thread."""
        if self._worker_thread is None: return
        self._task_queue.put(None)
        self._worker_thread.join(timeout=0)
        self._worker_thread = None
        # Ensure that we have all items.
        self._update_cache()

    def _find_engine(self, language, gender="male"):
        """Return TTS engine instance for `language` and `gender`."""
        if language is None: return None
        for engine in self.engines:
            if engine.supports(language):
                return engine(language, gender)
        if "_" in language:
            # Drop country and try plain language.
            language = language.split("_")[0]
            return self._find_engine(language, gender)
        return None

    def get(self, text):
        """Return the WAV filename for `text`."""
        self._update_cache()
        return self._cache.get(text, None)

    def get_uri(self, text):
        """Return the WAV file URI for `text`."""
        fname = self.get(text)
        if fname is None: return None
        return poor.util.path2uri(fname)

    def make(self, text):
        """Queue `text` for WAV file generation."""
        if self._engine is None: return
        self._update_cache()
        if text in self._cache:
            # WAV file already generated, just update
            # file modification time to prevent removal.
            if self._cache[text] is not None:
                os.utime(self._cache[text])
            return
        if self._worker_thread is None:
            self._result_queue = queue.Queue()
            self._task_queue = queue.Queue()
            self._worker_thread = threading.Thread(
                target=voice_worker,
                kwargs=dict(task_queue=self._task_queue,
                            result_queue=self._result_queue,
                            engine=self._engine,
                            tmpdir=self._tmpdir),

                daemon=True)
            self._worker_thread.start()
        # Add an empty element into cache to ensure that we don't
        # run the same voice direction twice through the engine.
        self._cache[text] = None
        self._task_queue.put(text)
        self._clean_outdated_cache()

    def _purge(self, text):
        """Remove generated WAV file from cache."""
        with poor.util.silent(Exception, tb=True):
            if self._cache[text] is not None:
                os.remove(self._cache[text])
        with poor.util.silent(Exception, tb=True):
            del self._cache[text]

    def quit(self):
        """Terminate the worker thread and purge generated files."""
        self._clean_worker()
        with poor.util.silent(Exception):
            shutil.rmtree(self._tmpdir)

    def set_voice(self, language, gender="male"):
        """Set TTS engine and voice to use."""
        new = self._find_engine(language, gender)
        if self._engine is None and new is None: return
        if (self._engine is None or
            new is None or
            new.__class__ is not self._engine.__class__ or
            new.voice_name != self._engine.voice_name):
            self._engine = new
            self.clean()

    def _update_cache(self):
        """Update the WAV file cache."""
        if self._result_queue is None: return
        while not self._result_queue.empty():
            text, fname = self._result_queue.get_nowait()
            self._result_queue.task_done()
            self._cache[text] = fname
