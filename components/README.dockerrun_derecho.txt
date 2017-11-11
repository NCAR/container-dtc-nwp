#
# Setup environment
#
setenv PROJ_DIR "/path/to/working/directory"  -or-  export PROJ_DIR="/path/to/working/directory"
setenv CASE_DIR ${PROJ_DIR}/derecho           -or-  export CASE_DIR=${PROJ_DIR}/derecho
mkdir -p ${CASE_DIR}
cd ${CASE_DIR}
mkdir -p wrfprd postprd metprd metviewer/mysql

#
# Run WPS/WRF/UPP (NWP: pre-proc, model, post-proc) script in docker-space.
#
docker run --rm -it --volumes-from wps_geog --volumes-from derecho \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${CASE_DIR}/wrfprd:/wrfprd -v ${CASE_DIR}/postprd:/postprd \
 --name run-dtc-nwp-derecho dtc-nwp /scripts/derecho_20120629/run/run-dtc-nwp.ksh

#
# Run NCL to generate plots from WRF output.
#
docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${CASE_DIR}/wrfprd:/wrfprd -v ${CASE_DIR}/nclprd:/nclprd \
 --name run-dtc-ncl-derecho dtc-ncl /scripts/common/ncl_run_all.ksh

#
# Run MET script in docker-space.
#
docker run -it --volumes-from derecho \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${CASE_DIR}/postprd:/postprd -v ${CASE_DIR}/metprd:/metprd \
 --name run-dtc-met-derecho dtc-met /scripts/derecho_20120629/run/run-dtc-met.ksh

#
# Run docker compose to launch METViewer.
#
cd ${PROJ_DIR}/container-dtc-nwp/components/metviewer
docker-compose up -d

#
# Run the METViewer load script.
#
docker exec -it metviewer_1 /scripts/common/metv_load_all.ksh mv_derecho

#
# Launch the local METViewer GUI webpage:
#   http://localhost:8080/metviewer/metviewer1.jsp
# Make plot selections and click the "Generate Plot" button.
#

#
# Additional METViewer container options:
# - Open a shell in the docker environment:
#     docker exec -it metviewer_1 /bin/bash
# - Inside the container, list the METViewer modules:
#     ls /METViewer/bin
# - Inside the container, ${CASE_DIR}/metprd is mounted to /data:
#     ls /data
# - Inside the container, administer MySQL:
#     mysql -h mysql_mv -uroot -pmvuser
# - Outside the container, stop and remove METViewer containers:
#     docker-compose down
#
