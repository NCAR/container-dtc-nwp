FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu>

ENV CASE_DIR /data/

RUN mkdir -p ${CASE_DIR} \
 && curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker/container-dtc-nwp-sandydata_20121027.tar.gz | tar -xzC ${CASE_DIR} \
 && chmod 6755 -R ${CASE_DIR}
VOLUME $CASE_DIR
CMD ["true"]

