#!/bin/bash


printf "\n"
echo "---------------------------------------------"
printf "CITUSDB FDW: START\n\n"

gosu postgres pg_ctl stop -w

sed -i "s/#shared_preload_libraries = ''/shared_preload_libraries = 'cstore_fdw'/g" $PGDATA/postgresql.conf

####### previously PG 9.3 and 9.4 did not start automatically
# if \
#   [[ "$PG_VERSION" = "9.3"* ]] || \
#   [[ "$PG_VERSION" = "9.4"* ]] ; then
#   gosu postgres pg_ctl start -w;
# else
#   gosu postgres pg_ctl reload; # activate new settings
# fi

gosu postgres pg_ctl start -w

psql -a -U postgres --dbname=postgres  <<EOSQL
CREATE EXTENSION cstore_fdw;
CREATE SERVER cstore_server FOREIGN DATA WRAPPER cstore_fdw;
EOSQL

printf "\nCITUSDB FDW: STOP\n"
echo "---------------------------------------------"
