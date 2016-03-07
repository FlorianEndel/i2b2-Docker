FROM floe/jboss_wildfly_axis1.6.3:10.0.0.CR4

MAINTAINER Florian Endel <florian@endel.at>

USER jboss

ARG i2b2_VERSION=1.7.06
ARG i2b2_VERSION_SHORT=1706
ARG i2b2_TRANS_TIMEOUT=1200
ENV i2b2_SOURCE=/opt/i2b2
ENV i2b2_FILE=i2b2core-src-$i2b2_VERSION_SHORT.zip

# DB Configuration
ARG DB_HOST=db
ENV CON_URL=jdbc:postgresql://$DB_HOST:5432/i2b2 \
    DB_DRIVER_CLASS=org.postgresql.Driver \
    DB_DRIVER=postgresql-9.4-1204.jdbc4.jar \
    DB_DRIVER_OLD=postgresql-9.2-1002.jdbc4.jar \
    #
    DB_HOST=${DB_HOST} \
    i2b2_VERSION=${i2b2_VERSION} \
    i2b2_VERSION_SHORT=${i2b2_VERSION_SHORT}

############
## i2b2 core

WORKDIR $i2b2_SOURCE
COPY resources/* ./


ENV \
  i2b2_db_user_HIVE=i2b2hive \
  i2b2_db_pass_HIVE=demouser \
  i2b2_db_schema_HIVE=i2b2hive \
  \
  i2b2_db_user_PM=i2b2pm \
  i2b2_db_pass_PM=demouser \
  i2b2_db_schema_PM=i2b2pm \
  \
  i2b2_AGGSERVICE_user=AGG_SERVICE_ACCOUNT \
  i2b2_AGGSERVICE_pass=demouser \
  \
  db_project=demo \
  \
  i2b2_db_user_CRC=i2b2demodata \
  i2b2_db_pass_CRC=demouser \
  i2b2_db_schema_CRC=i2b2demodata \
  \
  i2b2_db_user_ONT=i2b2metadata \
  i2b2_db_pass_ONT=demouser \
  i2b2_db_schema_ONT=i2b2metadata \
  \
  i2b2_db_user_WORK=i2b2workdata \
  i2b2_db_pass_WORK=demouser \
  i2b2_db_schema_WORK=i2b2workdata \
  \
  i2b2_db_user_IM=i2b2imdata \
  i2b2_db_pass_IM=demouser \
  i2b2_db_schema_IM=i2b2imdata

USER root
RUN chown -R jboss:jboss $i2b2_SOURCE
USER jboss

RUN unzip -q $i2b2_FILE \
  && rm -r $i2b2_FILE \
  # move config files
  && mkdir Config \
  && mv *.conf Config/ \
  # make scripts executable
  && chmod +x *.sh

WORKDIR $i2b2_SOURCE/edu.harvard.i2b2.server-common

# PostgreSQL JDBC Driver
RUN rm ./lib/jdbc/${DB_DRIVER_OLD} \
  && sed -i "s#${DB_DRIVER_OLD}#${DB_DRIVER}#g" build.xml \
  && cp ${i2b2_SOURCE}/${DB_DRIVER} ./lib/jdbc/

# Build i2b2 core
RUN sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
  \
  && ant clean dist deploy jboss_pre_deployment_setup


##########################
## Cell Project Management PM

WORKDIR $i2b2_SOURCE/edu.harvard.i2b2.pm
RUN sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
\
# Configure DB
  && cd $i2b2_SOURCE/edu.harvard.i2b2.pm/etc/jboss \
  && mv pm-ds.xml pm-ds.xml.orig && \
  XML_SCHEMA="ds=http://www.jboss.org/ironjacamar/schema" && \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:connection-url" -v $CON_URL pm-ds.xml.orig | \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver-class" -v $DB_DRIVER_CLASS | \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver" -v $DB_DRIVER | \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:user-name" -v $i2b2_db_user_PM | \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:password" -v $i2b2_db_pass_PM \
  > pm-ds.xml \
  && rm pm-ds.xml.orig \
\
# Deploy Cell
  && cd $i2b2_SOURCE/edu.harvard.i2b2.pm \
  && ant -f master_build.xml clean build-all deploy


################
## Cell Ontology ONT

WORKDIR $i2b2_SOURCE/edu.harvard.i2b2.ontology
RUN sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
\
# Configure Cells
  && cd $i2b2_SOURCE/edu.harvard.i2b2.ontology/etc/spring/ \
  && sed -i "s#applicationdir=.*#applicationdir=$JBOSS_HOME/standalone/configuration/ontologyapp#g" ontology_application_directory.properties \
  \
  && sed -i "s/ontology.bootstrapdb.metadataschema=.*/ontology.bootstrapdb.metadataschema=$i2b2_db_schema_HIVE/g" ontology.properties \
  && sed -i "s#http://localhost:9090#http://localhost:$JBOSS_PORT#g" ontology.properties \
  && sed -i "s/edu.harvard.i2b2.ontology.pm.serviceaccount.user=.*/edu.harvard.i2b2.ontology.pm.serviceaccount.user=$i2b2_AGGSERVICE_user/g" ontology.properties \
  && sed -i "s/edu.harvard.i2b2.ontology.pm.serviceaccount.password=.*/edu.harvard.i2b2.ontology.pm.serviceaccount.password=$i2b2_AGGSERVICE_pass/g" ontology.properties \
  && sed -i "s/Ontology.terminal.delimiter=.*/Ontology.terminal.delimiter=true/g" ontology.properties \
