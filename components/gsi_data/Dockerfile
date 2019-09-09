FROM dtcenter/base_image:simple
MAINTAINER Michael Kavulich <kavulich@ucar.edu>
#
RUN mkdir -p /data/gsi \
 && chown -R comuser:comusers /data
USER comuser
#
RUN curl -SL https://dtcenter.org/com-GSI/users/downloads/GSI_releases/CRTM_v2.3.0.tar.gz | tar -xzC /data/gsi/ \
 && chmod 6775 -R /data/gsi
VOLUME /data/gsi
USER root
CMD ["true"]
