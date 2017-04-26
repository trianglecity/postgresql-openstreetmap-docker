#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER docker;
    CREATE DATABASE docker;
    GRANT ALL PRIVILEGES ON DATABASE docker TO docker;
    ALTER USER docker WITH PASSWORD 'password';
    CREATE USER pgrouting;	
    CREATE DATABASE pgrouting;
    GRANT ALL PRIVILEGES ON DATABASE pgrouting TO pgrouting;
    ALTER USER pgrouting WITH PASSWORD 'password';		
EOSQL

psql -d docker -c "CREATE EXTENSION postgis;"
psql -d docker -c "CREATE EXTENSION hstore;"
psql -d pgrouting -c "CREATE EXTENSION postgis;"
psql -d pgrouting -c "CREATE EXTENSION hstore;"
psql -d pgrouting -c "CREATE EXTENSION pgrouting;"
