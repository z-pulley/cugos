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

    http://osm.openbasemap.org/mapservOSM/mapserver_springfling.html

    This map represents how the default mapfiles in \ **templateDIR** \are rendering currently. Not for long. Let's change that.

2. Let's make a color edit to understand the git push and pull workflow. Then we'll move onto a more advanced revision. Open the \ **landuse.map** \file in your favorite text editor and replace all color attributes with the color black \ **#000000** \. In VIM you could do it in one fell swoop like this:

    ``:%s/COLOR.*$/COLOR "#000000"/g`` 


3. Save your changes to the mapfile. Now we'll turn to git:

    # Before staging and commiting your changes you can always view which files are untracked, modified or deleted using this shorthand git command:

    ``$ git status -s``

    # The output would look something like this assuming you've only changed the \ **landuse.map** \file and haven't added or committed yet. \ **M** means modified, \ **D** \ means deleted, \ **A** means added and \ **??** \means a file is not tracked yet:

    ``M landuse.map
    ?? fonts.lst
    ?? fonts/
    ?? main_osm.map
    ?? osm2.xml
    ?? roadsfar.map
    ?? shorelines.map``

    # Add or 'stage' the files you've changed. Below I'm staging my whole workspace folder. Make sure to change \ **gc_mapfiles** \to your folder name.

    ``$ git add gc_mapfiles/``

    # Commit your changes and create a commit message with \ **-m** \switch.

    ``$ git commit -m "I changed everything back to BLACK!``

    # Before you push your changes make sure you do a \ **pull** \to get the most recent changes from others. If you get a conflict error, well, start Googling solutions
    ``$ git pull``

    # \ **TIP > NEVER RUN A GIT COMMIT COMMAND LIKE THIS:** \ ``git commit -a -m "blah blah"`` \until you know what you are doing. The \ **-a** \ switch is saying commit EVERYTHING in the current working space. You might commit changes you never wanted pushed. Stay away from this for now.

    # Now for the fun part. Let's \ **push** \our changes back to the github repository:

    ``$ git push``

4. If you go to the following URL and refresh the page you should see the folder you created with your \ **landuse.map** \file in it.
    
    https://github.com/thebigspoon/mapservOSM

5. We have one more change to make before we can pull the changes to the OpenBaseMap server and view them. Make a copy of \ **mapserver_springfling.html** \in the root directory and give it a name prefixed by your initials, similar to what you did in step 4 of previous section. I'm going to call mine \ **gc_mapserver_springfling.html** \.

    ``$ cp mapserver_springfling.html gc_mapserver_springfling.html``

6. Now open your \ **..springfling.html** \file in a text editor. Look for this line of javascript:

    ``.add(po.image().url('http://osm.openbasemap.org/cgi-bin/mapserv?map=mapservOSM/gc_mapfiles/main_osm.map&mode=tile&tile={X}+{Y}+{Z}'))``

7. You'll want to change the directory name in that line of code \ **gc_mapfiles** \to your mapfile directoy name. Make that edit and save the file. Or change the <Title> if you want something a little more personal.

8. Now follow all the git steps in \ **step 3** \ above to stage,commit and push only the newly edited \ **..springfling.html** \file. Here's mine::


        $ git add gc_mapserver_springfling.html
        $ git commit -m "Created my own pesonal mapserver_springfling page"
        [master 214f036] Created my own pesonal mapserver_springfling page
         1 files changed, 39 insertions(+), 0 deletions(-)
         create mode 100644 gc_mapserver_springfling.html
        $ git push
        Counting objects: 4, done.
        Delta compression using up to 8 threads.F
        Compressing objects: 100% (3/3), done.
        Writing objects: 100% (3/3), 1014 bytes, done.
        Total 3 (delta 0), reused 0 (delta 0)
        To git@github.com:thebigspoon/mapservOSM.git
           71a2c87..214f036  master -> master
        $ 

