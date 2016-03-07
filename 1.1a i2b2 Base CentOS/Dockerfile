FROM centos:7

MAINTAINER Florian Endel <florian@endel.at>

ARG JAVA_INSTALL=java-1.7.0-openjdk-devel

# Install EPEL, Java, ...
RUN rpm -ihv http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm \
  && yum update -y \
  && yum upgrade -y \
  && yum install -y \
    $JAVA_INSTALL \
    xmlstarlet \
    unzip  \
    postgresql \
    perl-XML-XPath \
    patch \
    R-core \
    R-core-devel \
  && yum clean all

ENV JAVA_HOME /usr/lib/jvm/java
