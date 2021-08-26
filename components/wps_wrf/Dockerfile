FROM dtcenter/base_image:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
# 
# This Dockerfile compiles WRF from source during "docker build" step
USER comuser
RUN umask 0002 \
 && mkdir /comsoftware/wrf
WORKDIR /comsoftware/wrf
ENV WRF_VERSION 4.3
ENV WPS_VERSION 4.3
#
# Download original sources
#
RUN umask 0002 \
 && curl -SL https://github.com/wrf-model/WRF/archive/v${WRF_VERSION}.tar.gz | tar zxC /comsoftware/wrf \
 && curl -SL https://github.com/wrf-model/WPS/archive/v${WPS_VERSION}.tar.gz | tar zxC /comsoftware/wrf
#
# Set environment for interactive container shells
#
RUN echo export LDFLAGS="-lm" >> /home/.bashrc \
 && echo export LD_LIBRARY_PATH="/usr/lib64/openmpi/lib:/comsoftware/libs/netcdf/lib" >> /home/.bashrc \
 && echo export PATH="/usr/lib64/openmpi/bin:$PATH" >> /home/.bashrc \
 && echo setenv LDFLAGS "-lm" >> /home/.cshrc \
 && echo setenv LD_LIBRARY_PATH "/usr/lib64/openmpi/lib:/comsoftware/libs/netcdf/lib" >> /home/.cshrc \
 && echo setenv PATH "/usr/lib64/openmpi/bin:$PATH" >> /home/.cshrc
#
# Build WRF first
# input 34 and 1 to configure script alternative line = && echo -e "34\r1\r" | ./configure
# 
RUN umask 0002 \ 
 && export NETCDF=/comsoftware/libs/netcdf/ \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && export J='-j 4' \
 && cd ./WRF-${WRF_VERSION} \
 && ./configure <<< $'34\r1\r' \
 && sed -i -e '/^DM_CC/ s/$/ -DMPI2_SUPPORT/' ./configure.wrf \
 && sed -i '/BUILD_RRTMG_FAST/d' ./configure.wrf \
 && /bin/csh ./compile em_real > compile_wrf_arw_opt34.1.log 2>&1
# Check build success
RUN ls /comsoftware/wrf/WRF-${WRF_VERSION}/main/real.exe /comsoftware/wrf/WRF-${WRF_VERSION}/main/wrf.exe
#
# Build WPS second
#
# input 1 to configure script (gfortran serial build)
RUN umask 0002 \
 && ln -sf WRF-${WRF_VERSION} WRF \
 && cd ./WPS-${WPS_VERSION} \
 && echo export NETCDF=/comsoftware/libs/netcdf/ \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && ./configure <<< $'1\r' \
 && sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff /' ./configure.wps \
 && /bin/csh ./compile > compile_wps.log 2>&1
# Check build success
RUN ls /comsoftware/wrf/WPS-${WPS_VERSION}/metgrid.exe /comsoftware/wrf/WPS-${WPS_VERSION}/ungrib.exe /comsoftware/wrf/WPS-${WPS_VERSION}/geogrid.exe
#
ENV LD_LIBRARY_PATH /usr/lib64/openmpi/lib:/comsoftware/libs/netcdf/lib
ENV PATH  /usr/lib64/openmpi/bin:$PATH
#
#
USER root
