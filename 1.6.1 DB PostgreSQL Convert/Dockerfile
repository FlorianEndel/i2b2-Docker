FROM floe/postgres_citusdb_1.3:9.4

MAINTAINER Florian Endel <florian@endel.at>


#RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
#ENV LANG en_EN.utf8

# Install packages
RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update \
  && apt-get install -q -y \
    unzip \
    curl \
    openjdk-7-jdk \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


######
## ANT
######

ARG ANT_VERSION=1.9.6
ENV ANT_HOME /opt/ant

USER root

WORKDIR /tmp

# Downlaod
RUN curl -O http://www.us.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz

# Use already loaded file (ADD would unpack)
#COPY apache-ant-$ANT_VERSION-bin.tar.gz ./

# install
RUN tar xf apache-ant-$ANT_VERSION-bin.tar.gz \
  && mv /tmp/apache-ant-$ANT_VERSION /opt \
  && ln -s /opt/apache-ant-$ANT_VERSION $ANT_HOME \
  && rm apache-ant-$ANT_VERSION-bin.tar.gz

# link
RUN sh -c 'echo ANT_HOME=/opt/ant >> /etc/environment' \
  && ln -s /opt/ant/bin/ant /usr/bin/ant

#RUN ant -version


#######
## i2b2
#######

ARG i2b2_VERSION=1.7.06
ARG i2b2_VERSION_SHORT=1706

ENV i2b2_VERSION=${i2b2_VERSION} \
    i2b2_VERSION_SHORT=${i2b2_VERSION_SHORT}

# i2b2 data
WORKDIR /opt/data

COPY resources/i2b2createdb-$i2b2_VERSION_SHORT.zip ./

RUN unzip -q i2b2createdb-$i2b2_VERSION_SHORT.zip \
  && rm i2b2createdb-$i2b2_VERSION_SHORT.zip

ENV i2b2_DATA  "/opt/data/edu.harvard.i2b2.data/Release_1-7/NewInstall"


COPY resources/*.conf /docker-entrypoint-initdb.d/
# COPY resources/db.properties.crcdata ./Crcdata/db.properties
# COPY resources/db.properties.hivedata ./Hivedata/db.properties
# COPY resources/db.properties.imdata ./Imdata/db.properties
# COPY resources/db.properties.metadata ./Metadata/db.properties
# COPY resources/db.properties.pmdata ./Pmdata/db.properties
# COPY resources/db.properties.workdata ./Workdata/db.properties

# i2b2 DB, USER, SCHEMA
COPY resources/*.sh /docker-entrypoint-initdb.d/
# COPY resources/10_configuration.sh /docker-entrypoint-initdb.d/
# COPY resources/11_prepare.sh /docker-entrypoint-initdb.d/
# COPY resources/12_data.sh /docker-entrypoint-initdb.d/
# COPY resources/13_setup.sh /docker-entrypoint-initdb.d/
# COPY resources/14_dump.sh /docker-entrypoint-initdb.d/
