FROM centos:latest
MAINTAINER John Halley Gotway <johnhg@ucar.edu>

# TO DO:
# - Compile with GRIB2 support and other optional libs
# - Redirect output to log files and echo out useful info?
# - everything else! 

# 
# This Dockerfile compiles MET from source during "docker build" step
#
ENV MET_VERSION 5.2
ENV MET_RELEASE_DATE 20160815
ENV MET_PATCH_DATE 20161010

ENV CC  /usr/bin/gcc
ENV CXX /usr/bin/g++
ENV FC  /usr/bin/gfortran
ENV F77 /usr/bin/gfortran

RUN yum -y update
RUN yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 libpng-devel jasper jasper-devel hostname m4 make perl tar tcsh time wget which zlib zlib-devel epel-release which

#
# Now get 3rd party EPEL builds of netcdf
#
RUN yum -y install netcdf-cxx-devel.x86_64 gsl-devel.x86_64 

#
# Set working directory
#
WORKDIR /met

#
# Set environment for interactive bash and csh container shells
#
RUN echo export CC=${CC} >> /etc/bashrc \
 && echo setenv CC ${CC} >> /etc/csh.cshrc \
 && echo export CXX=${CXX} >> /etc/bashrc \
 && echo setenv CXX ${CXX} >> /etc/csh.cshrc \
 && echo export FC=${FC} >> /etc/bashrc \
 && echo setenv FC ${FC} >> /etc/csh.cshrc \
 && echo export F77=${F77} >> /etc/bashrc \
 && echo setenv F77 ${F77} >> /etc/csh.cshrc \
 && echo export MET_BUFRLIB=/met/external_libs/BUFRLIB >> /etc/bashrc \
 && echo setenv MET_BUFRLIB /met/external_libs/BUFRLIB >> /etc/csh.cshrc

#
# Download source code for MET and patches
#
RUN curl -SL http://www.dtcenter.org/met/users/downloads/MET_releases/met-${MET_VERSION}.${MET_RELEASE_DATE}.tar.gz | tar zxC /met \
 && curl -SL http://www.dtcenter.org/met/users/support/known_issues/METv${MET_VERSION}/patches/met-${MET_VERSION}_patches_${MET_PATCH_DATE}.tar.gz | tar zxC /met/met-${MET_VERSION}

#
# Download and build BUFRLIB
#
RUN mkdir -p /met/external_libs/BUFRLIB \
 && cd /met/external_libs/BUFRLIB \
 && curl -SL http://www.dtcenter.org/met/users/support/online_tutorial/METv5.0/compilation/tar_files/BUFRLIB_v10-2-3.tar | tar xC /met/external_libs/BUFRLIB \
 && cat preproc.sh | sed 's/cpp /cpp -traditional-cpp /g' > preproc_patch.sh \
 && chmod +x preproc_patch.sh \
 && ./preproc_patch.sh *.F \
 && ${CC} -c -DUNDERSCORE *.c \
 && ${FC} -c -fno-second-underscore *.f \
 && ar crv libbufr.a *.o \
 && rm -f /usr/lib/libbufr.a \
 && cp  *.a /usr/lib

#
# Compile MET
#
RUN cd /met/met-${MET_VERSION} \
 && ./configure \
 && make install \
 && make test


