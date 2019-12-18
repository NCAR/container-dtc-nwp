FROM dtcenter/base_image:simple

MAINTAINER Tatiana Burek <tatiana@ucar.edu>

ENV METVIEWER_VERSION 2.11
ENV TOMCAT_MINOR_VERSION 5.23
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_VERSION ${TOMCAT_MAJOR_VERSION}.${TOMCAT_MINOR_VERSION}
ENV UMASK 002

ENV METVIEWER_URL http://www.dtcenter.org/met/users/downloads/MET_releases/METviewer-${METVIEWER_VERSION}.tar.gz

#
# Install Extra Packages for Enterprise Linux for Rscript install
#
RUN yum -y update \
 && yum -y install epel-release \
# Install required packages
 && yum -y install wget tar java R mysql ksh \
 && rm -rf /var/cache/yum/* \
 && yum clean all

# Setup default cran repo
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile

#
# Build GSL-2.1 manually
#
RUN echo "Compiling gsl-2.1 in /gsl" \
 && mkdir /gsl \
 && cd /gsl \
 && wget http://mirrors.syringanetworks.net/gnu/gsl/gsl-2.1.tar.gz \
 && tar -xf gsl-2.1.tar.gz \
 && cd gsl-2.1 \
 && ./configure --prefix=/usr \
 && make >& make.log \
 && make install >& make_install.log

#
# Install required R packages
#
RUN Rscript -e "install.packages('boot')" \
 && Rscript -e "install.packages('plotrix')" \
 && Rscript -e "install.packages('gsl')" \
 && Rscript -e "install.packages('data.table')" \
 && Rscript -e "install.packages('stats')" \
 && Rscript -e "install.packages('verification')"

#
# Install Tomcat
#
ENV CATALINA_HOME /opt/tomcat

RUN wget https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && rm apache-tomcat*.tar.gz \
 && mv apache-tomcat* ${CATALINA_HOME} \
 && chmod +x ${CATALINA_HOME}/bin/*sh

EXPOSE 8080

#
# Download and Deploy METviewer load/batch
#

RUN  curl -L ${METVIEWER_URL} | tar xzC /tmp \
 && mv /tmp/METviewer/dist/*.war $CATALINA_HOME/webapps/ \
 && mv /tmp/METviewer /METviewer

#
# Set working directory
#
WORKDIR /METviewer

#
# Start Tomcat
#
ENTRYPOINT ${CATALINA_HOME}/bin/startup.sh && /bin/bash
CMD ["true"]
