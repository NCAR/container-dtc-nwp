FROM centos:latest

MAINTAINER Tatiana Burek <tatiana@ucar.edu>

ENV METVIEWER_VERSION 2.3
ENV TOMCAT_MINOR_VERSION 5.23
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_VERSION ${TOMCAT_MAJOR_VERSION}.${TOMCAT_MINOR_VERSION}

ENV METVIEWER_URL http://www.dtcenter.org/met/users/downloads/MET_releases/METViewer-${METVIEWER_VERSION}.tar.gz

#
# Install Extra Packages for Enterprise Linux for Rscript install
#
RUN		yum -y update  \
	&&	yum -y install epel-release

#
# Install required packages
#
RUN yum -y install  wget tar java R gsl-devel mysql ksh\
  && rm -rf /var/cache/yum/* \
	&& yum clean all

# Setup default cran repo
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile

#
# Install required R packages
#
RUN Rscript -e "install.packages('boor')" \
	&& Rscript -e "install.packages('plotrix')" \
	&& Rscript -e "install.packages('gsl')" \
	&& Rscript -e "install.packages('stats')"


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
# Download and Deploy METViewer load/batch
#

RUN  curl -L ${METVIEWER_URL} | tar xzC /tmp \
  && mv  /tmp/METViewer/dist/*.war $CATALINA_HOME/webapps/ \
  && mv /tmp/METViewer /METViewer

#
# Set working directory
#
WORKDIR /METViewer


#
# Start Tomcat
#
ENTRYPOINT ${CATALINA_HOME}/bin/startup.sh && /bin/bash
CMD ["true"]
