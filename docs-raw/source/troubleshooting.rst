.. _troubleshooting:

Troubleshooting
===============

GPS
---
 Pure Maps does not get any location in linux.
   Make sure modem/gps is enabled, gnss-share and geoclue are running.
   If you use ModemManager 1.23.3 or lower, there must be a sim card present.
   postmarketOS users read: https://wiki.postmarketos.org/wiki/User:Magdesign#GPS
   
Map
---
 Pure Maps does not show city names in the default offline mode. 
  Edit:
  ``/usr/share/osmscout-server/styles/mapboxgl/styles/osmbright.json``
  change under ``id``: ``place-city``

.. code-block::

 "minzoom": 1,
 "maxzoom": 18,

this should show the city names in zoomlevel 14.49 to 18.
We also need to import other zoom levels 
see:

https://github.com/rinigus/osmscout-server/blob/master/scripts/import/mapbox/run_planetiler.sh

https://github.com/onthegomap/planetiler 

Thanks for any pull-request fixing this.
