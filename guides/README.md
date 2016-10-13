Implementing a Place Guide
==========================

By a place guide we mean a service that provides a geocoded list of
places by type (e.g. restaurant) around a given location and possibly
details, reviews, ratings, etc. of those places.

To implement a place guide you need to write a JSON metadata file, a
Python file that implements the `nearby` function and possibly a QML
file. The `nearby` function should given a string query, a point and a
radius return coordinates of the point and a list of dictionaries of
places, with each dictionary having keys `title`, `description`, `x` and
`y`. The point to search near can be either a string (an address, a
landmark, etc.) or a two-element tuple or list of (x, y) coordinates.

The QML settings file (`*_settings.qml`) is optional; it can be used to
provide a column of guide-specific settings, which are shown in Poor's
nearby page below the standard selectors. To pass settings to your
guide, you have two options. If those settings are to be saved across
sessions, define a `CONF_DEFAULTS` attribute in your Python code; it
will be automatically passed to and available at `poor.conf`. For
settings which shouldn't be saved across sessions, you can use
`page.params` in your QML.

To download data you should always use `poor.http.request_url` or
`poor.http.request_json` in order to use Poor's user-agent and default
timeout and error handling. If your guide provider cannot handle
addresses, but requires coordinates, consider geocoding using
`default`, which is shipped with Poor. See the guides shipped with
Poor for examples.

Use `~/.local/share/harbour-poor-maps/guides` as a local installation
directory in which to place your files. Restart Poor, and your guide
should be loaded, listed and available for use. During development,
consider keeping your files under the Poor Maps source tree and using
the Python interpreter or a test script, e.g.

```python
>>> import poor
>>> guide = poor.Guide("my_guide")
>>> guide.nearby("restaurant", "erottaja, helsinki", 1000)
```

and qmlscene (`/usr/lib/qt5/bin/qmlscene qml/poor-maps.qml`) for
testing.
