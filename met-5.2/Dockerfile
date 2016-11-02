FROM centos:latest
MAINTAINER John Halley Gotway <johnhg@ucar.edu>

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

#
# Install required packages
#
RUN yum -y update \
 && yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 \
                   libpng-devel jasper jasper-devel zlib zlib-devel \
                   cairo-devel freetype-devel epel-release \
                   hostname m4 make tar tcsh time wget which \
                   ncview gv \
 && yum -y install g2clib-devel \
 && yum -y install netcdf-cxx-devel gsl-devel

#
# Set working directory
#
WORKDIR /met

#
# Set environment for interactive bash and csh container shells
#
RUN echo export MET_FONT_DIR=/met/external_libs/fonts >> /etc/bashrc \
 && echo setenv MET_FONT_DIR /met/external_libs/fonts >> /etc/csh.cshrc

#
# Download BUFRLIB and GhostScript fonts
#
RUN mkdir -p /met/external_libs/BUFRLIB \
 && cd /met/external_libs/BUFRLIB \
 && BUFRLIB_URL=http://www.dtcenter.org/met/users/support/online_tutorial/METv5.0/compilation/tar_files/BUFRLIB_v10-2-3.tar \
 && echo "Downloading BUFRLIB from ${BUFRLIB_URL}" \
 && curl -SL ${BUFRLIB_URL} | tar xC /met/external_libs/BUFRLIB \
 && cat preproc.sh | sed 's/cpp /cpp -traditional-cpp /g' > preproc_patch.sh \
 && chmod +x preproc_patch.sh \
 && LOG_FILE=/met/external_libs/BUFRLIB/build.log \
 && echo "Compiling BUFRLIB and writing log file ${LOG_FILE}" \
 && ./preproc_patch.sh *.F > ${LOG_FILE} \
 && ${CC} -c -DUNDERSCORE *.c >> ${LOG_FILE} \
 && ${FC} -c -fno-second-underscore *.f >> ${LOG_FILE} \
 && ar crv libbufr.a *.o >> ${LOG_FILE} \
 && rm -f /usr/lib/libbufr.a \
 && cp  *.a /usr/lib \
 && GSFONT_URL=http://iweb.dl.sourceforge.net/project/gs-fonts/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz \
 && echo "Downloading GhostScript fonts from ${GSFONT_URL}" \
 && curl -SL ${GSFONT_URL} | tar zxC /met/external_libs

#
# Download and compile MET source code and patches
#
RUN MET_URL=http://www.dtcenter.org/met/users/downloads/MET_releases/met-${MET_VERSION}.${MET_RELEASE_DATE}.tar.gz \
 && echo "Downloading met-${MET_VERSION} from ${MET_URL}" \
 && curl -SL ${MET_URL} | tar zxC /met \
 && PATCH_URL=http://www.dtcenter.org/met/users/support/known_issues/METv${MET_VERSION}/patches/met-${MET_VERSION}_patches_${MET_PATCH_DATE}.tar.gz \
 && echo "Downloading met-${MET_VERSION} patches from ${PATCH_URL}" \
 && curl -SL ${PATCH_URL} | tar zxC /met/met-${MET_VERSION} \
 && cd /met/met-${MET_VERSION} \
 && LOG_FILE=/met/met-${MET_VERSION}/configure.log \
 && echo "Configuring met-${MET_VERSION} and writing log file ${LOG_FILE}" \
 && ./configure --enable-grib2 --enable-mode_graphics \
    MET_BUFRLIB=/met/external_libs/BUFRLIB \
    MET_FREETYPEINC=/usr/include/freetype2 MET_FREETYPELIB=/usr/lib \
    MET_CAIROINC=/usr/include/cairo MET_CAIROLIB=/usr/lib > ${LOG_FILE} \
 && LOG_FILE=/met/met-${MET_VERSION}/make_install.log \
 && echo "Compiling met-${MET_VERSION} and writing log file ${LOG_FILE}" \
 && make install > ${LOG_FILE} \
 && LOG_FILE=/met/met-${MET_VERSION}/make_test.log \
 && echo "Testing met-${MET_VERSION} and writing log file ${LOG_FILE}" \
 && make test > ${LOG_FILE} 2>&1

#
# Pull input data for the online tutorial
#
RUN DATA_URL=http://www.dtcenter.org/met/users/support/online_tutorial/tutorial_data/METv${MET_VERSION}_tutorial_data.tar.gz \
 && echo "Downloading input data for the met-${MET_VERSION} online tutorial from ${DATA_URL}" \
 && curl -SL ${DATA_URL} | tar zxC /met/met-${MET_VERSION}

