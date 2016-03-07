#! /bin/bash

printf "\n\n"
echo $PG_VERSION
printf "\n\n"

# gosu postgres pg_ctl start -w;

printf "\n"
echo "---------------------------------------------"
printf "CREATING SCHEMA & USER: START\n\n"

#gosu postgres createdb i2b2

psql -a -U postgres --dbname=i2b2  <<EOSQL

--CREATE USER i2b2 WITH SUPERUSER PASSWORD 'i2b2';

/*
CREATE USER $i2b2_db_user_HIVE 		  PASSWORD '$i2b2_db_pass_HIVE';
CREATE USER $i2b2_db_user_PM 		    PASSWORD '$i2b2_db_pass_PM';
CREATE SCHEMA IF NOT EXISTS AUTHORIZATION $i2b2_db_schema_HIVE;
CREATE SCHEMA IF NOT EXISTS AUTHORIZATION $i2b2_db_schema_PM;
*/

CREATE USER $i2b2_db_user_CRC 	PASSWORD '$i2b2_db_pass_CRC'; -- CRC
CREATE USER $i2b2_db_user_ONT 	PASSWORD '$i2b2_db_pass_ONT'; -- ONT
CREATE USER $i2b2_db_user_WORK 	PASSWORD '$i2b2_db_pass_WORK'; -- WORK
CREATE USER $i2b2_db_user_IM 		PASSWORD '$i2b2_db_pass_IM'; -- IM
CREATE SCHEMA IF NOT EXISTS $i2b2_db_schema_CRC   AUTHORIZATION $i2b2_db_user_CRC;
CREATE SCHEMA IF NOT EXISTS $i2b2_db_schema_ONT   AUTHORIZATION $i2b2_db_user_ONT;
CREATE SCHEMA IF NOT EXISTS $i2b2_db_schema_WORK  AUTHORIZATION $i2b2_db_user_WORK;
CREATE SCHEMA IF NOT EXISTS $i2b2_db_schema_IM    AUTHORIZATION $i2b2_db_user_IM;

EOSQL

printf "\nCREATING SCHEMA & USER: STOP\n"
echo "---------------------------------------------"
