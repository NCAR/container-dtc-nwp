FROM centos:latest
MAINTAINER Kate Fossell <fossell@ucar.edu>
# 
# This Dockerfile compiles UPP from source during "docker build" step
ENV UPP_VERSION 4.0_beta3
 
#SERIAL BUILD
RUN yum -y update
RUN yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 libpng-devel jasper jasper-devel ksh hostname m4 make perl tar tcsh time wget which zlib zlib-devel epel-release
#
# now get 3rd party EPEL builds of netcdf dependencies
RUN yum -y install netcdf-devel.x86_64 netcdf-fortran-devel.x86_64 netcdf-fortran.x86_64 hdf5.x86_64
#
# now get 3rd party EPEL builds of netcdf and openmpi dependencies
RUN yum -y install netcdf-openmpi-devel.x86_64 netcdf-fortran-openmpi-devel.x86_64 netcdf-fortran-openmpi.x86_64 hdf5-openmpi.x86_64 openmpi.x86_64 openmpi-devel.x86_64
#
WORKDIR /upp
#
# Download original sources
#
#RUN curl -SL http://www.dtcenter.org/upp/users/downloads/UPP_releases/DTC_upp_v${UPP_VERSION}.tar.gz | tar zxC /upp
RUN curl -SL http://www.dtcenter.org/upp/users/downloads/UPP_releases/UPPV4.0_beta3.tar.gz | tar zxC /upp

#

# Set environment for interactive container shells
#
RUN echo export LDFLAGS="-lm" >> /etc/bashrc \ 
 && echo export NETCDF=/upp/netcdf_links >> /etc/bashrc \
 && echo export JASPERINC=/usr/include/jasper/ >> /etc/bashrc \
 && echo export JASPERLIB=/usr/lib64/ >> /etc/bashrc \
 && echo export LD_LIBRARY_PATH="/usr/lib64" >> /etc/bashrc \
 && echo export PATH="/usr/lib64/bin:$PATH" >> /etc/bashrc \
 && echo setenv LDFLAGS "-lm" >> /etc/csh.cshrc \
 && echo setenv NETCDF "/upp/netcdf_links" >> /etc/csh.cshrc \
 && echo setenv JASPERINC "/usr/include/jasper/" >> /etc/csh.cshrc \
 && echo setenv JASPERLIB "/usr/lib64/" >> /etc/csh.cshrc \
 && echo setenv LD_LIBRARY_PATH "/usr/lib64" >> /etc/csh.cshrc \
 && echo setenv PATH "/usr/lib64/bin:$PATH" >> /etc/csh.cshrc
#
#
# Build UPP 
# input 7 to configure script (for gfortran serial build)

RUN pwd \
 && mkdir netcdf_links \
 && ln -sf /usr/include/ netcdf_links/include \
 && ln -sf /usr/lib64 netcdf_links/lib \
 && ln -sf /usr/lib64/gfortran/modules/netcdf.mod netcdf_links/include \
 && export NETCDF=/upp/netcdf_links \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && cd ./UPPV4.0_beta3 \
 && ./configure <<< $'7\r' \
 && /bin/csh ./compile > compile_upp.log 2>&1
#
#
ENV LD_LIBRARY_PATH /usr/lib64/lib
ENV PATH  /usr/lib64/bin:$PATH
#
# copy in a couple custom scripts
#
COPY run-upp /upp
RUN chmod +x /upp/run-upp
#
# set up ssh configuration
#
COPY ssh_config /root/.ssh/config
COPY slave /upp/slave
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
    && chmod +x /upp/slave

CMD ["/upp/run-upp"]
