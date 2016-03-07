FROM floe/jboss_wildfly:10.0.0.CR4

MAINTAINER Florian Endel <florian@endel.at>

USER jboss

ARG ANT_VERSION=1.9.6
ENV ANT_FILE=apache-ant-$ANT_VERSION-bin.tar.gz \
    ANT_HOME=/opt/ant

WORKDIR /opt
USER root

# Downlaod
#RUN curl -O http://www.us.apache.org/dist/ant/binaries/$ANT_FILE

# Use already loaded file (ADD would unpack)
COPY resources/$ANT_FILE ./

RUN chown -R jboss:jboss /opt/$ANT_FILE
USER jboss

# Install
RUN tar xf $ANT_FILE \
  && ln -s `pwd`/apache-ant-$ANT_VERSION $ANT_HOME \
  && rm $ANT_FILE

# System link
USER root
RUN sh -c "echo ANT_HOME=$ANT_HOME >> /etc/environment" \
  && ln -s $ANT_HOME/bin/ant /usr/bin/ant

USER jboss

#RUN ant -version
