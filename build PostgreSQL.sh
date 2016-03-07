WORKDIR=`pwd`
i2b2_VERSION=1.7.06
i2b2_VERSION_SHORT=1706

# Set Ant Version [0='1.8.4', 1='1.9.6']
ANT_VERSIONS=( '1.8.4' '1.9.6' ) # 1.8.4 <-- i2b2
ANT_VERSION=${ANT_VERSIONS[1]}

PGVERSIONS_FDW=( '9.3' '9.4' )
PGVERSIONS_i2b2=( '9.1' '9.2' '9.3' '9.4' ) # i2b2 Error: '9.0' '9.5'
PGVERSIONS=("${PGVERSIONS_FDW[@]}")


################################################################################
## 1) Database PostgreSQL + Citus DB fdw

cd "$WORKDIR/1.6.0 DB PostgreSQL CitusDB"

for PGVERSION in "${PGVERSIONS_FDW[@]}"
do
  echo $PGVERSION

  # Build
  echo "Build"
  sed -i "1s/.*/FROM postgres:$PGVERSION/" Dockerfile

  docker build --tag=floe/postgres_citusdb_1.3:$PGVERSION \
    --build-arg CITUS_VERSION=1.3 \
    --rm=true .

done

# Docker compose
# docker-compose up -d
# docker-compose ps
# docker-compose logs
#
# docker-compose stop
# docker-compose rm


################################################################################
## Database PostgreSQL: Load & Convert

cd "$WORKDIR/1.6.1 DB PostgreSQL Convert"

# get files
rm resources/i2b2createdb-*
cp ../Downloads/i2b2createdb-$i2b2_VERSION_SHORT.zip ./resources/
rm resources/*.conf
cp ../Configuration/* ./resources/


for PGVERSION in "${PGVERSIONS[@]}"
do
  echo $PGVERSION

  # Build
  echo "Build"
  sed -i "1s/.*/FROM floe\/postgres_citusdb_1.3:$PGVERSION/" Dockerfile
  #sed -i "1s/.*/FROM postgres:$PGVERSION/" Dockerfile

  DOCKER_IMAGE=floe/i2b2-$i2b2_VERSION_SHORT-postgres_convert:$PGVERSION
  echo $DOCKER_IMAGE
  docker build --tag=$DOCKER_IMAGE \
    --build-arg i2b2_VERSION=$i2b2_VERSION \
    --build-arg i2b2_VERSION_SHORT=$i2b2_VERSION_SHORT \
    --build-arg ANT_VERSION=$ANT_VERSION \
    --rm=true  .

  # Run
  echo "Run"
  DOCKER_CONTAINER=i2b2_$i2b2_VERSION_SHORT-postgres_convert-$PGVERSION
  DOCKER_PG_STORAGE=i2b2_$i2b2_VERSION_SHORT-postgres_storage-$PGVERSION
  echo $DOCKER_CONTAINER && echo $DOCKER_PG_STORAGE

  # Storage Container
  docker rm $DOCKER_PG_STORAGE
  docker create -it --name $DOCKER_PG_STORAGE \
    --volume /var/lib/postgresql \
    postgres:$PGVERSION echo "storage container: PostgreSQL $PGVERSION."

  docker run --name $DOCKER_CONTAINER -it --rm=true \
    -e "POSTGRES_PASSWORD=" \
    -e "demo_data=true" \
    -v "$(pwd)"/data:/data \
    --volumes-from $DOCKER_PG_STORAGE \
    $DOCKER_IMAGE postgres --version \
    > $DOCKER_CONTAINER.log 2>&1
    # -it --rm=true # for debugging
    # -e "POSTGRES_USER=" -e "POSTGRES_PASSWORD="

done


# LOG:
# * check project title: no trailing spaces
# * check for WAR / ERR / FAT
# * WARNING: GLOBAL is deprecated in temporary table creation by PostgreSQL
# ** http://www.postgresql.org/docs/9.4/static/sql-createtable.html#SQL-CREATETABLE-COMPATIBILITY
# * check "SQL statements executed successfully"
# * "LOG:  checkpoints are occurring too frequently"
# ** --> config edited in "11_prepare.sh"
# ** http://www.postgresql.org/docs/current/static/runtime-config-wal.html#RUNTIME-CONFIG-WAL-CHECKPOINTS


######
# Test

# Link from Vanilla PostgreSQL Container
# PGVERSION=9.4
# i2b2_VERSION_SHORT=1706
# DOCKER_PG_STORAGE=i2b2_$i2b2_VERSION_SHORT-postgres_storage-$PGVERSION
#
# docker run -it --rm=true --name pg_test_$PGVERSION -p 127.0.0.1:5432:5432 \
#   -e "POSTGRES_USER=postgres" -e "POSTGRES_PASSWORD=postgres" \
#   --volumes-from $DOCKER_PG_STORAGE \
#   floe/postgres_citusdb_1.3:$PGVERSION
#
# psql -h localhost -U i2b2pm i2b2



################################################################################
## add new project

cd "$WORKDIR/7.1 Project DB"

