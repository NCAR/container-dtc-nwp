FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu> or Michelle Harrold <harrold@ucar.edu>
#
RUN  mkdir /scripts
COPY *.ksh /scripts/
RUN  chmod +x /scripts/*.ksh
#
VOLUME /scripts
CMD ["true"]
