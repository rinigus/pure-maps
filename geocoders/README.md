Implementing a Geocoder
=======================

To implement a geocoder, you need to write two files: a JSON metadata
file and a Python file that implements the `geocode` function. The
`geocode` function should given a string query return a list of
dictionaries of geocoding results, with each dictionary having keys
`title`, `description`, `x` and `y`.

To download data you should always use `poor.http.request_url` or
`poor.http.request_json` in order to use Poor's user-agent and default
timeout and error handling. See the geocoders shipped with Poor for
examples, but note that you should be able to get by with a lot less
code if your geocoding service returns concise, human-readable results.

Use `~/.local/share/harbour-poor-maps/geocoders` as a local installation
directory in which to place your files. Restart Poor, and your geocoder
should be loaded, listed and available for use. During development,
consider keeping your files under the Poor Maps source tree and using
the Python interpreter or a test script, e.g.

```python
>>> import poor
>>> geocoder = poor.Geocoder("my_geocoder")
>>> geocoder.geocode("erottaja, helsinki")
```

and qmlscene (`/usr/lib/qt5/bin/qmlscene qml/poor-maps.qml`) for
testing.
