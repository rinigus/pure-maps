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

"""Managing map tiles cached on disk."""

import glob
import os
import poor
import time


def purge(max_age=None):
    """
    Remove all expired tiles from the cache directory.

    `max_age` should be age in days, tiles older which to remove.
    If `max_age` is not given, the minimum of tilesource's "max_age" field
    and :attr:`poor.conf.cache_max_age` will be used.
    """
    directories = glob.glob("{}/*".format(poor.CACHE_HOME_DIR))
    directories = list(filter(os.path.isdir, directories))
    ages = dict((x["pid"], x.get("max_age", poor.conf.cache_max_age))
                for x in poor.util.get_tilesources())

    max_age_given = max_age
    for child in sorted(directories):
        directory = os.path.basename(child)
        max_age = max_age_given
        if max_age_given is None:
            max_age = poor.conf.cache_max_age
            max_age = min((max_age, ages.get(directory, max_age)))
        if max_age >= 36500: continue
        purge_directory(directory, max_age)

def purge_directory(directory, max_age):
    """
    Remove all expired tiles in cache subdirectory.

    `directory` should be a relative directory under
    :attr:`poor.conf.CACHE_HOME_DIR`. `max_age` should be age in days,
    tiles older which to remove.
    """
    if not directory: return
    directory = os.path.join(poor.CACHE_HOME_DIR, directory)
    if not os.path.isdir(directory): return
    print("Purging cache >{:3.0f}d for {:22s}..."
          .format(max_age, repr(os.path.basename(directory))),
          end="")

    cutoff = time.time() - max_age * 86400
    total = removed = 0
    for root, dirs, files, rootfd in os.fwalk(
            directory, topdown=False, follow_symlinks=True):
        total += len(files)
        for name in files:
            if os.stat(name, dir_fd=rootfd).st_mtime < cutoff:
                with poor.util.silent(OSError):
                    os.remove(name, dir_fd=rootfd)
                    removed += 1
        for name in dirs:
            with poor.util.silent(OSError):
                # Fails if the directory is not empty.
                # Fails if the directory is a symlink.
                os.rmdir(name, dir_fd=rootfd)
    with poor.util.silent(OSError):
        # Fails if the directory is not empty.
        # Fails if the directory is a symlink.
        os.rmdir(directory)
    print(" {:6d} tiles removed, {:6d} left.".format(removed, total-removed))

def stat():
    """Return file count and total size of cache subdirectories."""
    stat = []
    directories = glob.glob("{}/*".format(poor.CACHE_HOME_DIR))
    directories = list(filter(os.path.isdir, directories))
    names = dict((x["pid"], x["name"]) for x in poor.util.get_tilesources())
    for child in sorted(directories):
        count = 0
        bytes = 0
        for root, dirs, files, rootfd in os.fwalk(child, follow_symlinks=True):
            count += len(files)
            bytes += sum(os.stat(x, dir_fd=rootfd).st_size for x in files)
        directory = os.path.basename(child)
        name = names.get(directory, directory)
        stat.append(dict(directory=directory,
                         name=name,
                         count=count,
                         bytes=bytes,
                         size=poor.util.format_filesize(bytes)))

    return stat
