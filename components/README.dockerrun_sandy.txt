# Setup environment
#
setenv PROJ_DIR "/path/to/working/directory"  -or-  export PROJ_DIR="/path/to/working/directory"
setenv CASE_DIR ${PROJ_DIR}/sandy             -or-  export CASE_DIR=${PROJ_DIR}/sandy
mkdir -p ${CASE_DIR}
cd ${CASE_DIR}
mkdir -p wrfprd postprd metprd metviewer/mysql

#
# Run WPS/WRF/UPP (NWP: pre-proc, model, post-proc) script in docker-space.
#
docker run --rm -it --volumes-from wps_geog --volumes-from sandy \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${CASE_DIR}/wrfprd:/wrfprd -v ${CASE_DIR}/postprd:/postprd \
 --name run-dtc-nwp-sandy dtc-nwp /scripts/sandy_20121027/run/run-dtc-nwp.ksh

#
# Run NCL to generate plots from WRF output.
#
docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${CASE_DIR}/wrfprd:/wrfprd -v ${CASE_DIR}/nclprd:/nclprd \
 --name run-dtc-ncl-sandy dtc-ncl /scripts/common/ncl_run_all.ksh

#
# Run MET script in docker-space.
#
docker run -it --volumes-from sandy \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts:/scripts \
 -v ${CASE_DIR}/postprd:/postprd -v ${CASE_DIR}/metprd:/metprd \
 --name run-dtc-met-sandy dtc-met /scripts/sandy_20121027/run/run-dtc-met.ksh

#
# Run docker compose to launch METViewer.
#
cd ${PROJ_DIR}/container-dtc-nwp/components/metviewer
docker-compose up -d

#
# Run the METViewer load script.
#
docker exec -it metviewer /scripts/common/metv_load_all.ksh mv_sandy

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

---
old


#
# Run WPS/WRF/UPP (NWP: pre-proc, model, post-proc) script in docker-space.
#
docker run -it --volumes-from wps_geog --volumes-from sandy \
 -v ~/wrfprd:/wrfprd -v ~/postprd:/postprd \
 --name run-dtc-nwp-sandy dtc-nwp /case_data/sandy_20121027/run/run-dtc-nwp

# Run NCL to generate plots from WRF output 
docker run --rm  -it -v ~/wrfprd:/wrfprd dtc-ncl

#
# Run MET script in docker-space.
#
docker run -it --volumes-from scripts --volumes-from sandy \
 -v ~/postprd:/postprd -v ~/metprd:/metprd \
 --name run-dtc-met-sandy dtc-met /case_data/sandy_20121027/run/run-dtc-met
 
