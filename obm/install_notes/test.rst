mod_tile with renderd setup
===========================

# Description

These instructions are designed to guide a user through
the installation of the mod\_tile appache module using
renderd as a rendering backend.

# Prerequisites/Assumptions

*    PostGIS database loaded using osm2pgsql.
*    Apache2 Install
*    Mapnik2. _NOTE:_ Mapnik 0.7.x can be used,
     but for the purposes of this guide we will
     assume a mapnik2 install from source.
*    cascadenik.
*    mod\_tile will run under the cugos group

# TODO/Questions

*    _Question:_ What is a practical way to start the renderd
     daemon upon system boot? Need new user?
*    _Temporary Answer:_ Use update-rc.d
*    Review mod\_tile config files.
*    Configure tile expiration.

# Install

Grab mod\_tile source:

    $ svn co http://svn.openstreetmap.org/applications/utils/mod_tile/
    $ cd mod_tile/

## Modify Makefile for Mapnik2

    $ vim Makefile
    54 -RENDER_LDFLAGS += -lmapnik -Liniparser3.0b -liniparser
    54 +RENDER_LDFLAGS += -lmapnik2 -Liniparser3.0b -liniparser

## Update render_config.h

In render\_config.h, we will change paths to point to
mapnik2's fonts and plugins directories. These will vary
based on install and hardware (e.g. x86/64-bit). Both directories
should share the same parent, so we can search for mapnik2's
font directory and infer the location of the plugin directory.

    $ python -c "import mapnik2; print mapnik2.fontscollectionpath"
    >>> /usr/local/lib/mapnik2/fonts

Check for the presence of the plugins directory:

    $ /usr/local/lib/mapnik2/input
    >>> -bash /usr/local/lib/mapnik2/input/: is a directory

Update paths in render\_config.h:

    $ vim render_config.h
    11 -#define HASH_PATH "/var/lib/mod_tile"
    11 +#define HASH_PATH "/mnt/z-raid6/projects/cugos/osm/tiles/"
    34 -#define MAPNIK_PLUGINS "/usr/local/lib64/mapnik/input"
    34 +#define MAPNIK_PLUGINS "/usr/local/lib/mapnik2/input"
    37 -#define FONT_DIR "/usr/local/lib64/mapnik/fonts"
    37 +#define FONT_DIR "/usr/local/lib/mapnik2/fonts"

_TODO:_ Review other flags in in render\_config.h:

## Make, install, and verify mod_tile:

    $ sudo make
    $ sudo make install
    $ ls /usr/lib/apache2/modules/mod_tile.so
    >>> /usr/lib/apache2/modules/mod_tile.so

# Virtual Host

Setup Apache Virtual Host. mod\_tile ships with a vanilla
'.conf' file. This file will be altered for the osm.openbasemap.org
subdomain.

    $ cp /usr/local/src/mod_tile/mod_tile.conf /mnt/z-raid6/projects/cugos/conf/mod_tile.conf

_TODO:_ Already modified '~/cugos/conf/mod\_tile.conf' need to document those changes and push to raid

# Stylesheet Setup

## Download and Prepare Shapefiles

