FROM dtcenter/base_image:latest
MAINTAINER John Halley Gotway <johnhg@ucar.edu>

#
# This Dockerfile compiles MET from source during "docker build" step
#


ENV MET_GIT_NAME    v10.0.0
ENV MET_GIT_URL     https://github.com/dtcenter/MET.git
ENV MET_DEVELOPMENT true

#
# Define the compilers.
#
ENV CC  /opt/rh/devtoolset-8/root/usr/bin/gcc
ENV FC  /opt/rh/devtoolset-8/root/usr/bin/gfortran
ENV CXX /opt/rh/devtoolset-8/root/usr/bin/g++
ENV F77 /opt/rh/devtoolset-8/root/usr/bin/gfortran

RUN source /opt/rh/devtoolset-8/enable

#
# Define package URL's.
#
ENV GSFONT_URL https://dtcenter.ucar.edu/dfiles/code/METplus/MET/docker_data/ghostscript-fonts-std-8.11.tar.gz

#
# Install the required packages.
#
USER root
RUN yum -y update \
 && yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 \
                   libpng-devel jasper jasper-devel zlib zlib-devel \
                   cairo-devel freetype-devel epel-release \
                   hostname m4 make tar tcsh ksh time wget which \
                   flex flex-devel bison bison-devel unzip \
 && yum -y install git g2clib-devel hdf5-devel.x86_64 gsl-devel \
 && yum -y install gv ncview wgrib wgrib2 ImageMagick ps2pdf \
 && yum -y install python3 python3-devel python3-pip \
 && pip3 install --upgrade pip \
 && python3 -m pip install numpy xarray

#
# Setup the environment for interactive bash/csh container shells.
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
 && echo "Checking out MET ${MET_GIT_NAME} from ${MET_GIT_URL}" \
 && git clone ${MET_GIT_URL} /comsoftware/met/met-${MET_GIT_NAME} \
 && cd /comsoftware/met/met-${MET_GIT_NAME}/met \
 && git checkout ${MET_GIT_NAME} \
 && LOG_FILE=/comsoftware/met/met-${MET_GIT_NAME}/met/configure.log \
 && echo "Running bootstrap" \
 && ./bootstrap \
 && echo "Configuring met-${MET_GIT_NAME} and writing log file ${LOG_FILE}" \
 && ./configure --prefix=/comsoftware/met/ --enable-grib2 --enable-mode_graphics --enable-modis --enable-lidar2nc --enable-python \
    MET_NETCDF=/comsoftware/libs/netcdf \
    MET_HDF=/comsoftware/libs/HDF4.2r3 \
    MET_HDFEOS=/comsoftware/libs/hdfeos \
    MET_FREETYPEINC=/usr/include/freetype2 MET_FREETYPELIB=/usr/lib \
    MET_CAIROINC=/usr/include/cairo MET_CAIROLIB=/usr/lib \
    MET_PYTHON_CC='-I/usr/include/python3.6m' MET_PYTHON_LD='-lpython3.6m' > ${LOG_FILE} \
 && LOG_FILE=/comsoftware/met/met-${MET_GIT_NAME}/met/make_install.log \
 && echo "Compiling met-${MET_GIT_NAME} and writing log file ${LOG_FILE}" \
 && make install > ${LOG_FILE} 
# && LOG_FILE=/comsoftware/met/met-${MET_GIT_NAME}/met/make_test.log \
# && echo "Testing met-${MET_GIT_NAME} and writing log file ${LOG_FILE}" \
# && make test > ${LOG_FILE} 2>&1

#
# Set working directory
#
WORKDIR /comsoftware/met

USER root
