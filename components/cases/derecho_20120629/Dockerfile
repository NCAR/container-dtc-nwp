FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu>

RUN mkdir -p /case_data/derecho_20120629

RUN curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data/derecho_20120629.tar.gz | tar -xzC /case_data/derecho_20120629

VOLUME /case_data/derecho_20120629
CMD ["true"]

