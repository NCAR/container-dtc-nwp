FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>

RUN  mkdir            /scripts
COPY common           /scripts/common
COPY derecho_20120629 /scripts/derecho_20120629
COPY sandy_20121027   /scripts/sandy_20121027
COPY snow_20160123   /scripts/snow_20160123
RUN  chmod +x /scripts/common/*.ksh /scripts/*/run/run*

VOLUME /scripts
CMD ["true"]
