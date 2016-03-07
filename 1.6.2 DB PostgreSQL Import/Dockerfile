FROM floe/postgres_citusdb_1.3:9.4

MAINTAINER Florian Endel <florian@endel.at>

#######
## i2b2
#######

ARG i2b2_PGVERSION=9.4
ARG i2b2_VERSION=1.7.06
ARG i2b2_VERSION_SHORT=1706

ENV i2b2_VERSION=${i2b2_VERSION} \
    i2b2_VERSION_SHORT=${i2b2_VERSION_SHORT}

# i2b2 data
WORKDIR /opt/data

COPY data/i2b2_$i2b2_VERSION_SHORT-postgres_dump-${i2b2_PGVERSION}.sql ./data.sql
#COPY data/i2b2_1706_postgres91_vmware.sql ./data.sql

# i2b2 DB, USER, SCHEMA

COPY resources/10_configure.sh /docker-entrypoint-initdb.d/
COPY resources/11_prepare.sh /docker-entrypoint-initdb.d/
COPY resources/12_load.sh /docker-entrypoint-initdb.d/

COPY resources/*.conf /docker-entrypoint-initdb.d/

###########
## Clean up
###########

#APT
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
