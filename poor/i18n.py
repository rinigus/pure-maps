# -*- coding: utf-8 -*-

# Copyright (C) 2016 Osmo Salomaa
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""Internationalization functions."""

import gettext
import locale
import poor

_translation = gettext.translation(
    "poor-maps",
    localedir=poor.LOCALE_DIR,
    languages=[locale.getdefaultlocale()[0] or ""],
    fallback=True)

_foreign_translations = {}

def _(message):
    """Return the localized translation of `message`."""
    return _translation.gettext(message)

def __(message, language):
    """Return the translation of `message` to `language`."""
    # Try to account for differences between provider API languages
    # and our translations, allowing some amount of fuzziness, e.g.
    # for German try "de" and "de_DE" in addition to the requested.
    plain = language.split("_")[0]
    origin = "{}_{}".format(plain, plain.upper())
    if not language in _foreign_translations:
        _foreign_translations[language] = gettext.translation(
            "poor-maps",
            localedir=poor.LOCALE_DIR,
            languages=[language, plain, origin],
            fallback=True)

    translation = _foreign_translations[language]
    return translation.gettext(message)
