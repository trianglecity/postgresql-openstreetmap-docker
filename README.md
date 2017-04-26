
##
## Postgresql & OpenStreetMap using postgis and pgrouting
##


Reference 1: http://learnosm.org/en/osm-data/osm2pgsql/

Reference 2: https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/#communication-across-links

Reference 3: https://live.osgeo.org/en/quickstart/pgrouting_quickstart.html


NOTICE 1: faroe-islands-latest.osm is from http://download.geofabrik.de/europe/faroe-islands.html

NOTICE 2: two terminals are used for the example.

NOIICE 3: password for the examples is "password" (check out init-user-db.sh for details).


Please follow the instructions below to run the osm-postgres and pgr_dijkstra examples.


[1] git clone this source-code-folder

[2] open a terminal

[3 terminal-1] cd downloaded-source-code-folder

[4 terminal-1] sudo docker build -t postgresql_osm-dev:01 .

[5 terminal-1] sudo docker run --name pgs_osm -e POSTGRES_PASSWORD=pgspassword -d postgresql_osm-dev:01

[6] open another terminal

[7 terminal-2] sudo docker run -it --rm --link pgs_osm:alias postgresql_osm-dev:01 bash 

[8 terminal-2] root@e365033757af:/# osm2pgsql -c -d docker -U docker -W  -H alias  -S /tmp/default.style /tmp/faroe-islands-latest.osm
	
	osm2pgsql SVN version 0.86.0 (64bit id space)

	Password: password (check out init-user-db.sh)

	Using projection SRS 900913 (Spherical Mercator)
	Setting up table: planet_osm_point
	NOTICE:  table "planet_osm_point" does not exist, skipping
	NOTICE:  table "planet_osm_point_tmp" does not exist, skipping
	Setting up table: planet_osm_line
	NOTICE:  table "planet_osm_line" does not exist, skipping
	NOTICE:  table "planet_osm_line_tmp" does not exist, skipping
	Setting up table: planet_osm_polygon
	NOTICE:  table "planet_osm_polygon" does not exist, skipping
	NOTICE:  table "planet_osm_polygon_tmp" does not exist, skipping
	Setting up table: planet_osm_roads
	NOTICE:  table "planet_osm_roads" does not exist, skipping
	NOTICE:  table "planet_osm_roads_tmp" does not exist, skipping
	Using built-in tag processing pipeline
	Allocating memory for dense node cache
	Allocating dense node cache in one big chunk
	Allocating memory for sparse node cache
	Sharing dense sparse
	Node-cache: cache=800MB, maxblocks=102400*8192, allocation method=3
	Mid: Ram, scale=100

	Reading in file: /tmp/faroe-islands-latest.osm
	Processing: Node(112k 112.8k/s) Way(7k 7.93k/s) Relation(155 155.00/s)  parse time: 2s

	Node stats: total(112825), max(4795639206) in 1s
	Way stats: total(7929), max(487043394) in 1s
	Relation stats: total(155), max(6361182) in 0s
	Committing transaction for planet_osm_point
	Committing transaction for planet_osm_line
	Committing transaction for planet_osm_polygon
	Committing transaction for planet_osm_roads

	Writing way (7k)
	Committing transaction for planet_osm_point
	Committing transaction for planet_osm_line
	Committing transaction for planet_osm_polygon
	Committing transaction for planet_osm_roads

	Writing relation (155)
	Sorting data and creating indexes for planet_osm_point
	node cache: stored: 112825(100.00%), storage efficiency: 52.37% (dense blocks: 31, sparse nodes: 91854), hit rate: 100.00%
	Sorting data and creating indexes for planet_osm_line
	Sorting data and creating indexes for planet_osm_polygon
	Sorting data and creating indexes for planet_osm_roads
	Analyzing planet_osm_roads finished
	Analyzing planet_osm_line finished
	Analyzing planet_osm_polygon finished
	Analyzing planet_osm_point finished
	Copying planet_osm_roads to cluster by geometry finished
	Creating geometry index on  planet_osm_roads
	Creating indexes on  planet_osm_roads finished
	All indexes on  planet_osm_roads created  in 1s
	Completed planet_osm_roads
	Copying planet_osm_point to cluster by geometry finished
	Creating geometry index on  planet_osm_point
	Copying planet_osm_line to cluster by geometry finished
	Creating geometry index on  planet_osm_line
	Copying planet_osm_polygon to cluster by geometry finished
	Creating geometry index on  planet_osm_polygon
	Creating indexes on  planet_osm_line finished
	Creating indexes on  planet_osm_polygon finished
	All indexes on  planet_osm_line created  in 1s
	Completed planet_osm_line
	All indexes on  planet_osm_polygon created  in 1s
	Completed planet_osm_polygon
	Creating indexes on  planet_osm_point finished
	All indexes on  planet_osm_point created  in 1s
	Completed planet_osm_point

	Osm2pgsql took 5s overall
	

