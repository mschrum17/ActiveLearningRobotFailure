C:
cd C:\Program Files\FlightGear 2018.2.2

SET FG_ROOT=C:\Program Files\FlightGear 2018.2.2\data
SET FG_SCENERY=C:\Program Files\FlightGear 2018.2.2\data\Scenery;C:\Program Files\FlightGear2018.2.2\data\WorldScenery
.\\bin\fgfs --aircraft=c172p --fdm=null --enable-auto-coordination --native-fdm=socket,in,30,localhost,5502,udp --fog-disable --enable-clouds3d --start-date-lat=2004:06:01:09:00:00 -- enable-sound --visibility=15000 --in-air --prop:/engines/engine0/running=true --disable-freeze --airport=KMIA --runway=06 --altitude=8000 --heading=0 --offset-distance=0 --offset-azimuth=0 --enable-rembrandt