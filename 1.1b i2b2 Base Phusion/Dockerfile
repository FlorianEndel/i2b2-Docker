FROM phusion/baseimage:0.9.17
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md#0917-release-date-2015-07-15

MAINTAINER Florian Endel <florian@endel.at>

ARG JAVA_VERSION=7

# RUN DEBIAN_FRONTEND=noninteractive \
#   && apt-get -qq -y update \
#   && apt-get -qq -y dist-upgrade \
#   && apt-get -qq -y install \
#     $JAVA_INSTALL \
#     xmlstarlet \
#     unzip \
#     postgresql-client

# Oracle Java 8 in Ubuntu 14.04
RUN apt-get -qq -y install \
  software-properties-common \
  && add-apt-repository ppa:webupd8team/java \
  && apt-get -qq -y update \
  && apt-get -qq -y dist-upgrade \
  && echo oracle-java$JAVA_VERSION-installer shared/accepted-oracle-license-v1-1 select true | \
    sudo /usr/bin/debconf-set-selections \
  && apt-get -qq -y  install \
    oracle-java$JAVA_VERSION-installer \
    xmlstarlet \
    unzip \
    postgresql-client \
    patch \
    r-base \
    r-base-dev \
  && update-java-alternatives -s java-$JAVA_VERSION-oracle

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