[9 terminal-2] root@e365033757af:/# psql -h alias -U docker

	Password for user docker: password (check out init-user-db.sh)
	psql (9.6.2)
	Type "help" for help.


[10] docker=> select * from geometry_columns;


	f_table_catalog | f_table_schema |    f_table_name    | f_geometry_column | coord_dimension |  srid  |    type
	-----------------+----------------+--------------------+-------------------+-----------------+--------+------------
	 docker          | public         | planet_osm_roads   | way               |               2 | 900913 | LINESTRING
	 docker          | public         | planet_osm_line    | way               |               2 | 900913 | LINESTRING
	 docker          | public         | planet_osm_polygon | way               |               2 | 900913 | GEOMETRY
	 docker          | public         | planet_osm_point   | way               |               2 | 900913 | POINT
	(4 rows)


[11] docker=> SELECT osm_id, ST_AsText(way) , ST_X(way), ST_Y(way), service FROM planet_osm_point WHERE (ST_Y(ST_Transform(way,4326)) > 62.1899 AND ST_Y(ST_Transform(way,4326)) < 62.1915) AND (ST_X(ST_Transform(way,4326)) > -7.0319 AND ST_X(ST_Transform(way,4326)) < -7.0274);

	  osm_id   |          st_astext           |    st_x    |    st_y    | service 
	-----------+------------------------------+------------+------------+---------
	 444662652 | POINT(-782779.96 8904664.22) | -782779.96 | 8904664.22 | 
	 444662502 | POINT(-782727.43 8904658.57) | -782727.43 | 8904658.57 | 
	 444662757 | POINT(-782720.01 8904626.47) | -782720.01 | 8904626.47 | 
	 444662512 | POINT(-782707.57 8904685.15) | -782707.57 | 8904685.15 | 
	 444662756 | POINT(-782694.07 8904612.39) | -782694.07 | 8904612.39 | 
	 444662501 | POINT(-782663.65 8904650.12) | -782663.65 | 8904650.12 | 
	 444662743 | POINT(-782662.04 8904606.17) | -782662.04 | 8904606.17 | 
	 444662500 | POINT(-782637.6 8904640)     |  -782637.6 |    8904640 | 
	 444662742 | POINT(-782633.65 8904603.83) | -782633.65 | 8904603.83 | 
	 444662744 | POINT(-782583.18 8904613.54) | -782583.18 | 8904613.54 | 
	 444662745 | POINT(-782548.03 8904617.5)  | -782548.03 |  8904617.5 | 
	 444662747 | POINT(-782505.75 8904579.47) | -782505.75 | 8904579.47 | 
	 444662772 | POINT(-782490.76 8904498.96) | -782490.76 | 8904498.96 | 
	 444662746 | POINT(-782471.46 8904573.91) | -782471.46 | 8904573.91 | 
	 772406879 | POINT(-782436.31 8904647.66) | -782436.31 | 8904647.66 | 
	 444662749 | POINT(-782425.65 8904572)    | -782425.65 |    8904572 | 
	 444662530 | POINT(-782403.98 8904658.88) | -782403.98 | 8904658.88 | 
	 444662748 | POINT(-782386.03 8904569.3)  | -782386.03 |  8904569.3 | 
	 444662548 | POINT(-782357.56 8904678.97) | -782357.56 | 8904678.97 | 
	 444662766 | POINT(-782312.02 8904564.77) | -782312.02 | 8904564.77 | 
	(20 rows)


