FROM centos:latest
MAINTAINER Michael Kavulich <kavulich@ucar.edu>
#
# This Dockerfile compiles GSI from source during "docker build" step
ENV GSI_VERSION 3.7
ENV ENKF_VERSION 1.2

# Make with this many parallel tasks
ENV J 4

#SERIAL BUILD
RUN yum -y update
#RUN yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 libpng-devel jasper jasper-devel ksh hostname m4 make perl tar tcsh time wget which zlib zlib-devel epel-release
RUN yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 ksh hostname m4 make perl tar tcsh time wget which epel-release
#
# now get 3rd party EPEL builds of netcdf dependencies
#SERIAL RUN yum -y install netcdf-devel.x86_64 netcdf-fortran-devel.x86_64 netcdf-fortran.x86_64 hdf5.x86_64 
RUN yum -y install netcdf-openmpi-devel.x86_64 netcdf-fortran-openmpi-devel.x86_64 netcdf-fortran-openmpi.x86_64 hdf5-openmpi.x86_64 openmpi.x86_64 openmpi-devel.x86_64 cmake3 openblas-devel.x86_64
#
WORKDIR /gsi
#
# Download source code
#
# This command will be used after the official release
#RUN curl -SL https://dtcenter.org/com-GSI/users/downloads/GSI_releases/comGSIv${GSI_VERSION}_EnKFv1.2.tar.gz | tar zxC /gsi 
#
ADD comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION}.tar.gz /gsi
#RUN gunzip comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION}.tar.gz \
# && tar -xf comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION}.tar

# Set necessary environment variables for GSI build
#
ENV LDFLAGS -lm
ENV NETCDF /gsi/netcdf_links
ENV LD_LIBRARY_PATH /lib64:/usr/lib64:/usr/lib64/openmpi/lib:/usr/lib
ENV PATH /usr/lib64/openmpi/bin:$PATH
ENV HDF5_ROOT $NETCDF
#
# Build GSI
# 
RUN pwd \ 
 && env \
 && mkdir netcdf_links \
 && ln -sf /usr/include/openmpi-x86_64/ netcdf_links/include \
 && ln -sf /usr/lib64/openmpi/lib netcdf_links/lib \
 && mkdir gsi_build \
 && cd gsi_build \
 && cmake3 /gsi/comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION} \
 && make -j ${J}
#

# Setup run directory
RUN mkdir /gsi/gsi_run

#
# copy in a couple custom scripts
#
COPY docker-clean /gsi
COPY run-gsi /gsi/gsi_run
RUN chmod +x /gsi/docker-clean \
 && chmod +x /gsi/gsi_run/run-gsi
#
# set up ssh configuration
#
COPY ssh_config /root/.ssh/config
COPY slave /gsi/slave
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
    && chmod +x /gsi/slave

CMD ["/gsi/run-gsi"]
