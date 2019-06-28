FROM centos:latest
MAINTAINER Michael Kavulich <kavulich@ucar.edu>
#
RUN mkdir -p /data/gsi
#
RUN curl -SL https://dtcenter.org/com-GSI/users/downloads/GSI_releases/CRTM_v2.3.0.tar.gz | tar -xzC /data/gsi/
#
RUN chmod 6755 -R /data/gsi
VOLUME /data/gsi
CMD ["true"]
