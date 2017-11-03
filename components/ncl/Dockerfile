#
FROM centos:latest
MAINTAINER Kate Fossell <fossell@ucar.edu>
# 
RUN yum -y update
RUN yum -y install fontconfig libgfortran libXext libXrender ImageMagick ksh
#
RUN curl -SL https://ral.ucar.edu/sites/default/files/public/projects/ncar-docker-wrf/nclncarg-6.3.0.linuxcentos7.0x8664nodapgcc482.tar.gz | tar zxC /usr/local
#
ENV NCARG_ROOT /usr/local
#
RUN mkdir /nclscripts
RUN mkdir /nclprd
RUN mkdir /wrfprd
COPY *.ncl /nclscripts/
COPY run_all_ncl /nclscripts
WORKDIR /nclscripts
