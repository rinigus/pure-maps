Implementing a Geocoder
=======================

## API

To implement a geocoder, you need to write two files: a JSON metadata
file and a Python file that implements the `geocode` function. The
`geocode` function should given a string query return a list of
dictionaries of geocoding results, with each dictionary having keys
`title`, `description`, `x` and `y`, example below.

```python
[
    {
        "title": "Erottaja",
        "description": "Mannerheimintie, 00120 Helsinki, Finland",
        "x": 24.9434147,
        "y": 60.1669202,
    },
    ...
]
```

## Tips

To download data you should always use `poor.http.get` or
`poor.http.get_json` in order to use Pure's user-agent and default
timeout and error handling. You might also find `poor.AttrDict`, a
dictionary with attribute access to keys, convenient when working with
JSON data.

Use `~/.local/share/harbour-pure-maps/geocoders` as a local
installation directory in which to place your files. Restart Pure Maps,
and your geocoder should be loaded, listed and available for use. During
development, consider keeping your files under the Pure Maps source
tree and using the Python interpreter or a test script, e.g.

```python
>>> import poor
>>> geocoder = poor.Geocoder("my_geocoder")
>>> geocoder.geocode("erottaja, helsinki")
```

and qmlscene (`qmlscene qml/pure-maps.qml`) for testing.
