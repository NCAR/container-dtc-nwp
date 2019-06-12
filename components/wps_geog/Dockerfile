FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
#
RUN mkdir -p /data/WPS_GEOG
#
RUN curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker/geog_minimum.tar.gz | tar -xzC /data/WPS_GEOG
#
RUN chmod 6755 -R /data/WPS_GEOG
VOLUME /data/WPS_GEOG
CMD ["true"]
