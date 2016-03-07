FROM floe/jboss_wildfly_ant1.9.6:10.0.0.CR4

MAINTAINER Florian Endel <florian@endel.at>

USER jboss

ARG AXIS_VERSION=1.6.3
ENV AXIS_VERSION=${AXIS_VERSION} \
    AXIS_FILE=axis2-$AXIS_VERSION-war.zip

# prepare
WORKDIR $JBOSS_HOME/standalone/deployments
RUN mkdir -p i2b2.war \
  && touch i2b2.war.dodeploy

WORKDIR /opt/

# Download Original from http://archive.apache.org/dist/axis/axis2
#RUN curl -O http://archive.apache.org/dist/axis/axis2/java/core/$AXIS_VERSION/$AXIS_FILE

# Download from i2b2
#RUN curl -O https://www.i2b2.org/software/projects/installer/axis2-1.6.2-war.zip

# Use loaded file
COPY resources/$AXIS_FILE ./

# Install
RUN unzip -q $AXIS_FILE -d axis2 \
  && unzip -q axis2/axis2.war -d $JBOSS_HOME/standalone/deployments/i2b2.war/ \
  \
# Clean
  && rm -r /opt/axis2 \
  && rm $AXIS_FILE


# Configure
# WORKDIR $JBOSS_HOME/standalone/deployments/i2b2.war/WEB-INF/conf
# sed -i 's/">30000</">60000<"/g' axis2.xml # ConfigContextTimeoutInterval
