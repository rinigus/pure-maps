Implementing a Tile Source
==========================

To implement a tile source you need to write a JSON metadata file. Most
of the fields are self-explanatory, see the tile sources shipped with
Poor for examples; non-trivial and optional fields are explained below.

* **`format`**: Name of the tile format implementation. Two formats
  are supported: `mapbox` and `slippy`.

* **`type`**: Type of tiles: either "basemap" or "overlay". If omitted,
  the default "basemap" is assumed. Overlays are partly transparent
  tiles stacked on top of basemaps, e.g. hillshade or traffic.

* **`urlDebug`**: When set to `true`, all URLs are printed out in
  `stdout` before fetching them.

* **`urlSuffix`**: When set, this string will be appended to all URLs
  before fetching them online.

* **`z`**: The stacking order of the layer among overlay tiles. `z` is
  only used for tiles of type "overlay". Low z-values are placed at the
  bottom and high ones on top. Recommended values are 10 for areas, 20
  for lines and 30 for points. Valid values are from 0 to 40.

Use `~/.local/share/harbour-poor-maps/tilesources` as a local
installation directory in which to place your JSON file. Restart Poor,
and your tile source should be loaded, listed and available for use.

Mapbox Tile Format
==================

Mapbox tile format confirms to
[Mapbox Style Specification][stylespec]. Either `styleUrl` or
`styleJson` should be specified to load the style. Additional options
are:

* **`styleReferenceLayer`**: Layer that can be used to draw the route
  found for routing under. Default is "waterway-label" which
  fits Mapbox.com default styles.

* **`pixelRatio`**: Pixel ratio for specific style can be specified,
  but not recommended. In general, its useful to change pixel ratio
  for some styles that use raster tiles.

[stylespec]: https://www.mapbox.com/mapbox-gl-js/style-spec/


Slippy Tile Format
==================

By far the most common format, used among others by Google and
OpenStreetMap. Based on Spherical Mercator. See
[documentation][slippy]. The parameters `scale` and `url` are
required.

* **`scale`** Relative size of an edge of a tile when compared to
  256 pixels x 256 pixels tiles.

* **`url`** Required URL template with parameters `x`, `y` and `z`.

[slippy]: http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
