FROM dtcenter/base_image:latest
MAINTAINER Kate Fossell <fossell@ucar.edu> or Michael Kavulich <kavulich@ucar.edu>
# 
# This Dockerfile compiles UPP from source during "docker build" step

USER comuser
RUN umask 0002 \
 && mkdir /comsoftware/upp
WORKDIR /comsoftware/upp
ENV UPP_VERSION 4.1
# Download and install NCEPLIBS
RUN umask 0002 \
 && curl -SL https://github.com/NCAR/NCEPlibs/archive/upp_v4.1_release.tar.gz | tar zxC /comsoftware/libs/ \
 && mkdir /comsoftware/libs/NCEPlibs_build \
 && cd /comsoftware/libs/NCEPlibs-upp_v4.1_release \
 && export JASPER_INC=/usr/include/jasper/ \
 && export PNG_INC=/usr/include/ \
 && export CC=gcc \
 && export FCserial=gfortran \
 && export FC=mpif90 \
 && export NOCOMPILERCHOICE=true \
 && ./make_ncep_libs.sh -s linux -c gnu -d /comsoftware/libs/NCEPlibs_build -o 0 -m 1 -a upp
 
# Download original source
RUN umask 0002 \
 && curl -SL https://dtcenter.ucar.edu/dfiles/code/upp/DTC_upp_v${UPP_VERSION}.tar.gz | tar zxC /comsoftware/upp
# Set environment for interactive container shells
#
RUN echo export LDFLAGS="-lm" >> /home/.bashrc \ 
 && echo export NETCDF=/comsoftware/libs/netcdf/ >> /home/.bashrc \
 && echo export PATH="/usr/lib64/openmpi/bin:$PATH" >> /home/.bashrc \
 && echo export JASPERINC=/usr/include/jasper/ >> /home/.bashrc \
 && echo export JASPERLIB=/usr/lib64/ >> /home/.bashrc \
 && echo export LD_LIBRARY_PATH="/usr/lib64/openmpi/lib:/comsoftware/libs/netcdf/lib" >> /home/.bashrc \
 && echo export PATH="/usr/lib64/openmpi/bin:$PATH" >> /home/.bashrc \
# && echo export LD_LIBRARY_PATH="/usr/lib64" >> /etc/bashrc \
# && echo export PATH="/usr/lib64/bin:$PATH" >> /etc/bashrc \
 && echo setenv LDFLAGS "-lm" >> /home/.cshrc \
 && echo setenv NETCDF /comsoftware/libs/netcdf/ >> /home/.cshrc \
 && echo setenv JASPERINC "/usr/include/jasper/" >> /home/.cshrc \
 && echo setenv JASPERLIB "/usr/lib64/" >> /home/.cshrc \
 && echo setenv LD_LIBRARY_PATH "/usr/lib64/openmpi/lib:/comsoftware/libs/netcdf/lib" >> /home/.cshrc \
 && echo setenv PATH "/usr/lib64/openmpi/bin:$PATH" >> /home/.cshrc
# && echo setenv LD_LIBRARY_PATH "/usr/lib64" >> /home/.cshrc \
# && echo setenv PATH "/usr/lib64/bin:$PATH" >> /home/.cshrc
#
#
# Build UPP 
# input 8 to configure script (for gfortran parallel build)
USER root

RUN umask 0002 \
 && export NETCDF=/comsoftware/libs/netcdf/ \
 && export NCEPLIBS_DIR=/comsoftware/libs/NCEPlibs_build \
 && cd ./UPPV${UPP_VERSION} \
 && ./configure <<< $'8\r' \
 && /bin/bash ./compile > compile_upp.log 2>&1
#
#
ENV LD_LIBRARY_PATH /usr/lib64/openmpi/lib:/comsoftware/libs/netcdf/lib
ENV PATH /usr/lib64/openmpi/bin:$PATH
#
#
USER root
