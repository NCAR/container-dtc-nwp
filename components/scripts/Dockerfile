FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>

RUN  mkdir /scripts
COPY util  /scripts/util
COPY derecho_20120629 /scripts/derecho_20120629
COPY sandy_20121027   /scripts/sandy_20121027
RUN  chmod +x /scripts/common/*.ksh /scripts/*/run/run*

VOLUME /scripts
CMD ["true"]
