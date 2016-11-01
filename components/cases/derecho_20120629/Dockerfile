FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu>

RUN mkdir /case_data

RUN curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/derecho_20120629.tar.gz | tar -xzC /case_data

VOLUME /case_data/derecho_20120629
CMD ["true"]

