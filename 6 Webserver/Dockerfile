FROM php:5.6-apache

MAINTAINER Florian Endel <florian@endel.at>

# Install Software & PHP Modules
RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update && \
    apt-get -qq dist-upgrade && \
    apt-get install -y -q \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libcurl4-gnutls-dev \
        unzip \
    && docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd curl \
    \
# Clean up APT
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure Apache
RUN echo "ServerName i2b2" | tee /etc/apache2/conf-available/servername.conf \
  && a2enconf servername

# Administration Module
ARG i2b2_VERSION=1.7.04
ARG i2b2_VERSION_SHORT=1704
ENV i2b2_SOURCE=/opt/i2b2
ENV i2b2_FILE=i2b2core-src-$i2b2_VERSION_SHORT.zip

ARG JBOSS_PORT=9090
ARG i2b2_HOST=i2b2

ARG HIVE_ID=i2b2demo
ARG HIVE_NAME=i2b2demo
# Defaults: i2b2demo


ENV HOME_WEBCLIENT=/var/www/html/webclient/ \
    HOME_WEBADMIN=/var/www/html/admin/

#################
## i2b2 Web Admin

WORKDIR $i2b2_SOURCE

# Installation
COPY resources/$i2b2_FILE ./
RUN unzip -q $i2b2_FILE \
  && cp -r admin /var/www/html/ \
  && rm -r *

WORKDIR ${HOME_WEBADMIN}

# Configuration
RUN sed -i "s#urlCellPM:.*#urlCellPM: 'http://$i2b2_HOST:$JBOSS_PORT/i2b2/services/PMService/',#g" i2b2_config_data.js

# Configurtion: Standards
RUN sed -i "s/domain:.*/domain: '$HIVE_ID',/g" i2b2_config_data.js \
  && sed -i "s/name:.*/name: '$HIVE_NAME',/g" i2b2_config_data.js \
  && sed -i "s/adminOnly:.*/adminOnly: true,/g" i2b2_config_data.js \
  && sed -i "s/debug:.*/debug: false/g" i2b2_config_data.js


#################
## i2b2 Web Client

WORKDIR $i2b2_SOURCE
ENV i2b2_FILE_WEBCLIENT=i2b2webclient-$i2b2_VERSION_SHORT.zip

# Installation
COPY resources/$i2b2_FILE_WEBCLIENT ./
RUN unzip -q $i2b2_FILE_WEBCLIENT \
  && mkdir -p ${HOME_WEBCLIENT} \
  && cp -r webclient/* ${HOME_WEBCLIENT} \
  && rm -r *

WORKDIR ${HOME_WEBCLIENT}

# Configuration
RUN sed -i "s#urlCellPM:.*#urlCellPM: 'http://$i2b2_HOST:$JBOSS_PORT/i2b2/services/PMService/',#g" i2b2_config_data.js

# Configurtion: Standards
RUN sed -i "s#urlProxy:.*#urlProxy: 'index.php',#g" i2b2_config_data.js \
  && sed -i "s#urlFramework:.*#urlFramework: 'js-i2b2/',#g" i2b2_config_data.js \
  && sed -i "s/domain:.*/domain: '$HIVE_ID',/g" i2b2_config_data.js \
  && sed -i "s/name:.*/name: '$HIVE_NAME',/g" i2b2_config_data.js \
  && sed -i "s/debug:.*/debug: false/g" i2b2_config_data.js

# Configure Security in PHP Proxy
# RUN sed -i "s/127.0.0.1/$i2b2_HOST/g" index.php \
#   && sed -i "s/9090/$JBOSS_PORT/g" index.php \
#   && sed -i 's#$pmURL = .*#$pmURL = "http://$i2b2_HOST:$JBOSS_PORT/i2b2/services/PMService/getServices";#g' index.php

# PHP Config
WORKDIR /usr/local/etc/php/
RUN echo 'error_log = /var/log/php-scripts.log' >> php.ini \
  && echo 'log_errors = On' >> php.ini \
  && echo 'error_reporting = E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED' >> php.ini \
  && echo 'display_errors = On' \
  # for ExportXLS
  && echo 'short_open_tag = On' >> php.ini


#########
## Patch 1.7.06