[12]   docker=> \q
	
	
[13 pgrouting]   root@e365033757af:/# osm2pgrouting --f /tmp/faroe-islands-latest.osm --conf /usr/share/osm2pgrouting/mapconfig.xml -h alias -W password --dbname pgrouting --username pgrouting --clean
	
	
	Execution starts at: Tue Apr 25 23:20:41 2017
	
	***************************************************
	           COMMAND LINE CONFIGURATION             *
	***************************************************
	Filename = /tmp/faroe-islands-latest.osm
	Configuration file = /usr/share/osm2pgrouting/mapconfig.xml
	host = alias
	port = 5432
	dbname = pgrouting
	username = pgrouting
	password = password
	schema= 
	prefix = 
	suffix = 
	Drop tables
	Don't add nodes
	***************************************************
	Connecting to the database
	host=alias user=pgrouting dbname=pgrouting port=5432 password=password
	connection success
	Opening configuration file: /usr/share/osm2pgrouting/mapconfig.xml
	    Parsing configuration

	    Parsing data (progress line per 100000 elements)
	
	[*************|            ] (27%) Total osm elements parsed: 527000    Finish Parsing data
	
	
	Dropping tables...
	NOTICE:  table "ways" does not exist, skipping
	NOTICE:  table "ways_vertices_pgr" does not exist, skipping
	NOTICE:  table "relations_ways" does not exist, skipping
	
	Creating tables...
	Creating 'ways_vertices_pgr': OK
	   Adding Geometry: Creating 'ways': OK
	   Adding Geometry: Creating 'relations_ways': OK
	Creating 'osm_nodes': OK
	   Adding Geometry: Creating 'osm_relations': OK
	Creating 'osm_way_types': OK
	Creating 'osm_way_classes': OK
	Adding auxiliary tables to database...
	
	Export Types ...
	    Processing 4 way types: 	 Inserted: 4 in osm_way_types
	
	Export Classes ...
	    Processing way's classes: 	 Inserted: 36 in osm_way_classes
	
	Export Relations ...
	    Processing 0 relations:	Inserted: 0 in osm_relations
	
	Export RelationsWays ...
	    Processing way's relations: 	 Inserted: 0 in relations_ways
	
	Export Ways ...
	    Processing 7929 ways:
	[*************************************************| ] (98%)    Ways Processed: 7929	    Split Ways generated: 7030	Vertices inserted 6061 Inserted 7030 split ways
	Creating Foreign Keys ...
	Foreign keys for osm_way_classes table created
	Foreign keys for relations_ways table created
	Foreign keys for Ways table created
	#########################
	size of streets: 7929
	Execution started at: Tue Apr 25 23:20:41 2017
	Execution ended at:   Tue Apr 25 23:20:46 2017
	Elapsed time: 4.791 Seconds.
	User CPU time: -> 2.36685 seconds
	#########################


[14] root@e365033757af:/# psql -h alias -U pgrouting pgrouting

[15] pgrouting=> \d

	                    List of relations
	 Schema |           Name           |   Type   |   Owner
	--------+--------------------------+----------+-----------
	 public | geography_columns        | view     | postgres
	 public | geometry_columns         | view     | postgres
	 public | osm_nodes                | table    | pgrouting
	 public | osm_nodes_node_id_seq    | sequence | pgrouting
	 public | osm_relations            | table    | pgrouting
	 public | osm_way_classes          | table    | pgrouting
	 public | osm_way_types            | table    | pgrouting
	 public | raster_columns           | view     | postgres
	 public | raster_overviews         | view     | postgres
	 public | relations_ways           | table    | pgrouting
	 public | spatial_ref_sys          | table    | postgres
	 public | ways                     | table    | pgrouting
	 public | ways_gid_seq             | sequence | pgrouting
	 public | ways_vertices_pgr        | table    | pgrouting
	 public | ways_vertices_pgr_id_seq | sequence | pgrouting
	(15 rows)

	
