WORKDIR=`pwd`
JBOSS_PORT=9090
JBOSS_PORT_AJP=9009
LOG_LEVEL=INFO # INFO, DEBUG, WARN, ERROR

i2b2_VERSION=1.7.06
i2b2_VERSION_SHORT=1706

# Set Ant Version [0='1.8.4', 1='1.9.6']
ANT_VERSIONS=( '1.8.4' '1.9.6' ) # 1.8.4 <-- i2b2
ANT_VERSION=${ANT_VERSIONS[1]}

# Set Axis2 Version [0='1.6.2', 1='1.6.3']
AXIS_VERSIONS=( '1.6.2' '1.6.3' ) # 1.6.2 <-- i2b2
AXIS_VERSION=${AXIS_VERSIONS[1]}

# PostgreSQL Database
PGVERSIONS=( '9.3' '9.4' )

# JBoss Wildfly
WILDFLY_VERSIONS=( '8.2.1.Final' '9.0.2.Final' '10.0.0.CR4' )



#######################
## Base Images with JDK
cd "$WORKDIR/1.1a i2b2 Base CentOS"
JAVA_CENTOS=( 'java-1.7.0-openjdk-devel' 'java-1.8.0-openjdk-devel' )

docker build --tag=floe/i2b2_base_centos:jdk7 \
  --build-arg JAVA_INSTALL=${JAVA_CENTOS[0]} --rm=true .

docker build --tag=floe/i2b2_base_centos:jdk8 \
  --build-arg JAVA_INSTALL=${JAVA_CENTOS[1]} --rm=true .


### PHUSION Oracle JDK
cd "$WORKDIR/1.1b i2b2 Base Phusion"
JAVA_ORACLE=( '7' '8' )

docker build --tag=floe/i2b2_base_phusion:jdk7 \
  --build-arg JAVA_VERSION=${JAVA_ORACLE[0]} --rm=true .

docker build --tag=floe/i2b2_base_phusion:jdk8 \
  --build-arg JAVA_VERSION=${JAVA_ORACLE[1]} --rm=true .


### UBUNTU OpenJDK
cd "$WORKDIR/1.1c i2b2 Base Ubuntu"
JAVA_UBUNTU=( 'openjdk-7-jdk' 'openjdk-8-jdk' )

docker build --tag=floe/i2b2_base_ubuntu:jdk7 \
  --build-arg JAVA_INSTALL=${JAVA_UBUNTU[0]} --rm=true .

docker build --tag=floe/i2b2_base_ubuntu:jdk8 \
  --build-arg JAVA_INSTALL=${JAVA_UBUNTU[1]} --rm=true .

# sed -i 's/JAVA_INSTALL=.*/JAVA_INSTALL=openjdk-8-jdk/g' Dockerfile
# docker build --tag=floe/i2b2_base_phusion:jdk8 --rm=true .



###############################
## JBoss AS Application Service
cd "$WORKDIR/1.2a JBoss AS"

docker build --tag=floe/jboss_as:7.1.1.Final \
  --build-arg JBOSS_PORT=${JBOSS_PORT} \
  --build-arg JBOSS_PORT_AJP=${JBOSS_PORT_AJP} \
  --build-arg JBOSS_LOG_LEVEL=${LOG_LEVEL} \
  --rm=true .

# docker run --name=jboss_as -it --rm=true -p 8080:$JBOSS_PORT -p 9999:9990 \
#   floe/jboss_as:7.1.1.Final
# http://127.0.0.1:8080

# JBoss Wildfly
cd "$WORKDIR/1.2b JBoss Wildfly"

for WILDFLY_VERSION in "${WILDFLY_VERSIONS[@]}"
do
  echo JBoss Wildfly: $WILDFLY_VERSION
  docker build --tag=floe/jboss_wildfly:$WILDFLY_VERSION \
    --build-arg JBOSS_PORT=$JBOSS_PORT \
    --build-arg JBOSS_PORT_AJP=$JBOSS_PORT_AJP \
    --build-arg JBOSS_LOG_LEVEL=$LOG_LEVEL \
    --build-arg WILDFLY_VERSION=$WILDFLY_VERSION \
    --rm=true .
