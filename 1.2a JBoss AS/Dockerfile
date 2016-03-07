FROM floe/i2b2_base_centos:jdk7
#FROM floe/i2b2_base_phusion:jdk7

MAINTAINER Florian Endel <florian@endel.at>

# Create User
RUN groupadd -r jboss -g 1000 \
  && useradd -u 1000 -r -g jboss -m -s /sbin/nologin jboss

USER jboss

# Variables
ENV JBOSS_AS_VERSION jboss-as-7.1.1.Final
ENV JBOSS_AS_FILE $JBOSS_AS_VERSION.zip

ENV JBOSS_HOME=/opt/jboss

# --build-arg
ARG JBOSS_PORT=9090
ARG JBOSS_PORT_AJP=9009
ARG JBOSS_LOG_LEVEL=INFO

# persistant ARGs
ENV \
  JBOSS_PORT=${JBOSS_PORT} \
  JBOSS_PORT_AJP=${JBOSS_PORT_AJP} \
  JBOSS_LOG_LEVEL=${JBOSS_LOG_LEVEL}

WORKDIR /opt
USER root

# Download from http://jbossas.jboss.org/downloads ...
#RUN curl -O http://download.jboss.org/jbossas/7.1/$JBOSS_AS_VERSION/$JBOSS_AS_FILE

# ... or use loaded file
COPY resources/$JBOSS_AS_FILE ./

RUN chown -R jboss:jboss /opt
USER jboss

# Install
RUN unzip -q $JBOSS_AS_FILE \
  && ln -s `pwd`/$JBOSS_AS_VERSION $JBOSS_HOME \
  && rm $JBOSS_AS_FILE

WORKDIR $JBOSS_HOME/standalone/configuration/
# JBoss Configuration: Port
RUN cp standalone.xml standalone.xml.orig && \
  xmlstarlet ed -u '//_:socket-binding[@name="http"]/@port' -v $JBOSS_PORT standalone.xml.orig | \
  xmlstarlet ed -u '//_:socket-binding[@name="ajp"]/@port' -v $JBOSS_PORT_AJP \
  > standalone.xml \
  && rm standalone.xml.orig \
  \
  # JBoss Log Level
  && cp standalone.xml standalone.xml.orig && \
  xmlstarlet ed -u '//*[@name="CONSOLE"]/*[local-name()="level"]/@name' -v $JBOSS_LOG_LEVEL standalone.xml.orig | \
    xmlstarlet ed -u '//*[name()="root-logger"]/*[local-name()="level"]/@name' -v $JBOSS_LOG_LEVEL \
  > standalone.xml \
  && rm standalone.xml.orig

# TESTING: use standalone.xml from i2b2 Demo VM
# RUN mv standalone.xml standalone.xml.orig
# COPY resources/standalone_i2b2_vm.xml ./

# Expose
EXPOSE 9090 9009 9990

# Create User
#RUN $JBOSS_HOME/bin/add-user.sh admin pass#0815 --silent # --> ERROR

# Start server
CMD ["/opt/jboss/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
