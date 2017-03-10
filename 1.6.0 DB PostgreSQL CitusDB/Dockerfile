FROM postgres:9.4
MAINTAINER Florian Endel <florian@endel.at>

# https://github.com/citusdata/cstore_fdw
# https://github.com/heap/citus-docker

RUN apt-get update && \
  apt-get install -y \
    curl wget protobuf-c-compiler libprotobuf-c0-dev postgresql-server-dev-${PG_MAJOR} unzip build-essential && \
  apt-get autoremove -y && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/*


# install citus_fdw
WORKDIR /tmp

ARG CITUS_VERSION=1.4.1
ENV CITUS_VERSION=${CITUS_VERSION}

# https://github.com/citusdata/cstore_fdw/releases
RUN wget https://github.com/citusdata/cstore_fdw/archive/v${CITUS_VERSION}.zip && \
    unzip v${CITUS_VERSION}.zip && \
    rm v${CITUS_VERSION}.zip && \
    cd cstore_fdw-${CITUS_VERSION} && \
    make && make install && \
    cd .. && \
    rm -r cstore_fdw-${CITUS_VERSION}

ADD resources/01_citusdb.sh /docker-entrypoint-initdb.d/

# change data directory
# RUN mkdir /pgData
# ENV PGDATA /pgData
