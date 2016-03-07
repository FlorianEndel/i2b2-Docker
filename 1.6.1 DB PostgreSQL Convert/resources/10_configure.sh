#! /bin/bash

source /docker-entrypoint-initdb.d/db_hive.conf
source /docker-entrypoint-initdb.d/db_project_demo.conf

cd $i2b2_DATA


printf "\n"
echo "---------------------------------------------"
printf "DB Properties: START\n\n"

# db.type
printf "db.type\n"
sed -i "s#db.type=.*#db.type=postgresql#g" ./Hivedata/db.properties
sed -i "s#db.type=.*#db.type=postgresql#g" ./Pmdata/db.properties
sed -i "s#db.type=.*#db.type=postgresql#g" ./Crcdata/db.properties
sed -i "s#db.type=.*#db.type=postgresql#g" ./Metadata/db.properties
sed -i "s#db.type=.*#db.type=postgresql#g" ./Workdata/db.properties
sed -i "s#db.type=.*#db.type=postgresql#g" ./Imdata/db.properties

# db.username
printf "db.username\n"
sed -i "s#db.username=.*#db.username=$i2b2_db_user_HIVE#g" ./Hivedata/db.properties
sed -i "s#db.username=.*#db.username=$i2b2_db_user_PM#g" ./Pmdata/db.properties

sed -i "s#db.username=.*#db.username=$i2b2_db_user_CRC#g" ./Crcdata/db.properties
sed -i "s#db.username=.*#db.username=$i2b2_db_user_ONT#g" ./Metadata/db.properties
sed -i "s#db.username=.*#db.username=$i2b2_db_user_WORK#g" ./Workdata/db.properties
sed -i "s#db.username=.*#db.username=$i2b2_db_user_IM#g" ./Imdata/db.properties

# db.password
printf "db.password\n"
sed -i "s#db.password=.*#db.password=$i2b2_db_pass_HIVE#g" ./Hivedata/db.properties
sed -i "s#db.password=.*#db.password=$i2b2_db_pass_PM#g" ./Pmdata/db.properties

sed -i "s#db.password=.*#db.password=$i2b2_db_pass_CRC#g" ./Crcdata/db.properties
sed -i "s#db.password=.*#db.password=$i2b2_db_pass_ONT#g" ./Metadata/db.properties
sed -i "s#db.password=.*#db.password=$i2b2_db_pass_WORK#g" ./Workdata/db.properties
sed -i "s#db.password=.*#db.password=$i2b2_db_pass_IM#g" ./Imdata/db.properties

# db.server (remove)
printf "db.server\n"
sed -i "/db.server.*/d" ./Hivedata/db.properties
sed -i "/db.server.*/d" ./Pmdata/db.properties
sed -i "/db.server.*/d" ./Crcdata/db.properties
sed -i "/db.server.*/d" ./Metadata/db.properties
sed -i "/db.server.*/d" ./Workdata/db.properties
sed -i "/db.server.*/d" ./Imdata/db.properties

# db.driver
printf "db.driver\n"
sed -i "s#db.driver=.*#db.driver=org.postgresql.Driver#g" ./Hivedata/db.properties
sed -i "s#db.driver=.*#db.driver=org.postgresql.Driver#g" ./Pmdata/db.properties
sed -i "s#db.driver=.*#db.driver=org.postgresql.Driver#g" ./Crcdata/db.properties
sed -i "s#db.driver=.*#db.driver=org.postgresql.Driver#g" ./Metadata/db.properties
sed -i "s#db.driver=.*#db.driver=org.postgresql.Driver#g" ./Workdata/db.properties
sed -i "s#db.driver=.*#db.driver=org.postgresql.Driver#g" ./Imdata/db.properties

# db.url
printf "db.url\n"
sed -i "s#db.url=.*#db.url=jdbc:postgresql://localhost/i2b2?searchpath=$i2b2_db_schema_HIVE#g" ./Hivedata/db.properties
sed -i "s#db.url=.*#db.url=jdbc:postgresql://localhost/i2b2?searchpath=$i2b2_db_schema_PM#g" ./Pmdata/db.properties

sed -i "s#db.url=.*#db.url=jdbc:postgresql://localhost/i2b2?searchpath=$i2b2_db_schema_CRC#g" ./Crcdata/db.properties
sed -i "s#db.url=.*#db.url=jdbc:postgresql://localhost/i2b2?searchpath=$i2b2_db_schema_ONT#g" ./Metadata/db.properties
sed -i "s#db.url=.*#db.url=jdbc:postgresql://localhost/i2b2?searchpath=$i2b2_db_schema_WORK#g" ./Workdata/db.properties
sed -i "s#db.url=.*#db.url=jdbc:postgresql://localhost/i2b2?searchpath=$i2b2_db_schema_IM#g" ./Imdata/db.properties

# db.project
printf "db.project\n"
sed -i "s#db.project=.*#db.project=$db_project#g" ./Hivedata/db.properties
sed -i "s#db.project=.*#db.project=$db_project#g" ./Pmdata/db.properties
sed -i "s#db.project=.*#db.project=$db_project#g" ./Crcdata/db.properties
sed -i "s#db.project=.*#db.project=$db_project#g" ./Metadata/db.properties
sed -i "s#db.project=.*#db.project=$db_project#g" ./Workdata/db.properties
sed -i "s#db.project=.*#db.project=$db_project#g" ./Imdata/db.properties




printf "\nDB Properties: STOP\n"
echo "---------------------------------------------"