\
# Configure DB
  && cd $i2b2_SOURCE/edu.harvard.i2b2.ontology/etc/jboss \
  && mv ont-ds.xml ont-ds.xml.orig && \
  XML_SCHEMA="ds=http://www.jboss.org/ironjacamar/schema" && \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:connection-url" -v $CON_URL ont-ds.xml.orig | \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver-class" -v $DB_DRIVER_CLASS | \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver" -v $DB_DRIVER | \
  xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:user-name)[1]" -v $i2b2_db_user_ONT | \
  xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:password)[1]" -v $i2b2_db_pass_ONT | \
  xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:user-name)[2]" -v  $i2b2_db_user_HIVE | \
  xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:password)[2]" -v $i2b2_db_pass_HIVE \
  > ont-ds.xml \
  && rm ont-ds.xml.orig \
\
# Deploy Cell
  && cd $i2b2_SOURCE/edu.harvard.i2b2.ontology \
  && ant -f master_build.xml clean build-all deploy



#######################
## Cell Data Repository CRC

WORKDIR $i2b2_SOURCE/edu.harvard.i2b2.crc

RUN \
# CRC Patch
  cp ${i2b2_SOURCE}/TablePdoQueryConceptDao.patch ./src/server/edu/harvard/i2b2/crc/dao/pdo/ \
  && cd ./src/server/edu/harvard/i2b2/crc/dao/pdo/ \
  && patch < TablePdoQueryConceptDao.patch \
  && cd $i2b2_SOURCE/edu.harvard.i2b2.crc \
\
  && sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
\
# Configure Cells
  && cd $i2b2_SOURCE/edu.harvard.i2b2.crc/etc/spring/ \
  && sed -i "s#applicationdir=.*#applicationdir=$JBOSS_HOME/standalone/configuration/crcapp#g" crc_application_directory.properties \
  && sed -i "s#http://localhost:9090#http://localhost:$JBOSS_PORT#g" edu.harvard.i2b2.crc.loader.properties \
\
  && mv CRCLoaderApplicationContext.xml CRCLoaderApplicationContext.xml.orig && \
  xmlstarlet ed -u '//property[@name="driverClassName"]/@value' -v $DB_DRIVER_CLASS CRCLoaderApplicationContext.xml.orig | \
  xmlstarlet ed -u '//property[@name="url"]/@value' -v $CON_URL | \
  xmlstarlet ed -u '//property[@name="username"]/@value' -v $i2b2_db_user_HIVE | \
  xmlstarlet ed -u '//property[@name="password"]/@value' -v $i2b2_db_pass_HIVE \
  > CRCLoaderApplicationContext.xml \
  && rm CRCLoaderApplicationContext.xml.orig \
