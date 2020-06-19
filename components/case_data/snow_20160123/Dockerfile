FROM dtcenter/base_image:simple
MAINTAINER Jamie Wolff <jwolff@ucar.edu>

ENV CASE_DIR /data
RUN mkdir -p ${CASE_DIR} \
 && chown -R comuser:comusers ${CASE_DIR}
USER comuser
#
RUN curl -SL https://dtcenter.ucar.edu/dfiles/container_nwp_tutorial/tar_files/data-dtc-nwp-snow_20160123.tar.gz | tar -xzC ${CASE_DIR} \
 && chmod 6775 ${CASE_DIR}
#
VOLUME $CASE_DIR
USER root
CMD ["true"]

