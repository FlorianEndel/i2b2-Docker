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

#touch ${i2b2_SOURCE}/ds-generic.xml


# ONTology
cd $i2b2_SOURCE/edu.harvard.i2b2.ontology/etc/jboss
CELL=Ontology
cp ont-ds.xml ont-ds.xml.bak

cat ont-ds.xml.bak | \
  sed -e "/\/datasources/ { r ${i2b2_SOURCE}/ds-generic.xml" -e "d}" | \
  sed \
    -e "s/_PROJECT_NAME_/$PROJECT_NAME/g;" \
    -e "s/_CELL_/$CELL/g;" \
    -e "s#_CON_URL_#$CON_URL#g;" \
    -e "s/_DB_USER_/$DB_USER/g;" \
    -e "s/_DB_PASS_/$DB_PASS/g;" \
    -e "s/_DB_DRIVER_CLASS_/$DB_DRIVER_CLASS/g;" \
    -e "s/_DB_DRIVER_/$DB_DRIVER/g" \
    > ont-ds.xml

# Deploy Cell
cd $i2b2_SOURCE/edu.harvard.i2b2.ontology
ant -f master_build.xml clean build-all deploy


# CRC / QueryTool
cd $i2b2_SOURCE/edu.harvard.i2b2.crc/etc/jboss
CELL=QueryTool
cp crc-ds.xml crc-ds.xml.bak

cat crc-ds.xml.bak | \
  sed -e "/\/datasources/ { r ${i2b2_SOURCE}/ds-generic.xml" -e "d}" | \
  sed \
    -e "s/_PROJECT_NAME_/$PROJECT_NAME/g;" \
    -e "s/_CELL_/$CELL/g;" \
    -e "s#_CON_URL_#$CON_URL#g;" \
    -e "s/_DB_USER_/$DB_USER/g;" \
    -e "s/_DB_PASS_/$DB_PASS/g;" \
    -e "s/_DB_DRIVER_CLASS_/$DB_DRIVER_CLASS/g;" \
    -e "s/_DB_DRIVER_/$DB_DRIVER/g" \
    > crc-ds.xml

# Deploy Cell
cd $i2b2_SOURCE/edu.harvard.i2b2.crc
ant -f master_build.xml clean build-all deploy


# WORK / Workplace
cd $i2b2_SOURCE/edu.harvard.i2b2.workplace/etc/jboss
CELL=Workplace
cp work-ds.xml work-ds.xml.bak

cat work-ds.xml.bak | \
  sed -e "/\/datasources/ { r ${i2b2_SOURCE}/ds-generic.xml" -e "d}" | \
  sed \
    -e "s/_PROJECT_NAME_/$PROJECT_NAME/g;" \
    -e "s/_CELL_/$CELL/g;" \
    -e "s#_CON_URL_#$CON_URL#g;" \
    -e "s/_DB_USER_/$DB_USER/g;" \
    -e "s/_DB_PASS_/$DB_PASS/g;" \
    -e "s/_DB_DRIVER_CLASS_/$DB_DRIVER_CLASS/g;" \
    -e "s/_DB_DRIVER_/$DB_DRIVER/g" \
    > work-ds.xml

# Deploy Cell
cd $i2b2_SOURCE/edu.harvard.i2b2.workplace
ant -f master_build.xml clean build-all deploy


# IM
cd ${i2b2_SOURCE}/edu.harvard.i2b2.im/etc/jboss
CELL=IM
cp im-ds.xml im-ds.xml.bak

cat im-ds.xml.bak | \
  sed -e "/\/datasources/ { r ${i2b2_SOURCE}/ds-generic.xml" -e "d}" | \
  sed \
    -e "s/_PROJECT_NAME_/$PROJECT_NAME/g;" \
    -e "s/_CELL_/$CELL/g;" \
    -e "s#_CON_URL_#$CON_URL#g;" \
    -e "s/_DB_USER_/$DB_USER/g;" \
    -e "s/_DB_PASS_/$DB_PASS/g;" \
    -e "s/_DB_DRIVER_CLASS_/$DB_DRIVER_CLASS/g;" \
    -e "s/_DB_DRIVER_/$DB_DRIVER/g" \
    > im-ds.xml

# Deploy Cell
cd ${i2b2_SOURCE}/edu.harvard.i2b2.im
ant -f master_build.xml clean build-all deploy
