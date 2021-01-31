Implementing a Router
=====================

## API

To implement a router you need to write a JSON metadata file, a Python
file that implements the `route` function and one QML
file. The `route` function should given two points return a
dictionary of route properties with keys `x`, `y`, `locations`,
`location_indexes`, `maneuvers`, `mode` and `language`, example
below. The location points (2 or more) are given as an argument in the
form of a list. List elements can be strings (addresses, landmarks,
etc.), two-element tuples or lists of (x, y) coordinates, or
dictionaries with the keys `x`, `y` (coordinates), and optional `text`
(can be used by router to describe location). If returning multiple
alternative routes for the user to choose from, the return value
should be a list of dictionaries of route properties. 

```python
{
    "x": [24.943464, 24.943294, 24.94318, ...],
    "y": [60.166938, 60.167053, 60.16705, ...],
    "locations": as_supplied_to_the_route_function_call,
    "location_indexes": [0, 122, ...],
    "maneuvers": [
        {
            "x": 24.943464,
            "y": 60.166938,
            "icon": "depart",
            "narrative": "Drive northwest.",
            "duration": 29.0,
        },
        ...
    ],
    "mode": "car",
    "language": "en_US",
}
```

Here, `location_indexes` designate the index of the point on the route
(xi,yi) which is considered as the closest to the location.

A QML file, the settings file (`*_settings.qml`) is optional;
it can be used to provide a column of router-specific settings, which
are shown in Pure's routing page below the endpoint selectors. To pass
settings to your router, you have two options. If those settings are to
be saved across sessions, define a `CONF_DEFAULTS` attribute in your
Python code; it will be automatically passed to and available at
`poor.conf`. For settings which shouldn't be saved across sessions, you
can use `page.params` in your QML.

If you provide settings file, you will have to ensure that QML object has
`full` property. When this property is set to `false`, only minimal settings
(if any) are expected. Show all settings when `full` is `true`.

If your router supports multiple languages, provide the list of
languages in `*_settings.qml` and use the user-given selection in the
Python `route` function. When returning the narration language as a part
of the return dictionary of `route`, make sure to use the standard
locale format `xx[_YY]`. See the OSM Scout router for an example on how
to implement language settings in QML and Python.

To display a route on the map, you'll want to call
`navigator.setRoute`. See the implementation of these functions in
`qml/Navigator.qml` to understand which fields are expected in their
arguments.

## Tips

To download data you should always use `poor.http.get` or
`poor.http.get_json` in order to use Pure's user-agent and default
timeout and error handling. You might also find `poor.AttrDict`, a
dictionary with attribute access to keys, convenient when working with
JSON data.

Use `~/.local/share/harbour-pure-maps/routers` as a local installation
directory in which to place your files. Since routers require QML files
and include `"../qml"` in their source, add a symbolic link
`~/.local/share/harbour-pure-maps/qml` pointing to
`/usr/share/harbour-pure-maps/qml`. Restart Pure Maps, and your router
should be loaded, listed and available for use. During development,
consider keeping your files under the Pure Maps source tree and using
the Python interpreter or a test script, e.g.

```python
>>> import poor
>>> router = poor.Router("my_router")
>>> router.route(["erottaja, helsinki", "tapiola, espoo"])
```

for testing.