done

# Test
# docker run --name=wildfly -it --rm=true -p 8080:$JBOSS_PORT -p 9990:9990  \
#   floe/jboss_wildfly:${WILDFLY_VERSIONS[2]}
# http://127.0.0.1:8080



#############
## Apache Ant
cd "$WORKDIR/1.3 Apache Ant"

# JBoss AS 7.1.1
sed -i "1s#floe.*#floe/jboss_as:7.1.1.Final#g" Dockerfile
docker build --tag=floe/jboss_as_ant$ANT_VERSION:7.1.1.Final \
  --build-arg ANT_VERSION=$ANT_VERSION \
  --rm=true .

# JBoss Wildfly
for WILDFLY_VERSION in "${WILDFLY_VERSIONS[@]}"
do
  echo JBoss Wildfly: $WILDFLY_VERSION, ANT: $ANT_VERSION

  sed -i "1s#floe.*#floe/jboss_wildfly:$WILDFLY_VERSION#g" Dockerfile
  docker build --tag=floe/jboss_wildfly_ant$ANT_VERSION:$WILDFLY_VERSION  \
    --build-arg ANT_VERSION=$ANT_VERSION \
    --rm=true .
done

# Test
# docker run --name=ant -it --rm=true \
#   floe/jboss_wildfly_ant$ANT_VERSION:${WILDFLY_VERSIONS[0]} ant -version



##############
## Apache Axis
cd "$WORKDIR/1.4 Apache Axis2"

# JBoss AS 7.1.1
sed -i "1s#floe.*#floe/jboss_as_ant$ANT_VERSION:7.1.1.Final#g" Dockerfile
docker build --tag=floe/jboss_as_axis$AXIS_VERSION:7.1.1.Final \
  --build-arg AXIS_VERSION=$AXIS_VERSION \
  --rm=true .

# JBoss Wildfly
for WILDFLY_VERSION in "${WILDFLY_VERSIONS[@]}"
do
    echo JBoss Wildfly: $WILDFLY_VERSION, ANT: $ANT_VERSION, AXIS2: $AXIS_VERSION

    sed -i "1s#floe.*#floe/jboss_wildfly_ant$ANT_VERSION:$WILDFLY_VERSION#g" Dockerfile
    docker build --tag=floe/jboss_wildfly_axis$AXIS_VERSION:$WILDFLY_VERSION \
      --build-arg AXIS_VERSION=$AXIS_VERSION \
      --rm=true .
done

# docker run --name=axis2 -it --rm=true -p 8080:$JBOSS_PORT -p 9999:9990 \
#   floe/jboss_wildfly_axis$AXIS_VERSION:${WILDFLY_VERSIONS[1]} /bin/bash
  # floe/jboss_as_axis$AXIS_VERSION:7.1.1.Final
# http://127.0.0.1:8080/i2b2/services/listServices



############
## i2b2 core
cd "$WORKDIR/4.1 i2b2 Server Common"

# set Axis Version
sed -i "1s#floe.*#floe/jboss_as_axis$AXIS_VERSION:7.1.1.Final#g" Dockerfile

