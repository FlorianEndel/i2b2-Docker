#! /bin/bash

# restart
# gosu postgres pg_ctl stop -w;
# gosu postgres pg_ctl start -w;


printf "\n"
echo "---------------------------------------------"
printf "DATA Crcdata START\n\n"

cd $i2b2_DATA
cd Crcdata
ant -f data_build.xml create_crcdata_tables_release_1-7
ant -f data_build.xml create_procedures_release_1-7
if [ "$demo_data" = true ] ; then
  ant -f data_build.xml db_demodata_load_data
fi

printf "\n"
echo "---------------------------------------------"
printf "DATA Crcdata END\n\n"



printf "\n"
echo "---------------------------------------------"
printf "DATA Imdata START\n\n"

cd $i2b2_DATA
cd Imdata
ant -f data_build.xml create_imdata_tables_release_1-7
if [ "$demo_data" = true ] ; then
  ant -f data_build.xml db_imdata_load_data
fi

printf "\n"
echo "---------------------------------------------"
printf "DATA Imdata END\n\n"



printf "\n"
echo "---------------------------------------------"
printf "DATA Metadata START\n\n"

cd $i2b2_DATA
cd Metadata
ant -f data_build.xml create_metadata_tables_release_1-7
if [ "$demo_data" = true ] ; then
  ant -f data_build.xml db_metadata_load_data
fi

printf "\n"
echo "---------------------------------------------"
printf "DATA Metadata END\n\n"



printf "\n"
echo "---------------------------------------------"
printf "DATA Workdata START\n\n"

cd $i2b2_DATA
cd Workdata
ant -f data_build.xml create_workdata_tables_release_1-7
if [ "$demo_data" = true ] ; then
  ant -f data_build.xml db_workdata_load_data
fi

printf "\n"
echo "---------------------------------------------"
printf "DATA Workdata END\n\n"
