FROM dtcenter/base_image:latest
MAINTAINER John Halley Gotway <johnhg@ucar.edu>

# 
# This Dockerfile compiles MET from source during "docker build" step
#
ENV MET_VERSION 8.0
ENV MET_RELEASE_DATE 20180927

#
# Compilers
#
ENV CC  /opt/rh/devtoolset-7/root/usr/bin/gcc
ENV FC  /opt/rh/devtoolset-7/root/usr/bin/gfortran
ENV CXX /opt/rh/devtoolset-7/root/usr/bin/g++
ENV F77 /opt/rh/devtoolset-7/root/usr/bin/gfortran

RUN source /opt/rh/devtoolset-7/enable

#
# Package URL's
#
ENV HDF4_URL       http://www.hdfgroup.org/ftp/HDF/releases/HDF4.2r3/src/HDF4.2r3.tar.gz
ENV HDFEOS_URL     https://dtcenter.org/sites/default/files/community-code/met/docker_data/HDF-EOS2.16v1.00.tar.Z

ENV NETCDF4C_URL   https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.zip
ENV NETCDF4CXX_URL https://github.com/Unidata/netcdf-cxx4/archive/v4.3.0.tar.gz

ENV BUFRLIB_URL    https://dtcenter.org/sites/default/files/community-code/met/docker_data/BUFRLIB_v10-2-3.tar
ENV GSFONT_URL     https://dtcenter.org/sites/default/files/community-code/met/docker_data/ghostscript-fonts-std-8.11.tar.gz

ENV MET_URL        https://dtcenter.org/sites/default/files/met-${MET_VERSION}.${MET_RELEASE_DATE}.tar.gz
ENV PATCH_URL      https://dtcenter.org/sites/default/files/met-${MET_VERSION}_patches_latest.tar.gz

#
# Install required packages
#
USER root
RUN yum -y update \
 && yum -y install cairo-devel freetype-devel unzip g2clib-devel gsl-devel ps2pdf \
 && yum -y install python2 python2-pip python2-devel \
 && pip install --upgrade pip \
 && pip install xarray numpy

#
# Environment for interactive bash and csh container shells
#
ENV MET_BASE        /comsoftware/met/share/met/
ENV MET_FONT_DIR    /comsoftware/met/external_libs/fonts
ENV RSCRIPTS_BASE   /usr/local/share/comsoftware/met/Rscripts
#ENV LD_LIBRARY_PATH /usr/local/lib

#
# Download GhostScript fonts
#
USER comuser
RUN umask 0002 \
 && echo "Downloading GhostScript fonts from ${GSFONT_URL}" \
 && curl -SL ${GSFONT_URL} | tar zxC /comsoftware/libs

#
# Download and compile MET source code
#
RUN umask 0002 \
 && echo "Downloading met-${MET_VERSION} from ${MET_URL}" \
 && mkdir -p /comsoftware/met \
 && curl -SL ${MET_URL} | tar zxC /comsoftware/met \
 && cd /comsoftware/met/met-${MET_VERSION} \
 && LOG_FILE=/comsoftware/met/met-${MET_VERSION}/configure.log \
 && echo "Configuring met-${MET_VERSION} and writing log file ${LOG_FILE}" \
 && ./configure --prefix=/comsoftware/met/ --enable-grib2 --enable-mode_graphics --enable-modis --enable-lidar2nc --enable-python \
    MET_NETCDF=/comsoftware/libs/netcdf \
    MET_HDF=/comsoftware/libs/HDF4.2r3 \
    MET_HDFEOS=/comsoftware/libs/hdfeos \
    MET_FREETYPEINC=/usr/include/freetype2 MET_FREETYPELIB=/usr/lib \
    MET_CAIROINC=/usr/include/cairo MET_CAIROLIB=/usr/lib \
    MET_PYTHON_CC='-I/usr/include/python2.7' MET_PYTHON_LD='-lpython2.7' > ${LOG_FILE} \
 && LOG_FILE=/comsoftware/met/met-${MET_VERSION}/make_install.log \
 && echo "Compiling met-${MET_VERSION} and writing log file ${LOG_FILE}" \
 && make install > ${LOG_FILE} \
 && LOG_FILE=/comsoftware/met/met-${MET_VERSION}/make_test.log \
 && echo "Testing met-${MET_VERSION} and writing log file ${LOG_FILE}" \
 && make test > ${LOG_FILE} 2>&1

#
# Set working directory
#
WORKDIR /comsoftware/met

USER root
