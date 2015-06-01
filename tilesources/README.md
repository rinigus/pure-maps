Implementing a Tile Source
==========================

To implement a tile source you need to write a JSON metadata file. Most
of the fields are self-explanatory, see the tile sources shipped with
Poor for examples; non-trivial and optional fields are explained below.

* **`extension`**: The filename extension of map tiles. The `extension`
  field is optional; usually you should define it, it makes things
  faster, but if the image format varies by zoom level, you should leave
  it out. If left out, the image format will be auto-detected based on
  the Content-Type header of the HTTP download response.

* **`format`**: Name of tile format implementation. If you mark the
  format as "foo", there should be a `foo.py` file in the tilesources
  directory. The following tile format implementations are shipped with
  Poor, for adding you own, see the next section.

    - `"slippy"`: By far the most common format, based on spherical
      Mercator and division into an amount of tiles that quadruples with
      each zoom level. See [documentation][1]. Provides URL parameters
      `x`, `y` and `z`.

    - `"slippy_elliptical"`: A variation of the "slippy" format, but
      using elliptical Mercator instead of spherical. Provides URL
      parameters `x`, `y` and `z`.

    - `"quadkey"`: By tile division equivalent to the "slippy" format,
      but with tiles referred to by a single key, see
      [documentation][2]. Provides URL parameters `x`, `y`, `z` and
      `key`.

* **`max_age`**: Maximum amount of days to keep tiles cached on disk.
  Usually you should not define this as there is a corresponding global
  preference that gives the user control over up-to-date maps vs. data
  traffic costs. You should, however, define it for tiles that change
  often, e.g. for traffic tiles, try something like 0.01 days, i.e.
  about 15 minutes.

* **`scale`**: The relative pixel density of tiles; e.g. if normal tiles
  are 256x256, then tiles at `scale=2` are 512x512 pixels, covering the
  same geographic area. If omitted, the default `scale=1` is assumed.
  The only allowed values are powers of two: 1, 2, 4, etc. (also 0.5,
  0.25, etc. for the rarer inverse problem). The scale field is meant
  for so called "retina" (or "HiDPI" or "HiRes" or "@2x") tiles that fit
  high pixel density screens better, especially regarding font sizes.
  Note that there are different kinds of retina tiles available and
  different ways of displaying them and thus different definitions for
  different sources.

* **`smooth`**: `true` to display tiles with [smooth filtering][3] –
  useful for tiles not displayed at natural size. If omitted, defaults
  to `false`.

* **`type`**: Type of tiles: either "basemap" or "overlay". If omitted,
  the default "basemap" is assumed. Overlays are partly transparent
  tiles stacked on top of basemaps, e.g. hillshade or traffic.

* **`z`**: The stacking order of layer among overlay tiles. `z` is only
  used for tiles of type "overlay". Low z-values are placed in the
  bottom and high ones on top. Recommended values are 10 for areas, 20
  for lines and 30 for points. Valid values are from 0 to 40.

[1]: http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
[2]: http://msdn.microsoft.com/en-us/library/bb259689.aspx
[3]: http://doc.qt.io/qt-5/qml-qtquick-image.html#smooth-prop

Use `~/.local/share/harbour-poor-maps/tilesources` as a local
installation directory in which to place your JSON file. Restart Poor,
and your tile source should be loaded, listed and available for use.

Implementing a Tile Format
==========================

With most tile sources you should get by with using one of the formats
shipped with Poor, but you can also implement your own. Poor uses a
spherical Mercator canvas with zoom levels matching the "slippy" format.
There is no projection done at the canvas level, so best results can be
achieved with small variations to that or different ways of referring to
the same tiles, e.g. inverse zoom level numbering. If you have a tile
source in a clearly different projection that would need rotation or
significant stretching of tiles to fit on the canvas, file a bug report
and maybe we can adjust.

The main job of the tile format implementation is to provide formulas to
convert between longitude/latitude coordinates and tile numbers, or keys
or whatever way tiles are referred to. You need to implement three
functions. `list_tiles` should given bounding box coordinates return a
list of dictionaries of tile properties, which will be used by Poor in
conjunction with the tile source metadata file to construct URLs and
download those tiles. `tile_corners` should return longitude/latitude
coordinates of each corner of the given tile. `tile_path` should return
the relative path used to store the tile in the user's local cache
directory `~/.cache/harbour-poor-maps/`.
