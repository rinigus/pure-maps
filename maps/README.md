Implementing a Map Source
=========================

To implement a map source you need to write a JSON metadata file. Common
keys are explained below, format-specific keys in following sections.

* **`attribution`**: Key-value pairs of attribution text and URL.

* **`format`**: Either "mapbox-gl" or "raster", see below.

* **`keys`**: List of API keys that are managed through
  `poor/keystore.py`. See HERE map layers for example of its use.
  
* **`lang`**: Optionally provide a language this map has been designed
  for. Language is one of: local, en, fr, de, ru. Alternatively,
  `lang` could be filled with a dictionary with the keys specifying a
  language and the values specifying some style-specific strings that
  will be used to replace `lang_key` in `tile_url` (raster tiles) or
  in vector style description.
  
* **`lang_key`**: If the map style `lang` is given by dictionary,
  specify which string is expected to be replaced in style or
  `tile_url`. See HERE maps sources for example.
  
* **`light`**: whether the map corresponds to `day` or `night` light
  scheme.

* **`logo`**: Name of logo file found under `qml/icons/attribution` to
  display in a corner of the map. Optional, defaults to "default.svg".

* **`name`**: Name of the map source shown in listings.

* **`profiles`**: List of profiles at which the map source should
  appear. Currently supported profiles are "offline", "online" and
  "mixed". For profiles that use some online server to pull the tiles
  from, it is recommended to set this property to `["mixed", "online"]`.
  
* **`provider`**: Maps from the same provider can be grouped
  together. For that, specify the same `provider` for all the maps.

* **`style_gui`**: JSON object that can be used to alter GUI elements
 in agreement with the used map style. For example, see OSM Scout
 night styles. For the list of available keys and their meaning, see
 `qml/Styler.qml`.
 
* **`type`**: maps under the same `provider` should specify their type
  as one from the following list: default, terrain, satellite, hybrid,
  preview, traffic, guidance. Traffic should be used if it is intended for
  preview of the road and contains traffic information.
  
* **`vehicle`**: optionally provide a transportations mode that this
  map has been designed for. Use on of: car, foot, bicycle, transit.

Use `~/.local/share/harbour-pure-maps/maps` as a local installation
directory in which to place your JSON file. Restart Pure Maps, and your
map source should be loaded, listed and available for use.

## Mapbox GL Vector Map Format

Mapbox GL is a vector map format that follows the [Mapbox style
specification][mapbox-style]. It can be used by either providing the URL
to a JSON format style definition, or by writing the style definition
into the JSON metadata file itself.

* **`first_label_layer`**: Identifier of the lowest label layer in the
  style. Icons and route polyline outlines will be rendered right below this layer
  so that labels are not obscured and remain readable.

* **`first_route_layer`**: Identifier of the layer in the
  style below which the route will be rendered. If not specified, it is
  assumed to be the same as `first_label_layer`. Is used in practice to avoid
  overlaying traffic information.

* **`style_json`**: A full JSON format style definition.

* **`style_url`**: A URL to a full JSON format style definition.
  Supports regular HTTP etc. URLs as well as `mapbox://` URLs for
  Mapbox.com-hosted styles.

* **`url_suffix`**: A suffix to add to all URL requests, including
  tiles, fonts, icons or whatever specified by the style. Usually used
  to provide an API key, token or some other identification.

* **`fingerprint`**: A dictionary consisting of keys and the values
  uniquely identifying the style. For example, `{ "id": "streets-v10" }`.
  This is used when generating language-specific version of the
  style by Pure Maps by replacing labels.

[mapbox-style]: https://www.mapbox.com/mapbox-gl-js/style-spec/

## Slippy Raster Tile Format

Raster is a raster tile format based on Spherical Mercator. It is used
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
