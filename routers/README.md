Implementing a Router
=====================

## API

To implement a router you need to write a JSON metadata file, a Python
file that implements the `route` function and one or two QML files. The
`route` function should given two points return a dictionary of route
properties with keys `x`, `y`, `maneuvers`, `mode`, `language`, and
`attribution`, example below. The from and to points given as arguments
can be either strings (addresses, landmarks, etc.) or two-element tuples
or lists of (x, y) coordinates. If returning multiple alternative routes
for the user to choose from, the return value should be a list of
dictionaries of route properties. Note that while you handle the return
value yourself in router specific QML, rerouting doesn't go through that
same interactive code and requires a return value consistent with other
routers.

```python
{
    "x": [24.943464, 24.943294, 24.94318, ...],
    "y": [60.166938, 60.167053, 60.16705, ...],
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
    "attribution": "Routing courtesy of Mapzen.",
}
```

Of the two QML files, the settings file (`*_settings.qml`) is optional;
it can be used to provide a column of router-specific settings, which
are shown in Poor's routing page below the endpoint selectors. To pass
settings to your router, you have two options. If those settings are to
be saved across sessions, define a `CONF_DEFAULTS` attribute in your
Python code; it will be automatically passed to and available at
`poor.conf`. For settings which shouldn't be saved across sessions, you
can use `page.params` in your QML.

If your router supports multiple languages, provide the list of
languages in `*_settings.qml` and use the user-given selection in the
Python `route` function. When returning the narration language as a part
of the return dictionary of `route`, make sure to use the standard
locale format `xx[_YY]`. See the Mapzen router for an example on how to
implement language settings in QML and Python.

The second QML file (`*_results.qml`) is mandatory and used to specify a
result page. At minimum this should be a page which shows a busy
indicator and handles passing data to the map or notification if no
results found. If writing a router that returns alternative routes, this
page can be used to list the routes and their properties.

To display a route on the map, you'll want to call `map.addRoute` and
`map.addManeuvers`. See the documentation of these functions in
`qml/Map.qml` to understand which fields are expected in their
arguments. It is easiest to have your Python `route` function return
something that can be directly passed to these QML functions.

## Tips

To download data you should always use `poor.http.get` or
`poor.http.get_json` in order to use Poor's user-agent and default
timeout and error handling. You might also find `poor.AttrDict`, a
dictionary with attribute access to keys, convenient when working with
JSON data.

Use `~/.local/share/harbour-poor-maps/routers` as a local installation
directory in which to place your files. Since routers require QML files
and include `"../qml"` in their source, add a symbolic link at
`~/.local/share/harbour-poor-maps/qml` pointing to
`/usr/share/harbour-poor-maps/qml`. Restart Poor, and your router should
be loaded, listed and available for use. During development, consider
keeping your files under the Poor Maps source tree and using the Python
interpreter or a test script, e.g.

```python
>>> import poor
>>> router = poor.Router("my_router")
>>> router.route("erottaja, helsinki", "tapiola, espoo")
```

and qmlscene (`qmlscene qml/poor-maps.qml`) for testing.
