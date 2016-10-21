Implementing a Router
=====================

To implement a router you need to write a JSON metadata file, a Python
file that implements the `route` function and one or two QML files. The
`route` function should given two points return properties of the found
route. The from and to points given as arguments can be either strings
(addresses, landmarks, etc.) or two-element tuples or lists of (x, y)
coordinates. The return value format is up to you, since you handle that
in your router-specific QML. However, for passing onwards, a dictionary
of route properties is a good idea, or a list of dictionaries if
returning multiple routes.

Of the two QML files, the settings file (`*_settings.qml`) is optional;
it can be used to provide a column of router-specific settings, which
are shown in Poor's routing page below the endpoint selectors. To pass
settings to your router, you have two options. If those settings are to
be saved across sessions, define a `CONF_DEFAULTS` attribute in your
Python code; it will be automatically passed to and available at
`poor.conf`. For settings which shouldn't be saved across sessions, you
can use `page.params` in your QML. See the `hsl` router for an example
of both of these two ways.

The second QML file (`*_results.qml`) is mandatory and used to specify a
result page. At minimum this should be a page which shows a busy
indicator and handles passing data to the map or notification if no
results found. For a minimal router that returns one route, you can copy
`mapquest_open` or `osrm` and possibly adapt that. If writing a router
that returns several routes that the user can choose from and/or allows
a closer examination of the route properties before showing it on a map,
you can use this page to display whatever is best suitable given your
router and domain. For example, the `hsl` router shows five alternative
public transportation routes with relevant details of each.

To display a route on the map, you'll want to call `map.addRoute` and
`map.addManeuvers`. See the documentation of these functions in
`qml/Map.qml` to understand which fields are expected in their
arguments. It is easiest to have your Python `route` function return
something that can fairly directly be passed to these QML functions.

To download data you should always use `poor.http.request_url` or
`poor.http.request_json` in order to use Poor's user-agent and default
timeout and error handling. If your routing provider cannot handle
addresses, but requires coordinates, consider geocoding using
`default`, which is shipped with Poor. See the routers shipped with
Poor for examples.

Use `~/.local/share/harbour-poor-maps/routers` as a local installation
directory in which to place your files. Since routers require QML
files and include `"../qml"` in their source, add a symbolic link at
`~/.local/share/harbour-poor-maps/qml` pointing to
`/usr/share/harbour-poor-maps/qml`. Restart Poor, and your router
should be loaded, listed and available for use. During development,
consider keeping your files under the Poor Maps source tree and using
the Python interpreter or a test script, e.g.

```python
>>> import poor
>>> router = poor.Router("my_router")
>>> router.route("erottaja, helsinki", "tapiola, espoo")
```

and qmlscene (`/usr/lib/qt5/bin/qmlscene qml/poor-maps.qml`) for
testing.
