FROM mkavulich/common-community-container:gnu7
MAINTAINER Kate Fossell <fossell@ucar.edu> or Michael Kavulich <kavulich@ucar.edu>
# 
# This Dockerfile compiles UPP from source during "docker build" step
USER comuser
RUN mkdir /comsoftware/upp
WORKDIR /comsoftware/upp
ENV UPP_VERSION 4.0.1
 
# Download original source
RUN curl -SL https://dtcenter.org/sites/default/files/DTC_upp_v${UPP_VERSION}.tar.gz | tar zxC /comsoftware/upp
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
# input 7 to configure script (for gfortran serial build)

RUN pwd \
 && export NETCDF=/comsoftware/libs/netcdf/ \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && cd ./UPPV${UPP_VERSION} \
 && ./configure <<< $'7\r' \
 && /bin/csh ./compile > compile_upp.log 2>&1
#
#
ENV LD_LIBRARY_PATH /usr/lib64/openmpi/lib:/comsoftware/libs/netcdf/lib
ENV PATH /usr/lib64/openmpi/bin:$PATH
#
# copy in a custom script...apparently there's no way to docker COPY with non-root permissions....
#
USER root
COPY run-upp /comsoftware/upp
RUN chmod +x /comsoftware/upp/run-upp \
 && chown comuser:comusers /comsoftware/upp/run-upp
USER comuser
#
# set up ssh configuration
#
#COPY ssh_config /root/.ssh/config
#COPY slave /upp/slave
#RUN yum install -y openssh-clients openssh-server net-tools \
#    && yum clean all \
#    && mkdir -p /var/run/sshd \
#    && ssh-keygen -A \
#    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config \
#    && sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config \
#    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
#    && ssh-keygen -f /root/.ssh/id_rsa -t rsa -N '' \
#    && chmod 600 /root/.ssh/config \
#    && chmod 700 /root/.ssh \
#    && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
#    && chmod +x /upp/slave

CMD ["/upp/run-upp"]
