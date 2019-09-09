FROM dtcenter/base_image:simple
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
#
RUN mkdir -p /data/WPS_GEOG \
 && chown -R comuser:comusers /data
USER comuser
#
RUN curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker/geog_minimum.tar.gz | tar -xzC /data/WPS_GEOG \
 && chmod 6775 -R /data/WPS_GEOG
VOLUME /data/WPS_GEOG
USER root
CMD ["true"]
