#! /bin/bash

if  ! [ -z "$DUMP" ] && $DUMP; then

  printf "\n"
  echo "---------------------------------------------"
  printf "pg_dump START\n\n"

  cd /data
  pg_dump -h localhost -U postgres i2b2 --file=i2b2_$i2b2_VERSION_SHORT-postgres_dump-$PG_MAJOR.sql

  printf "\n"
  echo "---------------------------------------------"
  printf "pg_dump END\n\n"

fi

# PG 9.4: "FATAL:  lock file "postmaster.pid" already exists" if not stopped
# if \
#   [[ "$PG_VERSION" = "9.4"* ]]; then
#   gosu postgres pg_ctl stop -w;
# fi