9. Go to the github website in \ **step 4** \above to make sure the .html file appears. If you have username/password to the OpeBaseMap server then you'll want to ask me or someone else to teach you how to pull the changes down (it's not rocket science). If you don't have access to the server then ask me or someone else to do this for you.
         
10. After \ **step 9** \is completed you can view your changes by going to the URL below -- make sure you change \ **gc_mapserver_springfling** \to reflect the name of your edited \ **...springfling.html** \file.

    http://osm.openbasemap.org/mapservOSM/gc_mapserver_springfling.html

**Adding a New Layer to Landuse**
_____________________________________

1. Let's say we really wanted to add a buildings layer to the mapserver files. How would we go about investigating that?. The first step (always the first step for me at least) is to go straight to the official renderer \ **mapnik's** \osm2.xml stylesheet. Open the osm2.xml in a text editor.


2. We are using osm2.xml to basically lookup what database column names would be mapped to an attribute like 'buildings'. There could be many as we'll see and the queries could range in complexity. In the osm2.xml stylesheet do a search for "building" or variations of the word. In VIM we would do something like this using regexs:

    ``/.*building.*``

3. I don't know about you, but I found a few. For the purposes of this section I'm going to stick with the layer descripton on \ **lines 4722-4810** \. It looks like we're going to target mostly residential buildngs here::

        <!-- Render the other building types. Some sql filtering is needed to exclude
             any type not already specifically rendered in buildings-lz. -->
        <Layer name="buildings" status="on" srs="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs +over">
            <StyleName>buildings</StyleName>
            <Datasource>
              <Parameter name="table">
              (select way,aeroway,
                case
                 when building in ('residential','house','garage','garages') then 'INT-light'::text
                 else building
                end as building
               from planet_osm_polygon
               where (building is not null
                 and building not in ('no','station','supermarket')
                 and (railway is null or railway != 'station')
                 and (amenity is null or amenity != 'place_of_worship'))
                  or aeroway = 'terminal'
               order by z_order,way_area desc) as buildings
              </Parameter>
              <!--
        Settings for your postgres setup.

        Note: feel free to leave password, host, port, or use blank
        -->

        <Parameter name="type">postgis</Parameter>
        <Parameter name="password">gis</Parameter>
        <Parameter name="host">localhost</Parameter>
        <Parameter name="port">5432</Parameter>
        <Parameter name="user">cugos</Parameter>
        <Parameter name="dbname">planet0304</Parameter>
        <!-- this should be 'false' if you are manually providing the 'extent' -->
        <Parameter name="estimate_extent">false</Parameter>
        <!-- manually provided extent in epsg 900913 for whole globe -->
        <!-- providing this speeds up Mapnik database queries -->
        <Parameter name="extent">-20037508,-19929239,20037508,19929239</Parameter>

            </Datasource>
        </Layer>

4. Next I'm going to copy an existing mapfile layer from my project and do some cutting and pasting. Let's make a copy of \ **landuse.map** \ and call it \ **res_buildings.map** \. 

    ``$ cp landuse.map res_buildings.map``

5. Now delete everything but the first \ **LAYER** \object so your \ **res_buildings.map** \file looks like this::

        # res_buildings.map

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


6. The next steps are straightfoward. Let's scan the \ **LAYER** \object attributes top-down and look for things we're going to have to change to accommodate our new layer.
    
7. It looks like we're going to make edits to the \ **NAME, DATA, CLASSITEM, MAXSCALEDENOM AND CLASS** \attributes. Some of these are going to be easy while others, namely \ **DATA, CLASS** \attributes are going to be harder. 

8. Change the \ **NAME, MAXSCALEDENOM** \attributes to look like this::

    NAME "res_buildings"
    ...
    MAXSCALEDENOM 70000

9. Delete all \ **EXPRESSION** \ variables from the \ **CLASS** \attributes so they look like this:

10.  

    
