FROM mkavulich/common-community-container:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
# 
# This Dockerfile compiles WRF from source during "docker build" step
USER comuser
RUN mkdir /comsoftware/wrf
WORKDIR /comsoftware/wrf
ENV WRF_VERSION 4.1.1
ENV WPS_VERSION 4.1
#
# Download original sources
#
RUN curl -SL https://github.com/wrf-model/WRF/archive/v${WRF_VERSION}.tar.gz | tar zxC /comsoftware/wrf \
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
RUN pwd \ 
 && export NETCDF=/comsoftware/libs/netcdf/ \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && cd ./WRF-${WRF_VERSION} \
 && ./configure <<< $'34\r1\r' \
 && sed -i -e '/^DM_CC/ s/$/ -DMPI2_SUPPORT/' ./configure.wrf \
 && /bin/csh ./compile em_real > compile_wrf_arw_opt34.1.log 2>&1
# Check build success
RUN ls WRF-${WRF_VERSION}/main/real.exe WRF-${WRF_VERSION}/main/wrf.exe
#
# Build WPS second
#
# input 1 to configure script (gfortran serial build)
RUN ln -sf WRF-${WRF_VERSION} WRF \
 && cd ./WPS-${WPS_VERSION} \
 && echo export NETCDF=/comsoftware/libs/netcdf/ \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && ./configure <<< $'1\r' \
 && sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff /' ./configure.wps \
 && /bin/csh ./compile > compile_wps.log 2>&1
# Check build success
RUN ls WPS-${WPS_VERSION}/metgrid.exe WPS-${WPS_VERSION}/ungrib.exe WPS-${WPS_VERSION}/geogrid.exe
#
ENV LD_LIBRARY_PATH /usr/lib64/openmpi/lib:/comsoftware/libs/netcdf/lib
ENV PATH  /usr/lib64/openmpi/bin:$PATH
#
# copy in a couple custom scripts...apparently there's no way to docker COPY with non-root permissions....
#
USER root
COPY docker-clean /comsoftware/wrf
COPY run-wps-wrf /comsoftware/wrf
RUN chmod +x /comsoftware/wrf/docker-clean \
 && chmod +x /comsoftware/wrf/run-wps-wrf \
 && chown comuser:comusers /comsoftware/wrf/docker-clean \
 && chown comuser:comusers /comsoftware/wrf/run-wps-wrf 
USER comuser
#
# set up ssh configuration
#
#COPY ssh_config /root/.ssh/config
#COPY slave /wrf/slave
#RUN yum install -y openssh-clients openssh-server net-tools \
#    && yum clean all \
#    && mkdir -p /var/run/sshd \
#    && ssh-keygen -A \
#    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /home/.ssh/sshd_config \
#    && sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/g' /home/.ssh/sshd_config \
#    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /home/.ssh/sshd_config \
#    && ssh-keygen -f /root/.ssh/id_rsa -t rsa -N '' \
#    && chmod 600 /root/.ssh/config \
#    && chmod 700 /root/.ssh \
#    && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
#    && chmod +x /wrf/slave
#
CMD ["/comsoftware/wrf/run-wps-wrf"]
