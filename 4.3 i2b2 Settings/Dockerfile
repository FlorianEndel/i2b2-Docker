FROM postgres:9.4

MAINTAINER Florian Endel <florian@endel.at>

ARG JBOSS_PORT=9090
ENV JBOSS_PORT=${JBOSS_PORT}

COPY resources/01_settings.sh /docker-entrypoint-initdb.d/
RUN chown postgres /docker-entrypoint-initdb.d/01_settings.sh

ENTRYPOINT ["/bin/bash"]
CMD ["/docker-entrypoint-initdb.d/01_settings.sh"]