# get sources
rm resources/i2b2core-src-*
cp ../Downloads/i2b2core-src-$i2b2_VERSION_SHORT.zip ./resources/
cp ../Configuration/* ./resources/Config/

# Build Application Server AS
DOCKER_IMAGE=floe/i2b2_core-as7.1.1.Final-axis$AXIS_VERSION:$i2b2_VERSION
DOCKER_IMAGE=$(echo $DOCKER_IMAGE | awk '{print tolower($0)}')

docker build --tag=$DOCKER_IMAGE \
  --build-arg i2b2_VERSION=$i2b2_VERSION \
  --build-arg i2b2_VERSION_SHORT=$i2b2_VERSION_SHORT \
  --build-arg DB_HOST=db \
  --rm=true .

# Build Wildfly
for WILDFLY_VERSION in "${WILDFLY_VERSIONS[@]}"
do
  DOCKER_IMAGE=floe/i2b2_core-wildfly$WILDFLY_VERSION-axis$AXIS_VERSION:$i2b2_VERSION
  DOCKER_IMAGE=$(echo $DOCKER_IMAGE | awk '{print tolower($0)}')
  echo $DOCKER_IMAGE

  sed -i "1s#floe.*#floe/jboss_wildfly_axis$AXIS_VERSION:$WILDFLY_VERSION#g" Dockerfile

  docker build --tag=$DOCKER_IMAGE \
    --build-arg i2b2_VERSION=$i2b2_VERSION \
    --build-arg i2b2_VERSION_SHORT=$i2b2_VERSION_SHORT \
    --build-arg DB_HOST=db \
    --rm=true .
done


#########
# publish

cd "$WORKDIR/4.1 i2b2 Server Common"




###############
## i2b2 Setting
# insert current Container IP in DB
cd "$WORKDIR/4.3 i2b2 Settings"

for PGVERSION in "${PGVERSIONS[@]}"
do
  echo $PGVERSION
  DOCKER_IMAGE=floe/i2b2$i2b2_VERSION_SHORT-setting_pg:$PGVERSION
  echo $DOCKER_IMAGE

  sed -i "1s/.*/FROM postgres:$PGVERSION/" Dockerfile

  docker build --tag=$DOCKER_IMAGE \
    --build-arg JBOSS_PORT=$JBOSS_PORT \
    --rm=true .
done


#########################
## Apache Webserver, PHP5
cd "$WORKDIR/6 Webserver"

# i2b2_VERSION=1.7.06
# i2b2_VERSION_SHORT=1706

# get files
rm resources/i2b2webclient-*
rm resources/i2b2core-src-*
cp ../Downloads/i2b2webclient-$i2b2_VERSION_SHORT.zip ./resources/
cp ../Downloads/i2b2core-src-$i2b2_VERSION_SHORT.zip ./resources/

docker build --tag=floe/i2b2_webserver:$i2b2_VERSION \
  --build-arg i2b2_VERSION=$i2b2_VERSION \
  --build-arg i2b2_VERSION_SHORT=$i2b2_VERSION_SHORT \
  --build-arg HIVE_ID=dexhelpp \
  --build-arg HIVE_NAME=dexhelpp \
  --build-arg i2b2_HOST=i2b2 \
  --build-arg JBOSS_PORT=$JBOSS_PORT \
  --rm=true .




################################################################################
## Run: DB
PGVERSION=9.4
DB_CONTAINER=i2b2_db

# from persistant image
PG_STORAGE=i2b2_$i2b2_VERSION_SHORT-postgres_storage-$PGVERSION
docker run -d --name $DB_CONTAINER \
  -p 127.0.0.1:5432:5432 \
  -e "POSTGRES_USER=postgres" -e "POSTGRES_PASSWORD=postgres" \
  --volumes-from $PG_STORAGE \
  floe/postgres_citusdb_1.3:$PGVERSION

# import SQL dump
docker run --name $DB_CONTAINER  -d \
  -p 127.0.0.1:5432:5432 \
  -e "POSTGRES_USER=postgres" -e "POSTGRES_PASSWORD=postgres" \
  floe/i2b2-$i2b2_VERSION_SHORT-postgres:$PGVERSION
# --> loading takes some time!!



