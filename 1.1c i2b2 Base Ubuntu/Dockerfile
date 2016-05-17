FROM ubuntu:16.04

MAINTAINER Florian Endel <florian@endel.at>

ARG JAVA_INSTALL=openjdk-7-jdk

RUN DEBIAN_FRONTEND=noninteractive \
  && apt-get -qq -y update \
  && apt-get -qq -y dist-upgrade \
  && apt-get -qq -y install \
    $JAVA_INSTALL \
    xmlstarlet \
    unzip \
    postgresql-client \
    patch \
    r-base \
    r-base-dev

# TODO. check openssh in phusion

# Oracle Java 8 in Ubuntu 14.04
# RUN apt-get -qq -y install \
#   software-properties-common \
#   && add-apt-repository ppa:webupd8team/java \
#   && apt-get -qq -y update && \
#   && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | \
#     sudo /usr/bin/debconf-set-selections \
#   && apt-get -qq -y install oracle-java8-installer \
#   && update-java-alternatives -s java-8-oracle

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
