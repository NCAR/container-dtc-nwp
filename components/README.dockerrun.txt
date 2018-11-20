#
# Setup environment.
#   CASE_NAME and CASE_DATE can be set to...
#    - snow    and 20160123
#    - derecho and 20120629
#    - sandy   and 20121027
#
export CASE_NAME=snow                         -or-  setenv CASE_NAME sandy
export CASE_DATE=20160123                     -or-  setenv CASE_DATE 20121027
export PROJ_DIR="/path/to/working/directory"  -or-  setenv PROJ_DIR "/path/to/working/directory"
export CASE_DIR=${PROJ_DIR}/${CASE_NAME}      -or-  setenv CASE_DIR ${PROJ_DIR}/${CASE_NAME}

mkdir -p ${CASE_DIR}
cd ${CASE_DIR}
mkdir -p wpsprd gsiprd wrfprd postprd metprd metviewer/mysql

#                                                                                                                                                             
# Run WPS script in docker-space.
#                                                                                           
docker run --rm -it --volumes-from wps_geog --volumes-from ${CASE_NAME} \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}_${CASE_DATE}:/scripts/case \
 -v ${CASE_DIR}/wpsprd:/wpsprd \
 --name run-${CASE_NAME}-wps dtc-wps_wrf /scripts/common/run_wps.ksh

#                                                                                                                                                             
# Run real in docker-space.
#                                                                                           

docker run --rm -it --volumes-from ${CASE_NAME} \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}_${CASE_DATE}:/scripts/case \
 -v ${CASE_DIR}/wpsprd:/wpsprd -v ${CASE_DIR}/wrfprd:/wrfprd \
 --name run-${CASE_NAME}-real dtc-wps_wrf /scripts/common/run_real.ksh

#
# Run GSI in docker-space.
#
docker run --rm -it --volumes-from gsi_data --volumes-from ${CASE_NAME} \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}_${CASE_DATE}:/scripts/case \
 -v ${CASE_DIR}/gsiprd:/gsiprd -v ${CASE_DIR}/wrfprd:/wrfprd \
 --name run-${CASE_NAME}-gsi dtc-gsi /scripts/common/run_gsi.ksh

#
# Run WRF in docker-space.
#
docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}_${CASE_DATE}:/scripts/case \
 -v ${CASE_DIR}/wpsprd:/wpsprd -v ${CASE_DIR}/gsiprd:/gsiprd -v ${CASE_DIR}/wrfprd:/wrfprd \
 --name run-${CASE_NAME}-wrf dtc-wps_wrf /scripts/common/run_wrf.ksh

#
# Run UPP in docker-space.
#
docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}_${CASE_DATE}:/scripts/case \
 -v ${CASE_DIR}/wrfprd:/wrfprd -v ${CASE_DIR}/postprd:/postprd \
 --name run-${CASE_NAME}-upp dtc-upp /scripts/common/run_upp.ksh

#
# Run NCL to generate plots from WRF output.
#
docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}_${CASE_DATE}:/scripts/case \
 -v ${CASE_DIR}/wrfprd:/wrfprd -v ${CASE_DIR}/nclprd:/nclprd \
 --name run-${CASE_NAME}-ncl dtc-ncl /scripts/common/run_ncl.ksh
 
#
# Run MET script in docker-space.
#
docker run -it --volumes-from ${CASE_NAME} \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}_${CASE_DATE}:/scripts/case \
 -v ${CASE_DIR}/postprd:/postprd -v ${CASE_DIR}/metprd:/metprd \
 --name run-${CASE_NAME}-met dtc-met /scripts/common/run_met.ksh

#
# Run docker compose to launch METViewer.
#
cd ${PROJ_DIR}/container-dtc-nwp/components/metviewer
docker-compose up -d

#
# Run the METViewer load script.
#
docker exec -it metviewer /scripts/common/metv_load_all.ksh mv_${CASE_NAME}

#
# Launch the local METViewer GUI webpage:
#   http://localhost:8080/metviewer/metviewer1.jsp
# Make plot selections and click the "Generate Plot" button.
#

#
# Additional METViewer container options:
# - Open a shell in the docker environment:
#     docker exec -it metviewer /bin/bash
# - Inside the container, list the METViewer modules:
#     ls /METViewer/bin
# - Inside the container, ${CASE_DIR}/metprd is mounted to /data:
#     ls /data
# - Inside the container, administer MySQL:
#     mysql -h mysql_mv -uroot -pmvuser
# - Outside the container, stop and remove METViewer containers:
#     cd ${PROJ_DIR}/container-dtc-nwp/components/metviewer
#     docker-compose down
#
