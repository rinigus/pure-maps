Implementing a Map Source
=========================

To implement a map source you need to write a JSON metadata file. Common
keys are explained below, format-specific keys in following sections.

* **`attribution`**: A string of plain text or HTML used to provide
  copyright and other information, usually as required by the terms of
  the provider.

* **`format`**: Either "mapbox-gl" or "slippy", see below.

* **`logo`**: Name of logo file found under `qml/icons/attribution` to
  display in the bottom left corner of the map. Optional, defaults to
  "default.svg".

* **`name`**: Name of the map source shown in listings.

Use `~/.local/share/harbour-whogo-maps/maps` as a local installation
directory in which to place your JSON file. Restart WhoGo maps, and your
map source should be loaded, listed and available for use.

## Mapbox GL Vector Map Format

Mapbox GL is a vector map format that follows the [Mapbox style
specification][mapbox-style]. It can be used by either providing the URL
to a JSON format specification, or by writing a specification into the
JSON metadata file itself.

* **`firstLabelLayer`**: Identifier of the lowest label layer in the
  style. Icons and route polylines are rendered right below this layer
  so that labels are not obscured and remain readable.

* **`styleJson`**: A full JSON format style specification.

* **`styleUrl`**: A URL to a full JSON format style specification.
  Supports regular HTTP etc. URLS as well as `mapbox://` URLs for
  Mapbox-hosted styles.

* **`urlSuffix`**: A suffix to add to all URL requests, including tiles,
  fonts, icons or whatever specified by the style. Usually used to
  provide an API key, token or some other identification.

[mapbox-style]: https://www.mapbox.com/mapbox-gl-js/style-spec/

## Slippy Raster Tile Format

Slippy is a raster tile format based on Spherical Mercator. It is used
by most global providers of raster tiles, e.g. Google and OpenStreetMap.
For documentation, see e.g. [OpenStreetMap Wiki][slippy].

* **`backgroundColor`**: Background color used behind actual tiles,
  visible before tiles are loaded. Optional, defaults to "#e6e6e6".
  Useful to change to a dark color for night styles.

* **`tileSize`**: The minimum visual size at which to display tiles.
  Note that this is not necessarily the pixel dimension of the actual
  tiles, try values 256, 512 and 1024 and use which one looks best.

* **`tileUrl`**: Tile URL template, containing variables `{x}`, `{y}`
  and `{z}` replaced with longitude tile number, latitude tile number
  and zoom level.

[slippy]: http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