## Run: i2b2 'native'
docker run --name=i2b2 -d -p 9090:$JBOSS_PORT -p 9990:9990 \
  --link $DB_CONTAINER:db \
  floe/i2b2_core-as7.1.1.final-axis$AXIS_VERSION:$i2b2_VERSION

  floe/i2b2_core-as7.1.1.final-axis1.6.2:1.7.06
  floe/i2b2_core-as7.1.1.final-axis1.6.3:$i2b2_VERSION
  floe/i2b2_core-wildfly8.2.1.final-axis1.6.2:1.7.06
  floe/i2b2_core-wildfly8.2.1.final-axis1.6.3:1.7.06
  floe/i2b2_core-wildfly9.0.2.final-axis1.6.2:1.7.04
  floe/i2b2_core-wildfly9.0.2.final-axis1.6.3:1.7.06
  floe/i2b2_core-wildfly10.0.0.cr4-axis1.6.2:1.7.06
  floe/i2b2_core-wildfly10.0.0.cr4-axis1.6.3:1.7.06

# docker inspect i2b2 | grep IPAddress
# docker exec -it i2b2 /bin/bash
# http://localhost:8080/i2b2/services/listServices



## Run: i2b2 'foreign'
# load installation as offline data-volume
# --> mount volume & run server from other image

# example for AS / JDK 7
docker run --name=i2b2_vol -d \
  floe/i2b2_core-as7.1.1.final-axis1.6.3:1.7.06 true

docker run --name=i2b2 -d -p 9090:$JBOSS_PORT -p 9990:9990 \
  --link $DB_CONTAINER:db \
  --volumes-from=i2b2_vol \
  floe/i2b2_base_ubuntu:jdk7 \
  /opt/jboss/as/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0

# example for Wildfly / JDK 8
docker run --name=i2b2_vol -d \
  floe/i2b2_core-wildfly10.0.0.cr2-axis1.6.3:1.7.06 true

docker run --name=i2b2 -d -p 9090:$JBOSS_PORT -p 9990:9990 \
  --link $DB_CONTAINER:db \
  --volumes-from=i2b2_vol \
  floe/i2b2_base_phusion:jdk8 \
  /opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0



## Run: i2b2 DB config
# get IPs from linked container or Environment Variables
IMAGE_SETTING=floe/i2b2$i2b2_VERSION_SHORT-setting_pg:$PGVERSION
docker run -it --rm=true --name i2b2_db_settings \
  -e "HIVE_ID=dexhelpp" \
  -e "JBOSS_PORT=$JBOSS_PORT" \
  -e "PGPASSWORD=postgres" \
  --link i2b2_i2b2_1:i2b2 \
  --link i2b2_i2b2_db_1:db \
  $IMAGE_SETTING
  #-e "PG_IP=172.17.0.2" \ --> to connect to the database
  #-e "i2b2_IP=172.17.0.3" \ --> to set i2b2 IP in configuration



## Run: Webserver
docker run -p 80:80 -d --name i2b2_web \
  --link i2b2:i2b2 \
  --volumes-from=i2b2 \
  floe/i2b2_webserver:1.7.04
# Current: $i2b2_VERSION
# Everything working: 1.7.04


## STOP
docker stop i2b2_web && docker rm i2b2_web
docker stop i2b2 && docker rm i2b2
#docker rm i2b2_vol
docker stop $DB_CONTAINER && docker rm $DB_CONTAINER


#############################3
## docker-compose

PGVERSION=9.4
JBOSS_PORT=9090
i2b2_VERSION=1.7.06
i2b2_VERSION_SHORT=1706
DB_HOST=

export PGVERSION JBOSS_PORT i2b2_VERSION i2b2_VERSION_SHORT DB_HOST

docker-compose up -d

# http://127.0.0.1:9090/i2b2/services/listServices
# http://localhost:9000/
# http://localhost:8080/
# localhost/webclient
# localhost/admin


##########
## plugin - Test

cd "$WORKDIR/4.x i2b2 Server Testing"

docker build --tag=i2b2_plugin:1.7.04 --rm=true .


docker run --name=i2b2 -d -p 9090:$JBOSS_PORT -p 9990:9990 \
  --link $DB_CONTAINER:db \
  i2b2_plugin:1.7.04


#