RUN \
  if  [ "$i2b2_VERSION" = '1.7.06' ] || \
      [ "$i2b2_VERSION" = '1.7.05' ]; then \
      cd ${HOME_WEBCLIENT}/js-i2b2/cells/plugins/standard/Dem1Set \
    && sed -i 's/+hData.toJSON()+/ + Object.toJSON(hData) +/g' Dem1Set_ctrlr.js \
    && cd ${HOME_WEBCLIENT}/js-i2b2/cells/plugins/standard/Dem2Set \
    && sed -i 's/+hData.toJSON()+/ + Object.toJSON(hData) +/g' Dem2Set_ctrlr.js; \
  fi



#########
## Plugin ExportXLS
# --> works only in 1.7.04

WORKDIR ${HOME_WEBCLIENT}

ENV i2b2_FILE_EXPORTXLS=ExportXLS-v3.3_20140423.zip
COPY resources/${i2b2_FILE_EXPORTXLS} ./
RUN unzip -q $i2b2_FILE_EXPORTXLS \
  && cp -r ExportXLS-v3.3/webclient/* ./ \
  && rm $i2b2_FILE_EXPORTXLS \
  && rm -r ExportXLS-v3.3 \
  && sed -i '/excanvas.js/a <script type=\"text/javascript\" src=\"js-ext/jquery-1.6.1.min.js\"></script>\n<script>\n\tvar \$j = jQuery.noConflict();\n</script>' default.htm \
  && sed -i '/ExampHello/i \\t\t{ code: "ExportXLS",\n\t\t\tforceLoading: true,\n\t\t\tforceConfigMsg: { params: [] },\n\t\t\tforceDir: "cells/plugins/standard"\n\t\t},' js-i2b2/i2b2_loader.js



#########
## Plugin GIRI

WORKDIR $i2b2_SOURCE

ENV CELL_GIRI=giri_i2b2_project_v1.1.zip
COPY resources/${CELL_GIRI} ./

RUN unzip -u -q $CELL_GIRI \
  && rm $CELL_GIRI \
  \
  # copy files
  && cd $i2b2_SOURCE/giri_i2b2_project_v1.1/GIRI_webclient_plugin/ \
  && cp -r GIRI ${HOME_WEBCLIENT}/js-i2b2/cells/ \
  && cp -r GIRIPlugin ${HOME_WEBCLIENT}/js-i2b2/cells/plugins/ \
  \
  # write access
  && cd ${HOME_WEBCLIENT}/js-i2b2 \
  && chmod -R 777 cells/plugins/GIRIPlugin/assets/ \
  && sed -i '/ExampHello/i \\n\n\t\t{ code: "GIRI"},\n\n\t\t{ code: "GIRIPlugin", \n\t\t\tforceLoading: true,\n\t\t\tforceConfigMsg: { params: [] },\n\t\t\troles: [ "DATA_LDS", "DATA_DEID", "DATA_PROT" ],\n\t\t\tforceDir: "cells/plugins"\n\t\t},' i2b2_loader.js



#########
## Plugin CARE Concept Demographic Histograms

WORKDIR ${HOME_WEBCLIENT}

ENV i2b2_FILE_CAREHIST=CAREcncptDem_v1.1_20150611.zip
COPY resources/${i2b2_FILE_CAREHIST} ./
RUN unzip -q ${i2b2_FILE_CAREHIST} \
  && cp -r CAREcncptDem/webclient/* ./ \
  && rm $i2b2_FILE_CAREHIST \
  && rm -r CAREcncptDem \
  #already registered by ExportXLS: && sed -i '/excanvas.js/a <script type=\"text/javascript\" src=\"js-ext/jquery-1.6.1.min.js\"></script>\n<script>\n\tvar \$j = jQuery.noConflict();\n</script>' default.htm \
  && sed -i '/ExampHello/i \\t\t{ code: "CAREcncptDem",\n\t\t\tforceLoading: true,\n\t\t\tforceConfigMsg: { params: [] },\n\t\t\tforceDir: "cells/plugins/standard"\n\t\t},' js-i2b2/i2b2_loader.js



#########
## Plugin CARE Concept Observation Tally Histograms

#WORKDIR ${HOME_WEBCLIENT}

ENV i2b2_FILE_CAREHIST=CAREobsTally_v1.1_20150611.zip
COPY resources/${i2b2_FILE_CAREHIST} ./
RUN unzip -q ${i2b2_FILE_CAREHIST} \
  && cp -r CAREobsTally/webclient/* ./ \
  && rm $i2b2_FILE_CAREHIST \
  && rm -r CAREobsTally \
  #already registered by ExportXLS: && sed -i '/excanvas.js/a <script type=\"text/javascript\" src=\"js-ext/jquery-1.6.1.min.js\"></script>\n<script>\n\tvar \$j = jQuery.noConflict();\n</script>' default.htm \
  && sed -i '/ExampHello/i \\t\t{ code: "CAREobsTally",\n\t\t\tforceLoading: true,\n\t\t\tforceConfigMsg: { params: [] },\n\t\t\tforceDir: "cells/plugins/standard"\n\t\t},' js-i2b2/i2b2_loader.js



#########
## Plugin WISE Annotator (Workplace Items Sharing Enhancement)

WORKDIR $i2b2_SOURCE

ENV i2b2_FILE_WISE_ANN=WISEannotator_v1.1_20120320.zip
COPY resources/${i2b2_FILE_WISE_ANN} ./
RUN unzip -q ${i2b2_FILE_WISE_ANN} \
  && cp -r $i2b2_SOURCE/WISEannotator ${HOME_WEBCLIENT}/js-i2b2/cells/plugins/standard/ \
  && rm -r WISEannotator* \
  \
  && cd ${HOME_WEBCLIENT} \
  && sed -i '/ExampHello/i \\t\t{ code: "WISEannotator",\n\t\t\tforceLoading: true,\n\t\t\tforceConfigMsg: { params: [] },\n\t\t\tforceDir: "cells/plugins/standard"\n\t\t},' js-i2b2/i2b2_loader.js



#########
## Plugin WISE Searcher (Workplace Items Sharing Enhancement)

WORKDIR $i2b2_SOURCE

ENV i2b2_FILE_WISE_SEARCH=WISEsearcher_v1.1_20120320.zip
COPY resources/${i2b2_FILE_WISE_SEARCH} ./
RUN unzip -q ${i2b2_FILE_WISE_SEARCH} \
  && cp -r $i2b2_SOURCE/export-files ${HOME_WEBCLIENT}/ \
  # /js-ext/jquery-1.6.1.min.js provided by ExportXLS
  && cp -r $i2b2_SOURCE/WISEsearcher ${HOME_WEBCLIENT}/js-i2b2/cells/plugins/standard/ \
  && rm -r WISEsearcher* \
  \
  && cd ${HOME_WEBCLIENT} \
  && sed -i '/ExampHello/i \\t\t{ code: "WISEsearcher",\n\t\t\tforceLoading: true,\n\t\t\tforceConfigMsg: { params: [] },\n\t\t\tforceDir: "cells/plugins/standard"\n\t\t},' js-i2b2/i2b2_loader.js
  # /js-ext/jquery-1.6.1.min.js registered by ExportXLS



#########
## Plugin IDRT Web Client Plugin

# WORKDIR $i2b2_SOURCE
# COPY resources/IDRT ./
# RUN  cp -r hiwi_webclient/webclient/js-i2b2/cells/plugins/idrt ${HOME_WEBCLIENT}/js-i2b2/cells/plugins/ \
#   && cp -r hiwi_webclient/webclient/js-i2b2/cells/plugins/examples/IDRTAdditionalData ${HOME_WEBCLIENT}/js-i2b2/cells/plugins/examples/ \
#   \
#   && cd ${HOME_WEBCLIENT} \
#   && sed -i '/ExampHello/i \\t\t{ code: "IdrtAdditionalData2",\n\t\t\tforceLoading: true,\n\t\t\tforceConfigMsg: { DefaultTab: 0 },\n\t\t\troles: [ "DATA_LDS", "DATA_DEID", "DATA_PROT" ],\n\t\t\tforceDir: "cells/plugins/idrt"\n\t\t},' js-i2b2/i2b2_loader.js
#


########
## debug
WORKDIR /var/www/html/debug
COPY resources/debug_curl.php ./
COPY resources/phpinfo.php ./


WORKDIR /var/www/html/

#
