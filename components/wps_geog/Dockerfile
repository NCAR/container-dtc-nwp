FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
#
RUN mkdir /WPS_GEOG
#
RUN curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker/geog_minimum.tar.gz | tar -xzC /WPS_GEOG
#
VOLUME /WPS_GEOG
CMD ["true"]
