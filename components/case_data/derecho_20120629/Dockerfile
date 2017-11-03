FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu>

ENV CASE_DIR /case_data/derecho_20120629

RUN mkdir -p ${CASE_DIR} \
 && curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker/container-dtc-nwp-derechodata_20120629.tar.gz | tar -xzC ${CASE_DIR}

VOLUME $CASE_DIR
CMD ["true"]