\
  && sed -i "s/edu.harvard.i2b2.crc.loader.ds.lookup.servertype=.*/edu.harvard.i2b2.crc.loader.ds.lookup.servertype=PostgreSQL/g" edu.harvard.i2b2.crc.loader.properties \
  && sed -i "s#http://localhost:9090#http://localhost:$JBOSS_PORT#g" crc.properties \
  && sed -i "s/queryprocessor.ds.lookup.servertype=.*/queryprocessor.ds.lookup.servertype=PostgreSQL/g" crc.properties \
\
# Configure DB
  && cd $i2b2_SOURCE/edu.harvard.i2b2.crc/etc/jboss \
  && mv crc-ds.xml crc-ds.xml.orig && \
  XML_SCHEMA="ds=http://www.jboss.org/ironjacamar/schema" && \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:connection-url" -v $CON_URL crc-ds.xml.orig | \
    xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver-class" -v $DB_DRIVER_CLASS | \
    xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver" -v $DB_DRIVER | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:user-name)[1]" -v $i2b2_db_user_HIVE | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:password)[1]" -v $i2b2_db_pass_HIVE | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:user-name)[2]" -v $i2b2_db_user_CRC | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:password)[2]" -v $i2b2_db_pass_CRC \
  > crc-ds.xml \
  && rm crc-ds.xml.orig \
\
# Deploy Cell
  && cd $i2b2_SOURCE/edu.harvard.i2b2.crc \
  && ant -f master_build.xml clean build-all deploy



#################
## Cell Workplace WORK

WORKDIR $i2b2_SOURCE/edu.harvard.i2b2.workplace
RUN sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
\
# Configure Cells
  && cd $i2b2_SOURCE/edu.harvard.i2b2.workplace/etc/spring/ \
  && sed -i "s#applicationdir=.*#applicationdir=$JBOSS_HOME/standalone/configuration/workplaceapp#g" workplace_application_directory.properties \
  && sed -i "s#http://localhost:9090#http://localhost:$JBOSS_PORT#g" workplace.properties \
  && sed -i "s/workplace.bootstrapdb.metadataschema=.*/workplace.bootstrapdb.metadataschema=$i2b2_db_schema_HIVE/g" workplace.properties \
\
# Configure DB
  && cd $i2b2_SOURCE/edu.harvard.i2b2.workplace/etc/jboss \
  && mv work-ds.xml work-ds.xml.orig && \
  XML_SCHEMA="ds=http://www.jboss.org/ironjacamar/schema" && \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:connection-url" -v $CON_URL work-ds.xml.orig | \
    xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver-class" -v $DB_DRIVER_CLASS | \
    xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver" -v $DB_DRIVER | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:user-name)[1]" -v $i2b2_db_user_HIVE | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:password)[1]" -v $i2b2_db_pass_HIVE | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:user-name)[2]" -v $i2b2_db_user_WORK | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:password)[2]" -v $i2b2_db_pass_WORK \
  > work-ds.xml \
  && rm work-ds.xml.orig \
\
# Deploy Cell
  && cd $i2b2_SOURCE/edu.harvard.i2b2.workplace \
  && ant -f master_build.xml clean build-all deploy



######################
## Cell Filerepository FR

WORKDIR $i2b2_SOURCE/edu.harvard.i2b2.fr
RUN sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
\
# Configure Cells
  && cd $i2b2_SOURCE/edu.harvard.i2b2.fr/etc/spring/ \
  && sed -i "s#applicationdir=.*#applicationdir=$JBOSS_HOME/standalone/configuration/frapp#g" fr_application_directory.properties \
  && sed -i "s#http://localhost:9090#http://localhost:$JBOSS_PORT#g" edu.harvard.i2b2.fr.properties \
\
# Deploy Cell
  && cd $i2b2_SOURCE/edu.harvard.i2b2.fr \
  && ant -f master_build.xml clean build-all deploy



###########################
## Cell Identity Management IM

