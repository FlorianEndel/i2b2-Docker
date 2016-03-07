FROM floe/i2b2_base_centos:jdk8

MAINTAINER Florian Endel <florian@endel.at>

# Create User
RUN groupadd -r jboss -g 1000 \
  && useradd -u 1000 -r -g jboss -m -s /sbin/nologin jboss

USER jboss

# Variables
ARG WILDFLY_VERSION=10.0.0.CR2
ENV WILDFLY_FILE=wildfly-$WILDFLY_VERSION.tar.gz

ENV JBOSS_HOME=/opt/jboss
ARG JBOSS_PORT=9090
ARG JBOSS_PORT_AJP=9009
ARG JBOSS_LOG_LEVEL=INFO

# persistant ARGs
ENV \
  JBOSS_PORT=${JBOSS_PORT} \
  JBOSS_PORT_AJP=${JBOSS_PORT_AJP} \
  JBOSS_LOG_LEVEL=${JBOSS_LOG_LEVEL} \
  WILDFLY_VERSION=${WILDFLY_VERSION}


WORKDIR /opt
USER root

# Download from http://jbossas.jboss.org/downloads ...
#RUN curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz

# ... or use already loaded file (ADD would unpack)
COPY resources/$WILDFLY_FILE ./

RUN chown -R jboss:jboss /opt
USER jboss

# Install
RUN tar xf $WILDFLY_FILE \
  #&& mkdir -p `pwd`/jboss \
  && ln -s `pwd`/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
  && rm $WILDFLY_FILE


WORKDIR $JBOSS_HOME/standalone/configuration/
# JBoss Configuration: Port
RUN cp standalone.xml standalone.xml.orig && \
  xmlstarlet ed -u '//_:socket-binding[@name="http"]/@port' -v $JBOSS_PORT standalone.xml.orig | \
  xmlstarlet ed -u '//_:socket-binding[@name="ajp"]/@port' -v $JBOSS_PORT_AJP \
  > standalone.xml \
  && rm standalone.xml.orig \
  \
  # JBoss Log Level
  && cp standalone.xml standalone.xml.orig \
  && xmlstarlet ed -u '//_:*[@name="CONSOLE"]/*[local-name()="level"]/@name' -v $JBOSS_LOG_LEVEL standalone.xml.orig | \
    xmlstarlet ed -u '//_:*[name()="root-logger"]/*[local-name()="level"]/@name' -v $JBOSS_LOG_LEVEL \
  > standalone.xml \
  && rm standalone.xml.orig


# Expose
EXPOSE 9090 9009 9990

# Create User
RUN $JBOSS_HOME/bin/add-user.sh admin pass#0815 --silent

# Start server
CMD ["/opt/jboss/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
