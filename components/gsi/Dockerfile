FROM ubuntu:latest
MAINTAINER Michael Kavulich <kavulich@ucar.edu>
#
# This Dockerfile compiles GSI from source during "docker build" step
ENV GSI_VERSION 3.7
ENV ENKF_VERSION 1.2

# Make with this many parallel tasks
ENV J 4

#SERIAL BUILD
RUN apt update
#RUN yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 libpng-devel jasper jasper-devel ksh hostname m4 make perl tar tcsh time wget which zlib zlib-devel epel-release
RUN apt -y install file gcc gfortran g++ ksh hostname m4 make perl tar tcsh time wget libopenmpi-dev libnetcdf-dev libnetcdff-dev netcdf-bin libopenblas-dev cmake
#
# now get 3rd party EPEL builds of netcdf dependencies, hdf5, openmpi stuff, cmake3, and openblas
#RUN apt install netcdf-openmpi-devel.x86_64 netcdf-fortran-openmpi-devel.x86_64 netcdf-fortran-openmpi.x86_64 hdf5-openmpi.x86_64 openmpi.x86_64 openmpi-devel.x86_64 cmake3 openblas-devel.x86_64
#

#
WORKDIR /gsi
#
# Download source code
#
# This command will be used after the official release
#RUN curl -SL https://dtcenter.org/com-GSI/users/downloads/GSI_releases/comGSIv${GSI_VERSION}_EnKFv1.2.tar.gz | tar zxC /gsi 
#
ADD comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION}.tar.gz /gsi

# Set necessary environment variables for GSI build
#
ENV LDFLAGS -lm
ENV NETCDF /gsi/netcdf_links
ENV LD_LIBRARY_PATH /usr/lib/
ENV PATH /usr/lib64/openmpi/bin:$PATH
ENV HDF5_ROOT $NETCDF
#
# Build GSI
# 
RUN pwd \ 
 && env \
 && mkdir netcdf_links \
 && ln -sf /usr/include /gsi/netcdf_links/ \
 && ln -sf /usr/lib/x86_64-linux-gnu/ /gsi/netcdf_links/lib \
 && mkdir gsi_build \
 && cd gsi_build \
 && cmake /gsi/comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION} \
 && make -j ${J}
#

# Setup run directory
RUN mkdir /gsi/gsi_run

#
# copy in a couple custom scripts
#
#COPY docker-clean /gsi
#COPY run-gsi /gsi/gsi_run
#RUN chmod +x /gsi/docker-clean \
# && chmod +x /gsi/gsi_run/run-gsi
#
# set up ssh configuration
#
COPY ssh_config /root/.ssh/config
COPY slave /gsi/slave
RUN apt install -y openssh-client openssh-server net-tools \
    && apt clean all \
    && mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
    && ssh-keygen -f /root/.ssh/id_rsa -t rsa -N '' \
    && chmod 600 /root/.ssh/config \
    && chmod 700 /root/.ssh \
    && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
    && chmod +x /gsi/slave

CMD ["/gsi/run-gsi"]
