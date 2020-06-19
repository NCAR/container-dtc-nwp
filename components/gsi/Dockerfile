FROM dtcenter/base_image:latest
MAINTAINER Michael Kavulich <kavulich@ucar.edu>
#
# This Dockerfile compiles GSI from source during "docker build" step
USER comuser
RUN umask 0002 \
 && mkdir /comsoftware/gsi
WORKDIR /comsoftware/gsi
ENV GSI_VERSION 3.7
ENV ENKF_VERSION 1.3

# Make with this many parallel tasks
ENV J 4

# Download source code
#
RUN umask 0002 \
 && curl -SL https://dtcenter.org/sites/default/files/comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION}.tar.gz | tar -xzC /comsoftware/gsi
# Set necessary environment variables for GSI build
#
ENV LDFLAGS -lm
ENV NETCDF /comsoftware/libs/netcdf/
ENV LD_LIBRARY_PATH /usr/lib:/comsoftware/libs/netcdf/lib
ENV PATH /usr/lib64/openmpi/bin:$PATH
ENV HDF5_ROOT $NETCDF
#
# Prep GSI build
# 
RUN umask 0002 \
 && mkdir /comsoftware/gsi/gsi_build \
 && cd /comsoftware/gsi/gsi_build \
 && cmake /comsoftware/gsi/comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION} 

#
# Fix a few GSI bugs
#
RUN umask 0002 \
 && sed -i 's/wij(1)/wij/g' /comsoftware/gsi/comGSIv3.7_EnKFv1.3/src/setuplight.f90 \
 && sed -i 's/$/ -L\/comsoftware\/libs\/netcdf\/lib/g' /comsoftware/gsi/gsi_build/src/CMakeFiles/gsi.x.dir/link.txt \
 && sed -i 's/$/ -L\/comsoftware\/libs\/netcdf\/lib/g' /comsoftware/gsi/gsi_build/src/enkf/CMakeFiles/enkf_wrf.x.dir/link.txt
#
# Build GSI
#
RUN umask 0002 \
 && cd /comsoftware/gsi/gsi_build \
 && make -j ${J} || echo "I think your build failed yo!"
#
USER root
