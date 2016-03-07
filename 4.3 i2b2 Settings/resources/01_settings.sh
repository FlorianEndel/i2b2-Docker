#! /bin/bash

if [ -z "$i2b2_IP" ]; then
  i2b2_IP=$(getent hosts i2b2 | awk '{ print $1 }' | uniq)
fi
if [ -z "$PG_IP" ]; then
  PG_IP=$(getent hosts db | awk '{ print $1 }' | uniq)
fi
#$(cat /etc/hosts | grep i2b2 | awk {'print $1'})


if [ -z "$HIVE_ID" ]; then
  HIVE_ID=i2b2demo
fi

if [ -z "$JBOSS_HOME"]; then
  JBOSS_HOME=/opt/jboss
fi

printf "\n\n"
echo PostgreSQL: $PG_MAJOR
echo i2b2 IP: $i2b2_IP
echo JBOSS_PORT: $JBOSS_PORT
echo Postgres IP: $PG_IP
echo JBOSS_HOME: $JBOSS_HOME
echo HIVE_ID: $HIVE_ID
printf "\n\n"


printf "\n"
echo "---------------------------------------------"
printf "SET IP of i2b2 Container: START\n\n"


psql -a -h $PG_IP -U postgres --dbname=i2b2  <<EOSQL

UPDATE i2b2pm.pm_cell_data
SET url = 'http://$i2b2_IP:$JBOSS_PORT/i2b2/services/QueryToolService/'
WHERE cell_id = 'CRC';

UPDATE i2b2pm.pm_cell_data
SET url = 'http://$i2b2_IP:$JBOSS_PORT/i2b2/services/FRService/'
WHERE cell_id = 'FRC';

UPDATE i2b2pm.pm_cell_data
SET url = 'http://$i2b2_IP:$JBOSS_PORT/i2b2/services/IMService/'
WHERE cell_id = 'IM';

UPDATE i2b2pm.pm_cell_data
SET url = 'http://$i2b2_IP:$JBOSS_PORT/i2b2/services/OntologyService/'
WHERE cell_id = 'ONT';

UPDATE i2b2pm.pm_cell_data
SET url = 'http://$i2b2_IP:$JBOSS_PORT/i2b2/services/WorkplaceService/'
WHERE cell_id = 'WORK';

EOSQL

printf "\nSET IP of i2b2 Container: STOP\n"
echo "---------------------------------------------"



printf "\n"
echo "---------------------------------------------"
printf "Activate GIRI Cell: START\n\n"


psql -a -h $PG_IP -U postgres --dbname=i2b2  <<EOSQL

DELETE FROM i2b2pm.pm_cell_data
WHERE cell_id = 'GIRI';

INSERT INTO
	i2b2pm.pm_cell_data
	(
  cell_id, project_path,
  name, method_cd,
  url,
  can_override, change_date, entry_date, changeby_char, status_cd
	)
VALUES
	(
		'GIRI','/',
		'GIRI Cell', 'REST',
		'http://$i2b2_IP:$JBOSS_PORT/i2b2/services/GIRIService/',
		'1', NULL, NULL, NULL, 'A'
);

EOSQL

printf "\nActivate GIRI Cell: STOP\n"
echo "---------------------------------------------"


#
# printf "\n"
# echo "---------------------------------------------"
# printf "Activate IDRT Webclient Plugin Cell: START\n\n"
#
#
# psql -a -h $PG_IP -U postgres --dbname=i2b2  <<EOSQL
#
# DELETE FROM i2b2pm.pm_cell_data
# WHERE cell_id = 'IdrtAdditionalData2';
#
# INSERT INTO
# 	i2b2pm.pm_cell_data
# 	(
#   cell_id, project_path,
#   name, method_cd,
#   url,
#   can_override, change_date, entry_date, changeby_char, status_cd
# 	)
# VALUES
# 	(
# 		'IdrtAdditionalData2','/',
# 		'IdrtAdditionalData2', 'SOAP',
# 		'http://$i2b2_IP:$JBOSS_PORT/i2b2/services/IdrtAdditionalData/',
# 		'1', NULL, NULL, NULL, 'A'
# );
#
# EOSQL
#
# printf "\nActivate IDRT Webclient Plugin Cell: STOP\n"
# echo "---------------------------------------------"






printf "\n"
echo "---------------------------------------------"
printf "SET HIVE ID: START\n\n"


psql -a -h $PG_IP -U postgres --dbname=i2b2  <<EOSQL

TRUNCATE TABLE i2b2pm.pm_hive_data;

INSERT INTO i2b2pm.pm_hive_data
  (DOMAIN_ID, HELPURL, DOMAIN_NAME, ENVIRONMENT_CD, ACTIVE,
		    CHANGE_DATE, ENTRY_DATE, CHANGEBY_CHAR, STATUS_CD)
  VALUES ('i2b2', 'http://www.i2b2.org', '$HIVE_ID', 'DEVELOPMENT', 1,
						    null, null, null, 'A');

UPDATE i2b2hive.work_db_lookup SET c_domain_id = '$HIVE_ID';
UPDATE i2b2hive.crc_db_lookup SET c_domain_id = '$HIVE_ID';
UPDATE i2b2hive.ont_db_lookup SET c_domain_id = '$HIVE_ID';
UPDATE i2b2hive.im_db_lookup SET c_domain_id = '$HIVE_ID';

EOSQL

printf "\nSET HIVE ID: STOP\n"
echo "---------------------------------------------"



printf "\n"
echo "---------------------------------------------"
printf "Activate PatientCount Cell: START\n\n"


psql -a -h $PG_IP -U postgres --dbname=i2b2  <<EOSQL


DELETE FROM i2b2demodata.qt_analysis_plugin
WHERE plugin_name = 'CALCULATE_PATIENTCOUNT_FROM_CONCEPTPATH';

INSERT INTO
	i2b2demodata.qt_analysis_plugin
	(
		plugin_id, plugin_name, description, version_cd,
		command_line, working_folder, status_cd, group_id
	)
VALUES
	(
		'1','CALCULATE_PATIENTCOUNT_FROM_CONCEPTPATH',
		'CALCULATE_PATIENTCOUNT_FROM_CONCEPTPATH', '1.0',
		'${JBOSS_HOME}/standalone/analysis_commons_launcher/bin/run_conceptpatient_breakdown.sh',
		'${JBOSS_HOME}/standalone/analysis_commons_launcher/bin',
		'A', '@'
);

EOSQL

printf "\nActivate PatientCount Cell: STOP\n"
echo "---------------------------------------------"
