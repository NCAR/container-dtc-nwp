FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
#
ENV WRF_VERSION 3.9
RUN mkdir /WPS_GEOG
#
RUN curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker/wpsgeogminimum-wrf-$WRF_VERSION.tar.gz | tar -xzC /WPS_GEOG
#
VOLUME /WPS_GEOG
CMD ["true"]
