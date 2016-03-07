#! /bin/bash

# restart
# gosu postgres pg_ctl stop -w;
# gosu postgres pg_ctl start -w;


printf "\n"
echo "---------------------------------------------"
printf "LOADING DATA: START\n\n"

psql -U postgres -f /opt/data/data.sql i2b2

printf "\nLOADING DATA: STOP\n"
echo "---------------------------------------------"



# if \
#   [[ "$PG_VERSION" = "9.4"* ]]; then
#   gosu postgres pg_ctl stop -w;
# fi