[16] pgrouting=> select osm_id, lon, lat, ST_AsText(the_geom)  from ways_vertices_pgr limit 10;
	
	
	   osm_id   |     lon     |     lat     |          st_astext
	------------+-------------+-------------+------------------------------
	 3168363677 | -6.79648660 | 62.00056210 | POINT(-6.7964866 62.0005621)
	  331796449 | -6.81978140 | 61.47407190 | POINT(-6.8197814 61.4740719)
	  366629200 | -7.14572420 | 62.28877990 | POINT(-7.1457242 62.2887799)
	  558639283 | -6.71098210 | 62.21059560 | POINT(-6.7109821 62.2105956)
	 3452032805 | -6.99596610 | 62.20211330 | POINT(-6.9959661 62.2021133)
	  410039264 | -6.86097870 | 62.25934840 | POINT(-6.8609787 62.2593484)
	 3429747864 | -6.77915910 | 62.01795350 | POINT(-6.7791591 62.0179535)
	 3622655257 | -6.78571640 | 62.00681230 | POINT(-6.7857164 62.0068123)
	  541162171 | -6.77375440 | 62.01128310 | POINT(-6.7737544 62.0112831)
	  454636994 | -6.75819930 | 62.11217800 | POINT(-6.7581993 62.112178)
	(10 rows)
		

[17] pgrouting=> SELECT osm_id, lon , lat, ST_AsText(the_geom) FROM ways_vertices_pgr WHERE (lat > 62.1911 AND lat < 62.1921) AND (lon > -7.0306 AND lon < -7.0281);

	  osm_id   |     lon     |     lat     |          st_astext
	-----------+-------------+-------------+------------------------------
	 559617914 | -7.02896090 | 62.19140220 | POINT(-7.0289609 62.1914022)
	(1 row)


[18] pgrouting=> SELECT osm_id, lon , lat, ST_AsText(the_geom) FROM ways_vertices_pgr WHERE (lat > 62.1929 AND lat < 62.1938) AND (lon > -7.0460 AND lon < -7.0435);

	
	  osm_id   |     lon     |     lat     |          st_astext
	-----------+-------------+-------------+------------------------------
	 559617727 | -7.04498740 | 62.19334670 | POINT(-7.0449874 62.1933467)
	(1 row)


[19] pgrouting=# SELECT osm_id, x1 , y1, x2,y2 , source, target  FROM ways WHERE (y1 > 62.1911 AND y1 < 62.1921) AND (x1 > -7.0306 AND x1 < -7.0281);

	osm_id   |     x1     |     y1     |     x2     |     y2     | source | target 
	-----------+------------+------------+------------+------------+--------+--------
	 114795881 | -7.0289609 | 62.1914022 | -7.0315045 | 62.1913156 |   3809 |   1900
	(1 row)

	 

[20] pgrouting=# SELECT osm_id, x1 , y1, x2, y2 , source, target  FROM ways WHERE (y1 > 62.1924 AND y1 < 62.1946) AND (x1 > -7.0453 AND x1 < -7.0382);

	 osm_id   |     x1     |     y1     |     x2     |     y2     | source | target 
	-----------+------------+------------+------------+------------+--------+--------
	  44013684 | -7.0408367 | 62.1937369 | -7.0395327 | 62.1933828 |    452 |   2045
	  44013684 | -7.0395327 | 62.1933828 | -7.0376734 | 62.1929646 |   2045 |    327
	 114795880 | -7.0399903 | 62.1940726 | -7.0390696 | 62.1938331 |   4951 |   5051
	 114795880 | -7.0390696 | 62.1938331 | -7.0362069 | 62.1931954 |   5051 |   1681
	 114795882 | -7.0395327 | 62.1933828 | -7.0390696 | 62.1938331 |   2045 |   5051
	(5 rows)

	

[21] pgrouting=# SELECT seq, node, edge, cost FROM pgr_dijkstra(' SELECT gid as id, source, target, length as cost FROM ways',     3809, 5051, false );

	 seq | node | edge |         cost
	-----+------+------+----------------------
	   1 | 3809 | 3816 |   0.0078278026786715
	   2 | 4758 | 3815 |  0.00113514190302428
	   3 |  327 | 3814 |  0.00190598730606986
	   4 | 2045 | 5814 | 0.000645934749024032
	   5 | 5051 |   -1 |                    0
	(5 rows)


[22] pgrouting=> \q


