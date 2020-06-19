FROM dtcenter/base_image:simple
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
#
RUN mkdir -p /data/WPS_GEOG \
 && chown -R comuser:comusers /data
USER comuser
#
RUN curl -SL https://dtcenter.ucar.edu/dfiles/container_nwp_tutorial/tar_files/geog_minimum.tar.gz | tar -xzC /data/WPS_GEOG \
 && chmod 6775 -R /data/WPS_GEOG
VOLUME /data/WPS_GEOG
USER root
CMD ["true"]
