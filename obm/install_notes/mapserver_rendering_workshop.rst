Rendering OSM Data with Mapserver Guidelines
===============================================

**Goals**
________________
This guide will help us understand how to render OSM data with Mapserver.
 
Here is a glimpse of what a final mapserver-rendered product can look like (this interpretation was brought to us by the GIS rock stars Roger Andre and Thomas Bonfort):
http://www.openbasemap.org/seattle_osm.html

We will be starting with a bare-bones \ **.map** \file. This map file only renders a few layers such as borders, major highways and some landuse. Our goal will be to expand on this basic map file and create alternative renderings.

**Toolbox**
______________
To help us along the way we might want to refer to these:

* mapnik osm2.xml \ **located in our github project folder** \.
* `Bonfert's mapserver-utils project <http://mapserver-utils.googlecode.com/svn/trunk/>`_.
* `Mapserver mapfile syntax documentation <http://mapserver.org/mapfile/index.html>`_.
* `Polymaps documentation <http://polymaps.org/>`_.
* Roger Andre's mapserver files located at \ ``/var/www/mapfiles/`` \on openbasemap server

**First Steps**
__________________________________________

0. Ground zero. You'll need a github account and your SSH keys setup. If you don't know how to do this, then ask me (or someone near you) for help. But first try these very well written URL resources that can help you do these first steps:
    
    Setting up a github account:

    ``http://help.github.com/linux-set-up-git/``

    Setting up your public/private keys. What do you know! The same tutorial covers both!
    
    ``http://help.github.com/linux-set-up-git/``

1. Clone the mapserver OSM workshop from github to your local machine::
    
     $ git clone git@github.com:thebigspoon/mapservOSM.git
     Initialized empty Git repository in /home/gcorradini/REPOS/GIT/mapservOSM/.git/
     remote: Counting objects: 22, done.
     remote: Compressing objects: 100% (22/22), done.
     remote: Total 22 (delta 1), reused 0 (delta 0)
     Receiving objects: 100% (22/22), 1.75 MiB | 1.03 MiB/s, done.
     Resolving deltas: 100% (1/1), dono

2. \ **cd** \into the mapservOSM directory

    ``$ cd mapservOSM``


3. Take a peek at the contents::

    $ ls -lah
    drwxr-xr-x 6 gcorradini gcorradini 4.0K 2011-04-18 21:49 .
    drwxr-xr-x 9 gcorradini gcorradini 4.0K 2011-04-18 21:48 ..
    drwxr-xr-x 8 gcorradini gcorradini 4.0K 2011-04-18 21:48 .git
    -rw-r--r-- 1 gcorradini gcorradini 1.3K 2011-04-18 21:48 mapserver_springfling.html
    drwxr-xr-x 3 gcorradini gcorradini 4.0K 2011-04-18 21:48 templateDIR

There should be 3 files.

    * The \ **.git** \repository is nothing we're going to touch, but it's where git stores all it's magic.
    * The \ **templateDIR** \ holds all our mapserver mapfiles used for rendering. There are also fonts in this directory.
    * Finally, \ **mapserver_springfling.html** is the bare-bones javascript and html for the slippy  map...we're going to be using Polymaps instead of OpenLayers.

4. Copy the \ **templateDIR** \within mapservOSM folder and give it a specific name such as \ **your initials + mapfiles** \. Mine will be \ **gc_mapfiles** \.::

    $ cp -r templateDIR gc_mapfiles

5. cd into the copied mapfile folder and take a peek at the contents::

    $ cd gc_mapfiles
    $ ls -lah
    drwxr-xr-x 3 gcorradini gcorradini 4.0K 2011-04-18 21:48 fonts
    -rw-r--r-- 1 gcorradini gcorradini  135 2011-04-18 21:48 fonts.lst
    -rw-r--r-- 1 gcorradini gcorradini 5.1K 2011-04-18 21:48 landuse.map
    -rw-r--r-- 1 gcorradini gcorradini  613 2011-04-18 21:48 main_osm.map
    -rw-r--r-- 1 gcorradini gcorradini 338K 2011-04-18 21:48 osm2.xml
    -rw-r--r-- 1 gcorradini gcorradini 1.7K 2011-04-18 21:48 roadsfar.map
    -rw-r--r-- 1 gcorradini gcorradini  906 2011-04-18 21:48 shorelines.map

There should be 7 files here.

    * The \ **fonts** \ files are self explanatory
    * osm2.xml is used by the renderer \ **mapnik** \to apply styles to OSM data. This is the official OSM renderer. It's helpful to see what that style sheet is querying on in the OSM database because, as you'll see, OSM data can be hairy to work with
    * Anything with the \ **.map** \extentsion is our mapserver files

6. Let's look quickly at two .map files so we understand what we're dealing with. Open \ **landuse.map** \in your favorite text editor::

        # landuse.map

        LAYER
            TYPE POLYGON
            STATUS DEFAULT
            PROJECTION
                "init=epsg:900913"
            END 
            NAME "landuse_layer1"
            GROUP "default"
            CONNECTIONTYPE POSTGIS
            CONNECTION "host=localhost dbname=planet0304 user=gcorradini"
            DATA "way from (select way,osm_id ,landuse, name from planet_osm_polygon where landuse is not null) as foo using unique osm_id using srid=900913"
            PROCESSING "CLOSE_CONNECTION=DEFER"
            CLASSITEM "landuse"
            MAXSCALEDENOM 1000010
            CLASS
                EXPRESSION ('[landuse]'='industrial' or '[landuse]'='commercial' or '[landuse]'='airport' or '[landuse]'='brownfield' or '[landuse]'='military' or '[landuse]'='railway')
                STYLE
                    COLOR "#EBE5D9"
                END 
             
            END 
            CLASS
                EXPRESSION ('[landuse]'='residential')
                STYLE
                    COLOR "#F6F1E6"
                END 
            END 
        END

You can see that this land use file only contains layers. Each layer has a number of key/value pairs that define it's properties. Take note of a few things:

    * Each layer has CONNECTION information about the OSM database
    * Each layer has it's own projection defined
    * The key \ **DATA** \holds our select statement for querying the OSM database
    * The key \ **EXPRESSION** \is our branching logic (think about it like a switch statement) that allows us to apply a particular style to a query value

7. So how do our layer .map files get into a map. Now take a look at \ **main_osm.map** \. This document contains our \ **MAP** \object and it's particular attributes::


        MAP
                NAME  'main_osm'
                EXTENT -13620844.349571 6049600.242247 -13611671.906179 6053680.068631 
                SIZE 800 600 
                IMAGECOLOR "#B3C6D4"
                PROJECTION
                    "init=epsg:900913"
                END 


                # MAP LAYERS
                INCLUDE 'shorelines.map'
                INCLUDE 'landuse.map'
                INCLUDE 'roadsfar.map'    
            
                # WEB PARAMETERS
                WEB 
                    IMAGEURL "/var/www/html/tmp"
                    IMAGEPATH "/tmp"
                END 

                OUTPUTFORMAT
                    NAME 'AGG'
                    DRIVER AGG/PNG
                    IMAGEMODE RGB 
                END 

                FONTSET 'fonts.lst'

        END

The most important thing to note here is that we reference the mapfile of each layer with an INCLUDE statement

**Example Rendering Workflow**
================================= 



:%s/COLOR.*$/#FFFFFF/gc 
