# -*- coding: utf-8 -*-

# Copyright (c) 2017 Osmo Salomaa
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""Dictionary with attribute access to keys."""

__all__ = ("AttrDict",)


class AttrDict(dict):

    """Dictionary with attribute access to keys."""

    def __init__(self, *args, **kwargs):
        """Initialize from :class:`dict`-compatible arguments."""
        dict.__init__(self, *args, **kwargs)
        for key, value in self.items():
            setattr(self, key, value)

    def __coerce(self, value):
        """Return `value` with dictionaries as attribute dictionaries."""
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
