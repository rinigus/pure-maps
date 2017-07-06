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

"""Dictionary with attribute access to keys."""

__all__ = ("AttrDict",)


class AttrDict(dict):

    """Dictionary with attribute access to keys."""

    def __init__(self, *args, **kwargs):
        """Initialize an :class:`AttrDict` object."""
        dict.__init__(self, *args, **kwargs)
        for key, value in self.items():
            setattr(self, key, value)

    def __coerce(self, value):
        """Return value with dicts as AttrDicts."""
        if isinstance(value, AttrDict):
            # Assume all children are AttrDicts as well. This allows us to do
            # a fast AttrDict(d) to ensure that we're handling an AttrDict.
            return value
        if isinstance(value, dict):
            return AttrDict(value)
        if isinstance(value, (list, tuple, set)):
            return type(value)(map(self.__coerce, value))
        return value

    def __delattr__(self, name):
        """Remove `name` from dictionary."""
        try:
            return self.__delitem__(name)
        except KeyError as error:
            raise AttributeError(str(error))

    def __getattr__(self, name):
        """Return `name` from dictionary."""
        try:
            return self.__getitem__(name)
        except KeyError as error:
            raise AttributeError(str(error))

    def __setattr__(self, name, value):
        """Set `name` to `value` in dictionary."""
        return self.__setitem__(name, value)

    def __setitem__(self, key, value):
        """Set `key` to `value` in dictionary."""
        value = self.__coerce(value)
        return dict.__setitem__(self, key, value)

    def setdefault(self, key, default=None):
        """Return `key` from dictionary, set to `default` if missing."""
        default = self.__coerce(default)
        return dict.setdefault(self, key, default)

    def update(self, *args, **kwargs):
        """Update dictionary with key-value pairs from arguments."""
        other = AttrDict(*args, **kwargs)
        return dict.update(self, other)
