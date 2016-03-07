#!/bin/bash

# check whether a dedicated project config file is defined
if [ -z "$1" ]; then
  # no config defined
  echo "Please define project configuration"
  exit 1;
else
  # load project configuration
  source $1
fi


cd $JBOSS_HOME/standalone/deployments
#touch ${i2b2_SOURCE}/ds-generic.xml


# ONTology
CELL=Ontology
cp ont-ds.xml ont-ds.xml.bak

cat ont-ds.xml.bak | \
  sed -e "/\/datasources/ { r ${i2b2_SOURCE}/ds-generic.xml" -e "d}" | \
  sed \
    -e "s/_PROJECT_NAME_/$PROJECT_NAME/g;" \
    -e "s/_CELL_/$CELL/g;" \
    -e "s#_CON_URL_#$CON_URL#g;" \
    -e "s/_DB_USER_/$i2b2_db_user_ONT/g;" \
    -e "s/_DB_PASS_/$i2b2_db_pass_ONT/g;" \
    -e "s/_DB_DRIVER_CLASS_/$DB_DRIVER_CLASS/g;" \
    -e "s/_DB_DRIVER_/$DB_DRIVER/g" \
    > ont-ds.xml



# CRC / QueryTool
CELL=QueryTool
cp crc-ds.xml crc-ds.xml.bak

cat crc-ds.xml.bak | \
  sed -e "/\/datasources/ { r ${i2b2_SOURCE}/ds-generic.xml" -e "d}" | \
  sed \
    -e "s/_PROJECT_NAME_/$PROJECT_NAME/g;" \
    -e "s/_CELL_/$CELL/g;" \
    -e "s#_CON_URL_#$CON_URL#g;" \
    -e "s/_DB_USER_/$i2b2_db_user_CRC/g;" \
    -e "s/_DB_PASS_/$i2b2_db_pass_CRC/g;" \
    -e "s/_DB_DRIVER_CLASS_/$DB_DRIVER_CLASS/g;" \
    -e "s/_DB_DRIVER_/$DB_DRIVER/g" \
    > crc-ds.xml



# WORK / Workplace
cd $JBOSS_HOME/standalone/deployments
CELL=Workplace
cp work-ds.xml work-ds.xml.bak

cat work-ds.xml.bak | \
  sed -e "/\/datasources/ { r ${i2b2_SOURCE}/ds-generic.xml" -e "d}" | \
  sed \
    -e "s/_PROJECT_NAME_/$PROJECT_NAME/g;" \
    -e "s/_CELL_/$CELL/g;" \
    -e "s#_CON_URL_#$CON_URL#g;" \
    -e "s/_DB_USER_/$i2b2_db_user_WORK/g;" \
    -e "s/_DB_PASS_/$i2b2_db_pass_WORK/g;" \
    -e "s/_DB_DRIVER_CLASS_/$DB_DRIVER_CLASS/g;" \
    -e "s/_DB_DRIVER_/$DB_DRIVER/g" \
    > work-ds.xml



# IM
cd $JBOSS_HOME/standalone/deployments
CELL=IM
cp im-ds.xml im-ds.xml.bak

cat im-ds.xml.bak | \
  sed -e "/\/datasources/ { r ${i2b2_SOURCE}/ds-generic.xml" -e "d}" | \
  sed \
    -e "s/_PROJECT_NAME_/$PROJECT_NAME/g;" \
    -e "s/_CELL_/$CELL/g;" \
    -e "s#_CON_URL_#$CON_URL#g;" \
    -e "s/_DB_USER_/$i2b2_db_user_IM/g;" \
    -e "s/_DB_PASS_/$i2b2_db_pass_IM/g;" \
    -e "s/_DB_DRIVER_CLASS_/$DB_DRIVER_CLASS/g;" \
    -e "s/_DB_DRIVER_/$DB_DRIVER/g" \
    > im-ds.xml
