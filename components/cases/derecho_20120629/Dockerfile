FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu>

RUN mkdir /wrfinput

RUN curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/derecho_20120629_wrfinput.tar.gz | tar -xzC /wrfinput

VOLUME /wrfinput/derecho_20120629
CMD ["true"]

