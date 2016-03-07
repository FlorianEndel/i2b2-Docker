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


printf "\n"
echo "---------------------------------------------"
printf "INSERT Project Information: START \n\n"

psql -a -U postgres --dbname=i2b2  <<EOSQL

-- Setup Project Data
INSERT INTO i2b2pm.pm_project_data (
  PROJECT_ID, PROJECT_NAME, PROJECT_WIKI, PROJECT_KEY, PROJECT_PATH,
  PROJECT_DESCRIPTION, CHANGE_DATE, ENTRY_DATE, CHANGEBY_CHAR, STATUS_CD
)
VALUES (
  '$PROJECT_NAME', '$PROJECT_NAME', 'http://www.i2b2.org', null, '/$PROJECT_NAME',
  null, null, null, null, 'A'
);


-- Insert Cell Information

INSERT INTO i2b2hive.crc_db_lookup (
  C_DOMAIN_ID, C_PROJECT_PATH, C_OWNER_ID, C_DB_FULLSCHEMA,
  C_DB_DATASOURCE, C_DB_SERVERTYPE, C_DB_NICENAME, C_DB_TOOLTIP,
  C_ENTRY_DATE, C_CHANGE_DATE, C_STATUS_CD
)
VALUES (
  '$HIVE_ID', '/$PROJECT_NAME/', '@', '$i2b2_db_schema_CRC',
  'java:/QueryTool$PROJECT_NAME', 'POSTGRESQL', '$PROJECT_NAME',
  null, null, null, null
);

INSERT INTO i2b2hive.ont_db_lookup (
  C_DOMAIN_ID, C_PROJECT_PATH, C_OWNER_ID, C_DB_FULLSCHEMA,
  C_DB_DATASOURCE, C_DB_SERVERTYPE, C_DB_NICENAME, C_DB_TOOLTIP,
  C_ENTRY_DATE, C_CHANGE_DATE, C_STATUS_CD
)
VALUES (
  '$HIVE_ID', '$PROJECT_NAME/', '@', '$i2b2_db_schema_ONT',
  'java:/Ontology$PROJECT_NAME', 'POSTGRESQL', '$PROJECT_NAME',
  null, null, null, null
);

INSERT INTO i2b2hive.work_db_lookup (
  C_DOMAIN_ID, C_PROJECT_PATH, C_OWNER_ID, C_DB_FULLSCHEMA,
  C_DB_DATASOURCE, C_DB_SERVERTYPE, C_DB_NICENAME, C_DB_TOOLTIP,
  C_ENTRY_DATE, C_CHANGE_DATE, C_STATUS_CD
)
VALUES (
  '$HIVE_ID', '$PROJECT_NAME/' ,'@' ,'$i2b2_db_schema_WORK',
  'java:/Workplace$PROJECT_NAME', 'POSTGRESQL', '$PROJECT_NAME',
  null, null, null, null
);

INSERT INTO i2b2hive.im_db_lookup (
  C_DOMAIN_ID, C_PROJECT_PATH, C_OWNER_ID, C_DB_FULLSCHEMA,
  C_DB_DATASOURCE, C_DB_SERVERTYPE, C_DB_NICENAME, C_DB_TOOLTIP,
  C_ENTRY_DATE, C_CHANGE_DATE, C_STATUS_CD
)
VALUES (
  '$HIVE_ID', '$PROJECT_NAME/', '@', '$i2b2_db_schema_IM',
  'java:/IM$PROJECT_NAME', 'POSTGRESQL' ,'$PROJECT_NAME',
  null, null, null, null
);

EOSQL

printf "\nINSERT Project Information: STOP\n"
echo "---------------------------------------------"



printf "\n"
echo "---------------------------------------------"
printf "INSERT Project i2b2 USERS: START\n\n"

psql -a -U postgres --dbname=i2b2  <<EOSQL
/*
INSERT INTO i2b2pm.pm_project_user_roles (
  PROJECT_ID, USER_ID, USER_ROLE_CD, CHANGE_DATE, ENTRY_DATE, CHANGEBY_CHAR, STATUS_CD
)
VALUES (
  '$PROJECT_NAME', 'OBFSC_SERVICE_ACCOUNT', 'USER', null, null, null, 'A'
);

INSERT INTO i2b2pm.pm_project_user_roles (
  PROJECT_ID, USER_ID, USER_ROLE_CD, CHANGE_DATE, ENTRY_DATE, CHANGEBY_CHAR, STATUS_CD
)
VALUES (
  '$PROJECT_NAME', 'OBFSC_SERVICE_ACCOUNT', 'DATA_OBFSC', null, null, null, 'A'
);
*/

INSERT INTO i2b2pm.pm_project_user_roles (
  PROJECT_ID, USER_ID, USER_ROLE_CD, CHANGE_DATE, ENTRY_DATE, CHANGEBY_CHAR, STATUS_CD
)
VALUES (
  '$PROJECT_NAME', 'AGG_SERVICE_ACCOUNT', 'DATA_AGG', null, null, null, 'A'
);

INSERT INTO i2b2pm.pm_project_user_roles (
  PROJECT_ID, USER_ID, USER_ROLE_CD, CHANGE_DATE, ENTRY_DATE, CHANGEBY_CHAR, STATUS_CD
)
VALUES (
  '$PROJECT_NAME', 'AGG_SERVICE_ACCOUNT', 'DATA_OBFSC', null, null, null, 'A'
);

INSERT INTO i2b2pm.pm_project_user_roles (
  PROJECT_ID, USER_ID, USER_ROLE_CD, CHANGE_DATE, ENTRY_DATE, CHANGEBY_CHAR, STATUS_CD
)
VALUES (
  '$PROJECT_NAME', 'AGG_SERVICE_ACCOUNT', 'USER', null, null, null, 'A'
);

EOSQL

printf "\nINSERT Project i2b2 USERS: STOP\n"
echo "---------------------------------------------"
