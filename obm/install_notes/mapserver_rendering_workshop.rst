Rendering OSM Data with Mapserver Guidelines
===============================================

**Goals**
________________
This guide will help us understand how to render OSM data with Mapserver.
 
Here is a glimpse of what a final mapserver-rendered product can look like (this interpretation was brought to us by the GIS rock stars Roger Andre and Thomas Bonfort):
http://www.openbasemap.org/seattle_osm.html

We will be starting with a bare-bones \ **.map** \file. This map file only renders a few layers such as borders, major highways and some landuse. Our goal will be to expand on this basic map file and create alternative renderings.

**Assumptions**
________________
This tutorial is meant for all but written in a way that might be biased. I'm working on Linux Ubuntu with the terminal text editor VIM. Therefore my text editing and directory commands might confuse you. Hopefully the directions give enough context that you can ignore the way I'm doing things and edit the text files and move through directories in your normal way. Though I do recommend learning VIM or emacs because they make text editing super duper fun and prepare you to work remotely!

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

0. Ground zero. \ **REVISE THIS LATER NOT SURE HOW TRUE** \You'll need a github account and your SSH keys setup. If you don't know how to do this, then ask me (or someone near you) for help. But first try these very well written URL resources that can help you do these first steps:
    
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

                STYLEh
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

The most important thing to note here is that we reference the mapfile of each layer with an \ **INCLUDE** \statement

**Example Rendering Workflow**
_________________________________

1. Assuming you've cloned the github repository, set your SSH keys properly (see step 0 and 1 in last section) and copied \ **templateDIR** \ as your own workspace (see step 4 in last section), then let's start by looking at what \ **mapserver_springfling.html** \looks like on the OpenBaseMap server. Point your browser at this URL:

    ``http://osm.openbasemap.org/mapservOSM/mapserver_springfling.html``

    This map represents how the default mapfiles in \ **templateDIR** \are rendering currently. Not for long ;) Let's change them!

2. Let's make an easy color edit to understand the git push and pull workflow. Then we'll move onto a more advanced revision. Open the \ **landuse.map** \file in your favorite text editor and replace all color attributes with the color black \ **#FFFFFF** \. In VIM you could do it in one fell swoop like this:

    ``:%s/COLOR.*$/COLOR "#FFFFFF"/g`` 


3. Save your changes to the mapfile. Now for the git magic:

    # Add or 'stage' your changes. Below I'm adding my edited \ **landuse.map** \file. Make sure to change \ **gc_mapfiles** \to your folder name. When staging changes \ ``git add`` \make sure you're only adding the things you've changed.
    ``$ git add gc_mapfiles/landuse.map``

    # Commit your changes and create a commit message with \ **-m** \switch.
    ``$ git commit -m "I changed everything back to BLACK!``
h
    # In the commit command \ **-m** \ is the shortform switch for \ *'message'* \. \ **ALSO NEVER RUN A GIT COMMIT COMMAND LIKE THIS:** \ ``git commit -a -m "blah blah"`` \until you know what you are doing. The \ **-a** \ switch is saying commit EVERYTHING in the current working space. You might commit changes you never wanted pushed. I would stay away from this for now.

    # Before you commited you can always view which files are untracked, modified or deleted using this shorthand git command:
    ``$ git status -s``

    # The output would look something like this assuming you've only changed the \ **landuse.map** \file and haven't commited yet. \ **M** means modified, \ **D** \ means deleted and \ **??** \means yo dude I'm not tracked yet:
    ``M landuse.map
    ?? fonts.lst
    ?? fonts/
    ?? main_osm.map
    ?? osm2.xml
    ?? roadsfar.map
    ?? shorelines.map``

    # Now for the fun part. Let's \ **push** \our changes back to the github repository:
    ``$ git push``

4. If you go to the following URL and refresh the page you should see the folder you created with your \ **landuse.map** \file in it.
    
    ``https://github.com/thebigspoon/mapservOSM``

5. We have one more change to make before we can pull the changes to the OpenBaseMap server and view them. Make a copy of \ **mapserver_springfling.html** \in the root directory and give it a name prefixed by your initials, similar to what you did in step 4 of previous section. I'm going to call mine \ **gc_mapserver_springfling.html** \.

    ``$ cp mapserver_springfling.html gc_mapserver_springfling.html``

6. Now open your \ **..springfling.html** \file in a text editor. Look for this line of javascript:

    ``.add(po.image().url('http://osm.openbasemap.org/cgi-bin/mapserv?map=mapservOSM/gc_mapfiles/main_osm.map&mode=tile&tile={X}+{Y}+{Z}'))``

7. You'll want to change the directory name in that line of code \ **gc_mapfiles** \to your mapfile directoy name. Make that edit and save the file. Or change the Title if you want something a little more personal.

8. Now follow all the git steps in \ **step 3** \ above to stage,commit and push only the newly edited \ **..springfling.html** \file. Here's mine::


        $ git add gc_mapserver_springfling.html
        $ git commit -m "Created my own pesonal mapserver_springfling page"
        [master 214f036] Created my own pesonal mapserver_springfling page
         1 files changed, 39 insertions(+), 0 deletions(-)
         create mode 100644 gc_mapserver_springfling.html
        $ git push
        Counting objects: 4, done.
        Delta compression using up to 8 threads.
        Compressing objects: 100% (3/3), done.
        Writing objects: 100% (3/3), 1014 bytes, done.
        Total 3 (delta 0), reused 0 (delta 0)
        To git@github.com:thebigspoon/mapservOSM.git
           71a2c87..214f036  master -> master
        $ 

9. Go to the github website in \ **step 4** \above to make sure the .html file appears. If you have username/password to the OpeBaseMap server then you'll want to ask me or someone else to teach you how to pull the changes down (it's not rocket science). If you don't have access to the server then ask me or someone else to do this for you.
         
10. After \ **step 9** \is completed you can view your changes by going to the URL below -- make sure you change \ **mapserver_springfling** \to reflect the name of your edited \ **...springfling.html** \file.
k
    ``http://osm.openbasemap.org/mapservOSM/gc_mapserver_springfling.html``

**Adding a New Layer to Landuse**
_____________________________________