WORKDIR $i2b2_SOURCE/edu.harvard.i2b2.im
RUN sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
\
# Configure Cells
  && cd $i2b2_SOURCE/edu.harvard.i2b2.im/etc/spring/ \
  && sed -i "s#applicationdir=.*#applicationdir=$JBOSS_HOME/standalone/configuration/imapp#g" im_application_directory.properties \
  && sed -i "s#http://localhost:9090#http://localhost:$JBOSS_PORT#g" im.properties \
  && sed -i "s/im.checkPatientInProject=.*/im.checkPatientInProject=true/g" im.properties \
\
# Configure DB
  && cd ${i2b2_SOURCE}/edu.harvard.i2b2.im/etc/jboss \
  && mv im-ds.xml im-ds.xml.orig && \
  XML_SCHEMA="ds=http://www.jboss.org/ironjacamar/schema" && \
  xmlstarlet ed -N $XML_SCHEMA  -u "//ds:connection-url" -v $CON_URL im-ds.xml.orig | \
    xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver-class" -v $DB_DRIVER_CLASS | \
    xmlstarlet ed -N $XML_SCHEMA  -u "//ds:driver" -v $DB_DRIVER | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:user-name)[1]" -v $i2b2_db_user_HIVE | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:password)[1]" -v $i2b2_db_pass_HIVE | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:user-name)[2]" -v $i2b2_db_user_IM | \
    xmlstarlet ed -N $XML_SCHEMA  -u "(//ds:password)[2]" -v $i2b2_db_pass_IM \
  > im-ds.xml \
  && rm im-ds.xml.orig \
\
# Deploy Cell
  && cd ${i2b2_SOURCE}/edu.harvard.i2b2.im \
  && ant -f master_build.xml clean build-all deploy



################################
## Additional Cell Patient Count
# --> Installation Guide erroneous!

ENV CELL_PAT_COUNT=i2b2crcplugin-patientcount-17.zip

WORKDIR $i2b2_SOURCE

RUN unzip -u -q $CELL_PAT_COUNT \
  && rm $CELL_PAT_COUNT \
  \
  && cd ${i2b2_SOURCE}/edu.harvard.i2b2.crcplugin.patientcount/etc/spring \
\
  # step 2 b: patientcount_application_directory.properties
  && sed -i 's#crcplugin.pb.applicationdir=.*#crcplugin.pb.applicationdir=$JBOSS_HOME/standalone/configuration/crcapp/#g' patientcount_application_directory.properties \
\
  # step 2 d, 6: edu.harvard.i2b2.crcplugin.pb.properties
  && sed -i 's#http://localhost:9090#http://localhost:$JBOSS_PORT#g' edu.harvard.i2b2.crcplugin.pb.properties \
  \
  # step 5
  && sed -i "s/datasource=.*/datasource=PBBootStrapDS/g" edu.harvard.i2b2.crcplugin.pb.properties \
  && sed -i "s/servertype=.*/servertype=PostgreSQL/g" edu.harvard.i2b2.crcplugin.pb.properties \
  && sed -i "s/schemaname=.*/schemaname=$i2b2_db_schema_HIVE/g" edu.harvard.i2b2.crcplugin.pb.properties \
  \
  # step 7 a
  && sed -i "s/serviceaccount.user=.*/serviceaccount.user=$i2b2_AGGSERVICE_user/g" edu.harvard.i2b2.crcplugin.pb.properties \
  && sed -i "s/serviceaccount.password=.*/serviceaccount.password=$i2b2_AGGSERVICE_pass/g" edu.harvard.i2b2.crcplugin.pb.properties \