# get files
rm resources/i2b2createdb-*
cp ../Downloads/i2b2createdb-$i2b2_VERSION_SHORT.zip ./resources/
cp ../Configuration/* ./resources/Config/


for PGVERSION in "${PGVERSIONS[@]}"
do
  echo $PGVERSION

  # Build
  echo "Build"
  sed -i "1s/.*/FROM floe\/postgres_citusdb_1.3:$PGVERSION/" Dockerfile
  #sed -i "1s/.*/FROM postgres:$PGVERSION/" Dockerfile

  DOCKER_IMAGE=floe/i2b2-$i2b2_VERSION_SHORT-postgres_add_project:$PGVERSION
  echo $DOCKER_IMAGE
  docker build --tag=$DOCKER_IMAGE \
    --build-arg i2b2_VERSION=$i2b2_VERSION \
    --build-arg i2b2_VERSION_SHORT=$i2b2_VERSION_SHORT \
    --build-arg ANT_VERSION=$ANT_VERSION \
    --rm=true  .

  # Run
  echo "Run"
  DOCKER_CONTAINER=i2b2_$i2b2_VERSION_SHORT-postgres_add_project-$PGVERSION
  DOCKER_PG_STORAGE=i2b2_$i2b2_VERSION_SHORT-postgres_storage-$PGVERSION
  echo $DOCKER_CONTAINER && echo $DOCKER_PG_STORAGE

  # i2b2_demo: i2b2 Demo Project in single schema
  docker run --name $DOCKER_CONTAINER -it --rm=true \
    -e "POSTGRES_PASSWORD=" \
    -e "i2b2_project_config=db_project_i2b2_demo.conf" \
    -e "DUMP=false" \
    --volumes-from $DOCKER_PG_STORAGE \
    $DOCKER_IMAGE \
    > $DOCKER_CONTAINER-i2b2_demo.log 2>&1
    # CMD Argument: "-i" for interacitve shell
    # -v "$(pwd)"/../Configuration/:/Configuration \
    # -e "i2b2_project_config=db_project_dexhelpp.conf"
    # -e "i2b2_project_config=db_project_i2b2_demo.conf"
    # -e "POSTGRES_USER=" -e "POSTGRES_PASSWORD="

  # DEXHELPP
  docker run --name $DOCKER_CONTAINER -it --rm=true \
    -e "POSTGRES_PASSWORD=" \
    -e "i2b2_project_config=db_project_dexhelpp.conf" \
    -e "DUMP=true" \
    -v "$(pwd)"/data:/data \
    --volumes-from $DOCKER_PG_STORAGE \
    $DOCKER_IMAGE \
    > $DOCKER_CONTAINER-dexhelpp.log 2>&1

done





################################################################################
## Image importing Vanilla from source

cd "$WORKDIR/1.6.2 DB PostgreSQL Import"

# clean data
rm -r data/*

rm resources/*.conf
cp ../Configuration/* ./resources/

for PGVERSION in "${PGVERSIONS[@]}"
do
  echo $PGVERSION

  # get data
  DATA_FILE=i2b2_$i2b2_VERSION_SHORT-postgres_dump-$PGVERSION.sql
  cp -r "../1.6.1 DB PostgreSQL Convert/data/$DATA_FILE" ./data/

  # settings
  sed -i "1s/.*/FROM floe\/postgres_citusdb_1.3:$PGVERSION/" Dockerfile
  #sed -i "1s/.*/FROM postgres:$PGVERSION/" Dockerfile

  # Build
  DOCKER_IMAGE=floe/i2b2-$i2b2_VERSION_SHORT-postgres:$PGVERSION
  docker build --tag=$DOCKER_IMAGE \
    --build-arg i2b2_VERSION=$i2b2_VERSION \
    --build-arg i2b2_VERSION_SHORT=$i2b2_VERSION_SHORT \
    --build-arg i2b2_PGVERSION=$PGVERSION \
    --rm=true .

  # clean
  rm -rf data/*
done





################################################################################
## re-load data to Storage Conatainer from SQL-dump-images

cd "$WORKDIR/1.6.2 DB PostgreSQL Import"

for PGVERSION in "${PGVERSIONS[@]}"
do
  echo $PGVERSION

  # get data
  DATA_FILE=i2b2_$i2b2_VERSION_SHORT-postgres_dump-$PGVERSION.sql

  # only original Demodata
  cp -r "../1.6.1 DB PostgreSQL Convert/data/$DATA_FILE" ./data/

  # Demodata + Demodata in 1 Schema + Project dexhelpp structure
  #cp -r "../7.1 Project DB/data/$DATA_FILE" ./data/

  # setting
  DOCKER_IMAGE=floe/i2b2-$i2b2_VERSION_SHORT-postgres:$PGVERSION
  DOCKER_CONTAINER=i2b2_$i2b2_VERSION_SHORT-postgres_load-$PGVERSION
  DOCKER_PG_STORAGE=i2b2_$i2b2_VERSION_SHORT-postgres_storage-$PGVERSION

  echo $DOCKER_IMAGE
  echo $DOCKER_CONTAINER
  echo $DOCKER_PG_STORAGE

  # Storage Container
  docker rm $DOCKER_PG_STORAGE
  docker create -it --name $DOCKER_PG_STORAGE \
    --volume /var/lib/postgresql \
    postgres:$PGVERSION echo "storage container: PostgreSQL $PGVERSION."

  docker run --name $DOCKER_CONTAINER -it --rm=true \
    -e "POSTGRES_PASSWORD=" \
    --volumes-from $DOCKER_PG_STORAGE \
    $DOCKER_IMAGE postgres --version \
    > $DOCKER_CONTAINER.log 2>&1
    # -it --rm=true # for debugging
    # -e "POSTGRES_USER=" -e "POSTGRES_PASSWORD="

done
