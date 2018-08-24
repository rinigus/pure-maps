Implementing a Map Source
=========================

To implement a map source you need to write a JSON metadata file. Common
keys are explained below, format-specific keys in following sections.

* **`attribution`**: Key-value pairs of attribution text and URL.

* **`format`**: Either "mapbox-gl" or "slippy", see below.

* **`logo`**: Name of logo file found under `qml/icons/attribution` to
  display in a corner of the map. Optional, defaults to "default.svg".

* **`name`**: Name of the map source shown in listings.

* **`style_gui`**: JSON object that can be used to alter GUI elements
 in agreement with the used map style. For example, see OSM Scout
 night styles. For the list of available keys and their meaning, see
 `qml/Styler.qml`.

Use `~/.local/share/harbour-pure-maps/maps` as a local installation
directory in which to place your JSON file. Restart Pure Maps, and your
map source should be loaded, listed and available for use.

## Mapbox GL Vector Map Format

Mapbox GL is a vector map format that follows the [Mapbox style
specification][mapbox-style]. It can be used by either providing the URL
to a JSON format style definition, or by writing the style definition
into the JSON metadata file itself.

* **`first_label_layer`**: Identifier of the lowest label layer in the
  style. Icons and route polylines might rendered right below this layer
  so that labels are not obscured and remain readable.

* **`style_json`**: A full JSON format style definition.

* **`style_url`**: A URL to a full JSON format style definition.
  Supports regular HTTP etc. URLs as well as `mapbox://` URLs for
  Mapbox.com-hosted styles.

* **`url_suffix`**: A suffix to add to all URL requests, including
  tiles, fonts, icons or whatever specified by the style. Usually used
  to provide an API key, token or some other identification.

[mapbox-style]: https://www.mapbox.com/mapbox-gl-js/style-spec/

## Slippy Raster Tile Format

Slippy is a raster tile format based on Spherical Mercator. It is used
by most global providers of raster tiles, such as Google and
OpenStreetMap. For documentation, see e.g. [OpenStreetMap Wiki][slippy].

* **`background_color`**: Background color used behind actual tiles,
  visible before tiles are loaded. Optional, defaults to "#e6e6e6".
  Useful to change to a dark color for night styles.

* **`tile_size`**: The minimum visual size at which to display tiles.
  Note that this is not necessarily the pixel dimension of the actual
  tiles, try values 256, 512 and 1024 and use which one looks best.

* **`tile_url`**: Tile URL template, containing variables `{x}`, `{y}`
  and `{z}` replaced with longitude tile number, latitude tile number
  and zoom level.

[slippy]: http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