\
  # step 4: PatientCountApplicationContext.xml
  && mv PatientCountApplicationContext.xml tmp.xml && \
  xmlstarlet ed -u '//*[@id="PBBootStrapDS"]/*[@name="driverClassName"]/@value' -v $DB_DRIVER_CLASS tmp.xml | \
  xmlstarlet ed -u '//*[@id="PBBootStrapDS"]/*[@name="url"]/@value' -v $CON_URL | \
  xmlstarlet ed -u '//*[@id="PBBootStrapDS"]/*[@name="username"]/@value' -v $i2b2_db_user_HIVE | \
  xmlstarlet ed -u '//*[@id="PBBootStrapDS"]/*[@name="password"]/@value' -v $i2b2_db_pass_HIVE | \
  \
  # step 7 b
  xmlstarlet ed -u '//*[@id="QueryToolDemoDS"]/*[@name="driverClassName"]/@value' -v $DB_DRIVER_CLASS | \
  xmlstarlet ed -u '//*[@id="QueryToolDemoDS"]/*[@name="url"]/@value' -v $CON_URL | \
  xmlstarlet ed -u '//*[@id="QueryToolDemoDS"]/*[@name="username"]/@value' -v $i2b2_db_user_CRC | \
  xmlstarlet ed -u '//*[@id="QueryToolDemoDS"]/*[@name="password"]/@value' -v $i2b2_db_pass_CRC \
  > PatientCountApplicationContext.xml \
\
# 2.3 Build and Deploy
  # 1.
  && cd $i2b2_SOURCE/edu.harvard.i2b2.server-common \
  && ant dist \
  && cd $i2b2_SOURCE/edu.harvard.i2b2.crcplugin.patientcount \
  \
  # 2 b
  && sed -i 's#crcplugin.home=.*#crcplugin.home=$JBOSS_HOME/standalone/configuration/crcapp/#g' build.properties \
  && sed -i 's#jboss.home=.*#jboss.home=$JBOSS_HOME#g' build.properties \
  \
  # 2 c, d
  && ant setup_launcher_folder \
  && ant deploy




#########################
## Additional Cell R GIRI

USER root

# Install R
# RUN yum update -y \
#   && yum upgrade -y \
#   && yum install -y \
#     R-core \
#     R-core-devel \
#   && yum clean all \

# Configure R & install packages
RUN R_VERSION=`Rscript -e "cat(paste(getRversion()))"` \
  && mkdir -p /usr/share/doc/R-${R_VERSION}/html \
  && R CMD javareconf \
  && Rscript -e 'install.packages(c("rJava",  \
      "survival", \
      "xtable", \
      "splines" \
  ), repos="https://cran.rstudio.com")'

# test rJava
#RUN Rscript -e 'library(rJava); .jinit(); s <- .jnew("java/lang/String", "Hello World!"); .jcall(s,"I","length");' # --> [1] 12

RUN mkdir -p /var/www/html/ \
  && chown jboss:jboss /var/www/html

USER jboss


WORKDIR $i2b2_SOURCE

ENV CELL_GIRI=giri_i2b2_project_v1.1.zip

# RUN cd $JAVA_HOME/jre/lib/amd64/server \
#   && ls -lh \
#   && find . -name libjvm

