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
import threading
import time


def purge(max_age=None):
    """
    Remove all expired tiles from the cache directory.

    `max_age` should be age in days, tiles older which to remove.
    If `max_age` is not given, the minimum of tilesource's "max_age" field
    and :attr:`poor.conf.cache_max_age` will be used.
    """
    max_age_given = max_age
    directories = glob.glob("{}/*".format(poor.CACHE_HOME_DIR))
    directories = list(filter(os.path.isdir, directories))
    get_age = lambda x: (x["pid"], x.get("max_age", poor.conf.cache_max_age))
    ages = dict(get_age(x) for x in poor.util.get_tilesources())
    for directory in sorted(directories):
        child = os.path.basename(directory)
        max_age = max_age_given
        if max_age_given is None:
            max_age = poor.conf.cache_max_age
            max_age = min((max_age, ages.get(child, max_age)))
        if max_age >= 36500: continue
        purge_directory(child, max_age)

def purge_async(max_age=None):
    """Remove all expired tiles from the cache directory."""
    threading.Thread(target=purge,
                     kwargs=dict(max_age=max_age),
                     daemon=True).start()

def purge_directory(directory, max_age):
    """
    Remove all expired tiles in cache subdirectory.

    `directory` should be a relative directory under
    :attr:`poor.conf.CACHE_HOME_DIR`. `max_age` should be age in days,
    tiles older which to remove.
    """
    if not directory: return
    basename = directory
    if not poor.CACHE_HOME_DIR:
        # This shouldn't happen, but just in case it does,
        # let's try to avoid a disaster.
        raise Exception("poor.CACHE_HOME_DIR not set")
    directory = os.path.join(poor.CACHE_HOME_DIR, directory)
    directory = os.path.realpath(directory)
    if not os.path.isdir(directory): return
    if os.path.samefile(os.path.expanduser("~"), directory):
        # This shouldn't happen, but just in case it does,
        # let's try to avoid a disaster.
        raise Exception("Refusing to act on $HOME")
    print("Purging cache >{:3.0f}d for {:22s}..."
          .format(max_age, repr(basename)), end="")

    cutoff = time.time() - max_age * 86400
    total = removed = 0
    # Only follow symlinks for the directory itself, not its children
    # in order to simplify matters and do a safe bottomup walk.
    for root, dirs, files, rootfd in os.fwalk(
            directory, topdown=False, follow_symlinks=False):
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
        # Release GIL to let other threads do something more important.
        time.sleep(0.000001)
    with poor.util.silent(OSError):
        # Fails if the directory is not empty.
        # Fails if the directory is a symlink.
        os.rmdir(directory)
    print(" {:6d} tiles removed, {:6d} left.".format(removed, total-removed))

def purge_directory_async(directory, max_age):
    """Remove all expired tiles in cache subdirectory."""
    threading.Thread(target=purge_directory,
                     args=(directory, max_age),
                     daemon=True).start()

def stat():
    """Return file count and total size of cache subdirectories."""
    stat = []
    directories = glob.glob("{}/*".format(poor.CACHE_HOME_DIR))
    directories = list(filter(os.path.isdir, directories))
    for directory in sorted(directories):
        child = os.path.basename(directory)
        stat.append(stat_directory(child))
    return stat

def stat_directory(directory):
    """
    Return file count and total size of cache subdirectory.

    `directory` should be a relative directory under
    :attr:`poor.conf.CACHE_HOME_DIR`.
    """
    count = 0
    bytes = 0
    basename = directory
    directory = os.path.join(poor.CACHE_HOME_DIR, directory)
    directory = os.path.realpath(directory)
    if os.path.isdir(directory):
        for root, dirs, files, rootfd in os.fwalk(
                directory, follow_symlinks=False):
            count += len(files)
            bytes += sum(os.stat(x, dir_fd=rootfd).st_size for x in files)
    names = dict((x["pid"], x["name"]) for x in poor.util.get_tilesources())
    name = names.get(basename, basename)
    return dict(directory=basename,
                name=name,
                count=count,
                bytes=bytes,
                size=poor.util.format_filesize(bytes))
