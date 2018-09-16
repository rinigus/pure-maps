Pure Maps
==========

Pure Maps is a fork of [WhoGo Maps](https://github.com/otsaloma/whogo-maps) 
that was made to continue its development. Pure Maps is an application for 
Sailfish OS to display vector and raster maps, places, routes, and provide
navigation instructions with a flexible selection of data and service
providers.

Pure Maps is free software released under the GNU General Public License
(GPL), see the file [`COPYING`](COPYING) for details.

For testing purposes you can just run `qmlscene qml/pure-maps.qml`. For
installation, you can build the RPM package with command `make rpm`. You
don't need an SDK to build the RPM, only basic tools: `make`,
`rpmbuild`, `gettext` and `qttools`. 

For building RPMs, please copy `tools/apikeys_dummy.py` to `tools/apikeys.py`
and fill missing API keys for the services that you plan to use.