RUN unzip -u -q $CELL_GIRI \
  && rm $CELL_GIRI \
  && cd $i2b2_SOURCE/giri_i2b2_project_v1.1/GIRI_cell/de.erlangen.i2b2.giri/ \
  \
  # recompile JRI
  # && ln -s $JAVA_HOME/jre/lib/amd64/server/libjvm.so /lib64/libjvm.so \
  # && cd ./etc/JRI/ \
  # && ./configure \
  # && make \
  # && cd ../..
  # && cp ./etc/JRI/libjri.so ./lib/ \
  \
  # use JRI from rJava package
  && cp /usr/lib64/R/library/rJava/jri/libjri.so ./lib/ \
  \
  # setup script directory
  && GIRI_SCRIPT=/opt/GIRI_Script \
  && mkdir -p $GIRI_SCRIPT \
  && cd $i2b2_SOURCE/giri_i2b2_project_v1.1/GIRIScriptletExamples/ \
  && cp -r ./* $GIRI_SCRIPT \
  \
  # setup Web-Directory
  && GIRI_WEBDIR=/var/www/html/webclient/js-i2b2/cells/plugins/ \
  && mkdir -p $GIRI_WEBDIR \
  && cd $GIRI_WEBDIR \
  && cp -r $i2b2_SOURCE/giri_i2b2_project_v1.1/GIRI_webclient_plugin/GIRIPlugin ./ \
  && chown -R jboss:jboss ./* \
  && chmod -R 777 ./* \
  \
  # build.properties
  && cd $i2b2_SOURCE/giri_i2b2_project_v1.1/GIRI_cell/de.erlangen.i2b2.giri/ \
  && sed -i "s#GIRI.directory=.*#GIRI.directory=$GIRI_SCRIPT#g" build.properties \
  && sed -i 's#r.home=.*#r.home=/usr/lib64/R#g' build.properties \
  && sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
  && sed -i "s#web.dir=.*#web.dir=$GIRI_WEBDIR/GIRIPlugin/assets/#g" build.properties \
  && sed -i 's#sample.xml.request=.*#sample.xml.request=$i2b2_SOURCE/giri_i2b2_project_v1.1/GIRI_cell/de.erlangen.i2b2.giri/src/test/de/erlangen/i2b2/giri/test/GetRResultsSample.xml#g' build.properties \
  && sed -i 's#jri.libpath=.*#/usr/lib64/R/library/rJava/jri/#g' build.properties \
  && sed -i 's#config.schema.path=.*#$i2b2_SOURCE/giri_i2b2_project_v1.1/GIRI_cell/edu.harvard.i2b2.xml/xsd/cell/giri/GIRIConfig.xsd#g' build.properties \
  \
  # config / waittime
  && cd $i2b2_SOURCE/giri_i2b2_project_v1.1/GIRI_cell/de.erlangen.i2b2.giri/ \
  && cd src/core/de/erlangen/i2b2/giri/ \
  && sed -i 's/180000/18000099/g' MessageUtil.java \
  \
  # build & deploy
  && cd $i2b2_SOURCE/giri_i2b2_project_v1.1/GIRI_cell/de.erlangen.i2b2.giri/ \
	&& ant -f master_build.xml build-all \
  && ant jboss_deploy

# only for tests: giri.webservice.url
# && sed -i 's#giri.webservice.url=.*#giri.webservice.url=http://localhost:$JBOSS_PORT/i2b2/services/GIRIService#g' build.properties \

VOLUME ["/var/www/html/webclient/js-i2b2/cells/plugins/GIRIPlugin/assets"]




#########################
## Additional Cell IDRT i2b2 Web Client Plugin

WORKDIR $i2b2_SOURCE

## use provided binaries OR
# RUN  cp "Server Builds 2015-11-12/IdrtAdditionalData.aar" $JBOSS_HOME/standalone/deployments/i2b2.war/WEB-INF/services/ \
#   && cp "Server Builds 2015-11-12/IdrtAdditionalData-EJB.jar" $JBOSS_HOME/standalone/deployments/i2b2.war/WEB-INF/lib/

## OR compile locally
# ENV CELL_IDRT_WC=IDRT_Web_Client_Plugin_Cell_2015-11-12.zip
# RUN unzip -u -q $CELL_IDRT_WC \
#   && rm $CELL_IDRT_WC \
#   && mv de.umg.mi.idrt.i2b2.cell/edu.miGoettingen.i2b2.plugin.moreData ./ \
#   && cd edu.miGoettingen.i2b2.plugin.moreData \
#   && sed -i "s#jboss.home=.*#jboss.home=$JBOSS_HOME#g" build.properties \
#   \
#   # build & deploy
# 	&& ant -f master_build.xml build-all \
#   && ant deploy



###########################
## Configuration: Timeout

# for JBOSS AS & Wildfly: remove & add values in xmlns="urn:jboss:domain:transactions
RUN cd $JBOSS_HOME/standalone/configuration/ \
  && sed -i '/<coordinator-environment/d' standalone.xml \
  && sed -i "/<recovery-environment/a <coordinator-environment default-timeout=\"$i2b2_TRANS_TIMEOUT\"/>" standalone.xml

# --> alternative: with JBOSS
# $JBOSS_HOME/bin/jboss-cli.sh --connect
#
# /subsystem=transactions/:write-attribute(name=default-timeout,value=500)
# /subsystem=transactions/:write-attribute(name=enable-statistics,value=true)




###########################
## Final steps

USER root

#VOLUME ["/opt"]


#
