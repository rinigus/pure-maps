Implementing a Venue Guide
==========================

By a venue guide we mean a service that provides a geocoded list of
venues by type (e.g. restaurant) around a given location and possibly
details, reviews, ratings, etc. of those venues.

## API

To implement a venue guide you need to write a JSON metadata file, a
Python file that implements the `nearby` function and possibly a QML
settings file. The `nearby` function should given a string query, a
point and a radius return coordinates of the point and a list of
dictionaries of venues, with each dictionary having keys `title`,
`description`, `x` and `y`, example below. The point to search near can
be either a string (an address, a landmark, etc.) or a two-element tuple
or list of (x, y) coordinates.

```python
[
    {
        "title": "Ragu",
        "description": "8.9/10, Restaurant, Ludviginkatu 3-5...",
        "x": 24.944736480080568,
        "y": 60.165858355160665,
    },
    ...
]
```

The QML settings file (`*_settings.qml`) is optional; it can be used to
provide a column of guide-specific settings, which are shown in Pure's
nearby page below the standard selectors. To pass settings to your
guide, you have two options. If those settings are to be saved across
sessions, define a `CONF_DEFAULTS` attribute in your Python code; it
will be automatically passed to and available at `poor.conf`. For
settings which shouldn't be saved across sessions, you can use
`page.params` in your QML.

## Tips

To download data you should always use `poor.http.get` or
`poor.http.get_json` in order to use Pure's user-agent and default
timeout and error handling. You might also find `poor.AttrDict`, a
dictionary with attribute access to keys, convenient when working with
JSON data.

Use `~/.local/share/harbour-pure-maps/guides` as a local installation
directory in which to place your files. Restart Pure Maps, and your
guide should be loaded, listed and available for use. During
development, consider keeping your files under the Pure Maps source
tree and using the Python interpreter or a test script, e.g.

```python
>>> import poor
>>> guide = poor.Guide("my_guide")
>>> guide.nearby("restaurant", "erottaja, helsinki", 1000)
```

and qmlscene (`qmlscene qml/pure-maps.qml`) for testing.
