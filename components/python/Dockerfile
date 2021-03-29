FROM dtcenter/base_image:simple
MAINTAINER Michelle Harrold <harrold@ucar.edu> or Jamie Wolff <jwolff@ucar.edu>
# 
# This Dockerfile builds miniconda and installs python3 during "docker build" step
RUN mkdir /home/postprd \
 && mkdir /home/pythonprd \
 && chown -R comuser:comusers /home/postprd \
 && chown -R comuser:comusers /home/pythonprd
USER comuser

WORKDIR /home/pythonprd

# Set Python3 and miniconda versions
ENV PYTHON_VERS 38
ENV MINIC_VERS 4.8.3

USER root
RUN yum -y update \
 && yum -y install curl bzip2 ksh ImageMagick \
 && curl -sSL https://repo.continuum.io/miniconda/Miniconda3-py${PYTHON_VERS}_${MINIC_VERS}-Linux-x86_64.sh -o /tmp/miniconda.sh \
 && bash /tmp/miniconda.sh -bfp /usr/local/ \
 && rm -rf /tmp/miniconda.sh \
 && conda install -y python=3 \
 && conda update conda \
 && conda clean --all --yes \
 && rpm -e --nodeps curl bzip2 \
 && yum clean all

RUN conda install -c conda-forge pygrib \
  && conda install -c conda-forge cartopy \
  && conda install -c conda-forge netCDF4 \
  && conda install -c conda-forge pyyaml

ENV MPLCONFIGDIR /home/user
