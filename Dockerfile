FROM postgres:9.6

RUN	apt-get  update 
RUN	apt-get  upgrade -y

RUN 	apt-get install -y postgis

ENV	POSTGIS_ENABLE_OUTDB_RASTERS	1
ENV	POSTGIS_GDAL_ENABLED_DRIVERS 	ENABLE_ALL

RUN	mkdir -p /docker-entrypoint-initdb.d 	

	

RUN	apt-get install -y osm2pgsql

RUN 	mkdir -p /tmp



RUN	apt-get install -y libproj-dev && \
	apt-get install -y libgeos-dev && \
	apt-get install -y libgdal-dev



RUN	apt-get install -y build-essential && \
 	apt-get install -y apt-utils && \
	apt-get install -y automake && \
	apt-get install -y cmake && \
	apt-get install -y libprotobuf-dev && \
	apt-get install -y gcc && \
	apt-get install -y gcc-4.9 && \
	apt-get install -y gcc-4.8 && \
	apt-get install -y g++ && \
	apt-get install -y g++-4.9 && \
	apt-get install -y g++-4.8 && \
	apt-get install -y gcc-multilib && \
	apt-get install -y libgomp1 && \
	apt-get install -y pkg-config && \
	apt-get install -y sphinx-common && \
	apt-get install -y gfortran

RUN	apt-get install -y libboost-dev && \
	apt-get install -y libpq-dev && \
	apt-get install -y libexpat1-dev && \
	apt-get install -y expat && \
	apt-get install -y cmake && \
	apt-get install -y git && \
	apt-get install -y libboost-program-options-dev

RUN	git clone https://github.com/pgRouting/osm2pgrouting.git && \
	cd osm2pgrouting && \
	cmake -H. -Bbuild && \
	cd build && \
	make && \
	make install

RUN	apt-get install -y postgresql-9.6-pgrouting && \
	apt-get install -y postgresql-9.6-pgrouting-scripts

ADD 	init-user-db.sh /docker-entrypoint-initdb.d	
ADD 	faroe-islands-latest.osm /tmp/
ADD 	default.style /tmp/
