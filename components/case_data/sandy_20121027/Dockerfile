FROM dtcenter/base_image:simple
MAINTAINER Jamie Wolff <jwolff@ucar.edu>

ENV CASE_DIR /data
RUN mkdir -p ${CASE_DIR} \
 && chown -R comuser:comusers ${CASE_DIR}
USER comuser
#
RUN curl -SL http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker/container-dtc-nwp-sandydata_20121027.tar.gz | tar -xzC ${CASE_DIR} \
 && chmod 6775 ${CASE_DIR}
#
VOLUME $CASE_DIR
USER root
CMD ["true"]

