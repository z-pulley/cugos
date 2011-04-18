Rendering OSM Data with Mapserver Guidelines
===============================================

**Goals**
________________
This guide will help us understand how to render OSM data with Mapserver.

Here is a glimpse of what a final mapserver-rendered product can look like (this interpretation was brought to us by the GIS rock star Roger Andre):
http://www.openbasemap.org/seattle_osm.html

We will be starting with a bare-bones .map file. This map file only renders a few map layers such as borders, major highways and some landuse. Our goal will be to expand on this basic map file and create alternative renderings.

**Toolbox**
______________
To begin we will need to know 

* mapnik osm2.xml\ *located in the project folder* \.
* Roger Andre's mapserver files located at ``/var/www`` on openbasemap server
* `Bonfer's mapserver-utils project <http://mapserver-utils.googlecode.com/svn/trunk/>`_.
* `Mapserver mapfile syntax documentation <http://mapserver.org/mapfile/index.html>`_.




