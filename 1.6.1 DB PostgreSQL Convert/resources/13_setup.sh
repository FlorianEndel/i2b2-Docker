#! /bin/bash

printf "\n"
echo "---------------------------------------------"
printf "Edit DB: START\n\n"

psql -a -U postgres --dbname=i2b2  <<EOSQL

UPDATE i2b2hive.crc_db_lookup
  SET c_db_fullschema = 'i2b2demodata'
  WHERE c_domain_id = 'i2b2demo';

UPDATE i2b2hive.im_db_lookup
  SET c_db_fullschema = 'i2b2imdata'
  WHERE c_domain_id = 'i2b2demo';

UPDATE i2b2hive.ont_db_lookup
  SET c_db_fullschema = 'i2b2metadata'
  WHERE c_domain_id = 'i2b2demo';

UPDATE i2b2hive.work_db_lookup
  SET c_db_fullschema = 'i2b2workdata'
  WHERE c_domain_id = 'i2b2demo';

EOSQL

printf "\nEdit DB: STOP\n"
echo "---------------------------------------------"
