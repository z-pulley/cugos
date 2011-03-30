var po = org.polymaps;

var map = po.map()
    .container(document.getElementById("map").appendChild(po.svg("svg")))
    .add(po.interact())
    .add(po.hash());

map.add(po.image()
    .url(po.url("http://osm.openbasemap.org/osm_tiles2/{Z}/{X}/{Y}.png")));

map.add(po.compass()
    .pan("none"));
