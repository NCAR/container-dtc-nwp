FROM centos:latest
MAINTAINER Jamie Wolff <jwolff@ucar.edu>

ENV CASE_DIR /case_data/sandy_20121027

RUN mkdir -p ${CASE_DIR}/run ${CASE_DIR}/param \
 && curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker/container-dtc-nwp-sandydata_20121027.tar.gz | tar -xzC $CASE_DIR

COPY run ${CASE_DIR}/run
COPY param ${CASE_DIR}/param
RUN chmod +x ${CASE_DIR}/run/run*

VOLUME $CASE_DIR
CMD ["true"]

