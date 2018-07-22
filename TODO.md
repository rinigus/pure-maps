WhoGo Maps 1.1
==============

* [x] Add autocomplete support to Digitransit geocoder (#2)
* [ ] Add autocomplete support to Foursquare venue types
    - Don't query autocompletions when search query hasn't changed
    - Don't filter autocompletions in QML
    - Disable history when autocomplete_type defined
    - Use unicodedata to remove accents, e.g. Café before matching?
    - Abstract out string matching done by autocomplete_type
* [x] Add OSM Scout car styles (#43)
* [x] Remove obsolete OSM Scount router module requirement (#45)
* [x] Fix tilt when navigating setting
