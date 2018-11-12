FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
# 
# This Dockerfile compiles WRF from source during "docker build" step
ENV WRF_VERSION 4.0.2
ENV WPS_VERSION 4.0.2
ENV UPP_VERSION 3.2

#SERIAL BUILD
RUN yum -y update
RUN yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 libpng-devel jasper jasper-devel ksh hostname m4 make perl tar tcsh time wget which zlib zlib-devel epel-release
#
# now get 3rd party EPEL builds of netcdf dependencies
RUN yum -y install netcdf-devel.x86_64 netcdf-fortran-devel.x86_64 netcdf-fortran.x86_64 hdf5.x86_64
#
WORKDIR /wrf_serial
#
# Download original sources
#
RUN curl -SL https://github.com/wrf-model/WRF/archive/v${WRF_VERSION}.tar.gz | tar zxC /wrf_serial \
 && curl -SL http://www.dtcenter.org/upp/users/downloads/UPP_releases/DTC_upp_v${UPP_VERSION}.tar.gz | tar zxC /wrf_serial
#

# Set environment for interactive container shells
#
RUN echo export LDFLAGS="-lm" >> /etc/bashrc \ 
 && echo export NETCDF=/wrf_serial/netcdf_links >> /etc/bashrc \
 && echo export JASPERINC=/usr/include/jasper/ >> /etc/bashrc \
 && echo export JASPERLIB=/usr/lib64/ >> /etc/bashrc \
 && echo export LD_LIBRARY_PATH="/usr/lib64" >> /etc/bashrc \
 && echo export PATH="/usr/lib64/bin:$PATH" >> /etc/bashrc \
 && echo setenv LDFLAGS "-lm" >> /etc/csh.cshrc \
 && echo setenv NETCDF "/wrf_serial/netcdf_links" >> /etc/csh.cshrc \
 && echo setenv JASPERINC "/usr/include/jasper/" >> /etc/csh.cshrc \
 && echo setenv JASPERLIB "/usr/lib64/" >> /etc/csh.cshrc \
 && echo setenv LD_LIBRARY_PATH "/usr/lib64" >> /etc/csh.cshrc \
 && echo setenv PATH "/usr/lib64/bin:$PATH" >> /etc/csh.cshrc
#
# Build WRF first
# input 34 and 1 to configure script alternative line = && echo -e "32\r1\r" | ./configure
# 
RUN pwd \ 
 && mkdir netcdf_links \
 && ln -sf /usr/include/ netcdf_links/include \
 && ln -sf /usr/lib64 netcdf_links/lib \
 && ln -sf /usr/lib64/gfortran/modules/netcdf.mod netcdf_links/include \
 && export NETCDF=/wrf_serial/netcdf_links \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && cd ./WRF-${WRF_VERSION} \
 && ./configure <<< $'32\r1\r' \
 && /bin/csh ./compile em_real > compile_wrf_arw_opt32.1.log 2>&1
#
# Build UPP second
#
# input 7 to configure script (for gfortran serial build)
RUN cd ./UPPV3.2 \
 && export NETCDF=/wrf_serial/netcdf_links \
 && ./configure <<< $'1\r' <<<< $"../WRF-${WRF_VERSION}\r" <<< $'7\r' \
 && /bin/csh ./compile > compile_upp.log 2>&1
#
ENV LD_LIBRARY_PATH /usr/lib64/lib
ENV PATH  /usr/lib64/bin:$PATH
#

#PARALLEL BUILD
#
# now get 3rd party EPEL builds of netcdf and openmpi dependencies
RUN yum -y install netcdf-openmpi-devel.x86_64 netcdf-fortran-openmpi-devel.x86_64 netcdf-fortran-openmpi.x86_64 hdf5-openmpi.x86_64 openmpi.x86_64 openmpi-devel.x86_64
#
WORKDIR /wrf
#
# Download original sources
#
RUN curl -SL https://github.com/wrf-model/WRF/archive/v${WRF_VERSION}.tar.gz | tar zxC /wrf \
 && curl -SL https://github.com/wrf-model/WPS/archive/v${WPS_VERSION}.tar.gz | tar zxC /wrf
#
# Set environment for interactive container shells
#
RUN echo export LDFLAGS="-lm" >> /etc/bashrc \
 && echo export NETCDF=/wrf/netcdf_links >> /etc/bashrc \
 && echo export JASPERINC=/usr/include/jasper/ >> /etc/bashrc \
 && echo export JASPERLIB=/usr/lib64/ >> /etc/bashrc \
 && echo export LD_LIBRARY_PATH="/usr/lib64/openmpi/lib" >> /etc/bashrc \
 && echo export PATH="/usr/lib64/openmpi/bin:$PATH" >> /etc/bashrc \
 && echo setenv LDFLAGS "-lm" >> /etc/csh.cshrc \
 && echo setenv NETCDF "/wrf/netcdf_links" >> /etc/csh.cshrc \
 && echo setenv JASPERINC "/usr/include/jasper/" >> /etc/csh.cshrc \
 && echo setenv JASPERLIB "/usr/lib64/" >> /etc/csh.cshrc \
 && echo setenv LD_LIBRARY_PATH "/usr/lib64/openmpi/lib" >> /etc/csh.cshrc \
 && echo setenv PATH "/usr/lib64/openmpi/bin:$PATH" >> /etc/csh.cshrc
#
# Build WRF first
# input 34 and 1 to configure script alternative line = && echo -e "34\r1\r" | ./configure
# 
RUN pwd \ 
 && mkdir netcdf_links \
 && ln -sf /usr/include/openmpi-x86_64/ netcdf_links/include \
 && ln -sf /usr/lib64/openmpi/lib netcdf_links/lib \
 && export NETCDF=/wrf/netcdf_links \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && cd ./WRF-${WRF_VERSION} \
 && ./configure <<< $'34\r1\r' \
 && sed -i -e '/^DM_CC/ s/$/ -DMPI2_SUPPORT/' ./configure.wrf \
 && /bin/csh ./compile em_real > compile_wrf_arw_opt34.1.log 2>&1
#
# Build WPS second
#
# input 1 to configure script (gfortran serial build)
RUN cd ./WPS-${WPS_VERSION} \
 && export NETCDF=/wrf/netcdf_links \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && ./configure <<< $'1\r' \
 && sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff /' ./configure.wps \
 && /bin/csh ./compile > compile_wps.log 2>&1
#
ENV LD_LIBRARY_PATH /usr/lib64/openmpi/lib
ENV PATH  /usr/lib64/openmpi/bin:$PATH
#
# copy in a couple custom scripts
#
COPY docker-clean /wrf
COPY run-wps-wrf-upp /wrf
RUN chmod +x /wrf/docker-clean \
 && chmod +x /wrf/run-wps-wrf-upp
#
# set up ssh configuration
#
COPY ssh_config /root/.ssh/config
COPY slave /wrf/slave
RUN yum install -y openssh-clients openssh-server net-tools \
    && yum clean all \
    && mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
    && ssh-keygen -f /root/.ssh/id_rsa -t rsa -N '' \
    && chmod 600 /root/.ssh/config \
    && chmod 700 /root/.ssh \
    && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
    && chmod +x /wrf/slave

CMD ["/wrf/run-wps-wrf-upp"]
