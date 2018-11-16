FROM ubuntu:latest
MAINTAINER Michael Kavulich <kavulich@ucar.edu>
#
RUN apt update
RUN apt -y install wget
RUN mkdir /gsi_data
#
# Get GSI tutorial data
#
#RUN mkdir -p /gsi_data/ \
# && wget  https://dtcenter.org/container_nwp_tutorial/tar_files/gsi_obs.tar -P /gsi_data/ \
# && tar -xf /gsi_data/gsi_obs.tar -C /gsi_data/
#
# Download CRTM files
RUN wget https://dtcenter.org/com-GSI/users/downloads/GSI_releases/CRTM_v2.3.0.tar.gz -P /gsi_data/ \
 && tar -xf /gsi_data/CRTM_v2.3.0.tar.gz -C /gsi_data/
VOLUME /gsi_data
CMD ["true"]