_NOTE:_ Ripped from springmeyer: [DBSGEO FOSS4G 2010 OSM Rendering Workshop](http://dbsgeo.com/foss4g2010/html/getting_stylish.html)

Download the prerequisite shapefiles for rendering osm locally:

    $ cd /mnt/z-raid6/gis/osm
    $ mkdir shapefiles
    $ cd shapefiles
    $ wget http://tile.openstreetmap.org/world_boundaries-spherical.tgz # (50M)
    $ wget http://tile.openstreetmap.org/processed_p.tar.bz2 # (227M)
    $ wget http://tile.openstreetmap.org/shoreline_300.tar.bz2 # (46M)
    $ wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/10m-populated-places.zip # (1.5 MB)
    $ wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/110m-admin-0-boundary-lines.zip # (38 KB)

Unzip shapefiles:

    $ tar xzf world_boundaries-spherical.tgz # creates a 'world_boundaries' folder which the styles need
    $ tar xjf processed_p.tar.bz2 -C world_boundaries
    $ tar xjf shoreline_300.tar.bz2 -C world_boundaries
    $ unzip -q 10m-populated-places.zip -d world_boundaries
    $ unzip -q 110m-admin-0-boundary-lines.zip -d world_boundaries

Index Shapefiles:

    $ cd world_boundaries
    $ shapeindex processed_p
    $ shapeindex builtup_area
    $ shapeindex shoreline_300
    $ shapeindex 10m_populated_places
    $ shapeindex 110m_admin_0_boundary_lines_land

## Setup Arial Font

Arial is a prequisite font for the osm-bright stylesheet.
Check if Arial Font is installed. Running the command below
will list all fonts registered with mapnik2. If Arial Regular
or Arial Bold are not installed, download them:

    $ python -c "from mapnik2 import FontEngine as e; print '\n'.join(e.instance().face_names())"

Grab the msttcorefonts package:

_NOTE:_ There is a debian package available [here](http://packages.debian.org/squeeze/msttcorefonts).
I took the lazy route and grabbed them from the HOT Kiosk Mapping
github repo, [here](https://github.com/hotosm/styles).

Copy the fonts to mapnik2's font directory and verify
that Arial is registered with mapnik2:

    $ cd /path/to/hot-kiosk/kiosk/osm-bright/fonts
    $ sudo cp -r *.ttf /usr/local/lib/mapnik2/fonts/
    $  python -c "from mapnik2 import FontEngine as e; print '\n'.join(e.instance().face_names())"

## Download OSM-Bright Style

Download the osm-bright github repo:

    $ cd /mnt/z-raid6/gis/osm
    $ mkdir stylesheet
    $ cd stylesheet
    $ git clone git://github.com/developmentseed/osm-bright.git

## Modify osm-bright.mml

Before converting the osm-bright.mml file to a mapnik2 xml file,
we need to modify it to point towards the database:

    $ cd osm-bright/
    $ vim osm-bright.mml
    58 -<Parameter name='base'>osm_shapefiles_dir</Parameter>
    58 +<Parameter name='base'>/mnt/z-raid6/gis/osm/shapefiles/world_boundaries/</Parameter>
    65 -<Parameter name="dbname">osm_ontario</Parameter>
    65 +<Parameter name="dbname">planet0304</Parameter>
    66 -<Parameter name="user">gis</Parameter>
    66 +<Parameter name="user">cugos</Parameter>
    67 -<Parameter name="password">gis</Parameter>
    67 +<Parameter name="password"></Parameter> 

## Compile osm-bright.mml

    $ cascadenik-compile.py osm-bright.mml osm-bright_mapnik2.xml

# Modify /etc/renderd.conf

    $ sudo vim /etc/renderd.conf
    5 -stats_file=
    5 +state_file=/mnt/z-raid6/projects/cugos/logs/osm.renderd.stats
    8 -plugins_dir=/usr/local/lib64/mapnik/input
    8 +plugins_dir=/usr/local/lib/mapnik2/input
    9 -font_dir=/usr/local/lib64/mapnik/fonts
    9 +font_dir=/usr/local/lib/mapnik2/fonts
    13 -URI=/osm_tiles2/
    13 +URI=/tiles/
    14 -XML=/home/jburgess/osm/svn.openstreetmap.org/applications/rendering/mapnik/osm-local.xml
    14 +XML=/mnt/z-raid6/gis/osm/stylesheet/osm-bright/osm-bright_mapnik2.xml
    15 -HOST=tile.openstreetmap.org
    15 +HOST=osm.openbasemap.org

# Setup renderd to run at boot

    $ sudo cp /usr/local/src/mod_tile/renderd /etc/init.d/renderd
    $ sudo update-rc.d renderd defaults
