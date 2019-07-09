FROM mkavulich/common-community-container:latest
#FROM mkavulich/common-community-container:gnu7
MAINTAINER Michael Kavulich <kavulich@ucar.edu>
#
# This Dockerfile compiles GSI from source during "docker build" step
USER comuser
RUN mkdir /comsoftware/gsi
WORKDIR /comsoftware/gsi
ENV GSI_VERSION 3.7
ENV ENKF_VERSION 1.3

# Make with this many parallel tasks
ENV J 4

# Download source code
#
#RUN wget https://dtcenter.org/com-GSI/users/downloads/GSI_releases/comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION}.tar.gz | tar zxC /comsoftware/gsi 
RUN curl -SL https://dtcenter.org/com-GSI/users/downloads/GSI_releases/comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION}.tar.gz | tar -xzC /comsoftware/gsi
# Set necessary environment variables for GSI build
#
ENV LDFLAGS -lm
ENV NETCDF /comsoftware/libs/netcdf/
ENV LD_LIBRARY_PATH /usr/lib:/comsoftware/libs/netcdf/lib
ENV PATH /usr/lib64/openmpi/bin:$PATH
ENV HDF5_ROOT $NETCDF
#
# Build GSI
# 
RUN pwd \ 
 && env \
 && mkdir /comsoftware/gsi/gsi_build \
 && cd /comsoftware/gsi/gsi_build \
 && sed -i 's/wij(1)/wij/g' /comsoftware/gsi/comGSIv3.7_EnKFv1.3/src/setuplight.f90 \
 && cmake /comsoftware/gsi/comGSIv${GSI_VERSION}_EnKFv${ENKF_VERSION} \
 && make -j ${J}
#
# Setup run directory
RUN mkdir /home/gsi_run
#
# Set some useful settings for bashrc/cshrc
RUN echo set -o ignoreeof >> /etc/bashrc \
 && echo set -o ignoreeof >> /etc/csh.cshrc \
RUN set -o ignoreeof
#
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
#
#RUN env
CMD ["/home/gsiprd/run-gsi"]
