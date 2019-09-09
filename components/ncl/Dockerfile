FROM dtcenter/base_image:latest
MAINTAINER Kate Fossell <fossell@ucar.edu> or Michael Kavulich <kavulich@ucar.edu>
# 
USER comuser
RUN umask 0002 \
 && mkdir /home/nclprd \
 && mkdir /home/wrfprd
WORKDIR /home/nclprd
USER root
RUN yum -y update \
 && yum -y install fontconfig libgfortran libXext libXrender ImageMagick ksh
#
RUN curl -SL https://ral.ucar.edu/sites/default/files/public/projects/ncar-docker-wrf/nclncarg-6.3.0.linuxcentos7.0x8664nodapgcc482.tar.gz | tar zxC /usr/local
#
ENV NCARG_ROOT /usr/local
#
