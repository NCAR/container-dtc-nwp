# Setup environment
#
setenv PROJ_DIR "/path/to/working/directory"  -or-  export PROJ_DIR="/path/to/working/directory"
setenv CASE_DIR ${PROJ_DIR}/sandy             -or-  export CASE_DIR=${PROJ_DIR}/sandy
mkdir -p ${CASE_DIR}
cd ${CASE_DIR}
mkdir -p wpsprd gsiprd wrfprd postprd metprd metviewer/mysql

#
# Run WPS and real.exe in docker-space.
#
                                                                                              
docker run --rm -it --volumes-from wps_geog --volumes-from sandy \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/sandy_20121027:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd \
 --name run-sandy-wps dtc-wps_wrf /home/scripts/common/run_wps.ksh

docker run --rm -it --volumes-from sandy \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/sandy_20121027:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd -v ${CASE_DIR}/wrfprd:/home/wrfprd \
 --name run-sandy-real dtc-wps_wrf /home/scripts/common/run_real.ksh

#
# Run GSI in docker-space.
#
docker run --rm -it --volumes-from gsi_data --volumes-from sandy \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/sandy_20121027:/home/scripts/case \
 -v ${CASE_DIR}/gsiprd:/home/gsiprd -v ${CASE_DIR}/wrfprd:/home/wrfprd \
 --name run-sandy-gsi dtc-gsi /home/scripts/common/run_gsi.ksh

#
# Run WRF in docker-space.
#
docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/sandy_20121027:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd -v ${CASE_DIR}/gsiprd:/home/gsiprd -v ${CASE_DIR}/wrfprd:/home/wrfprd \
 --name run-sandy-wrf dtc-wps_wrf /home/scripts/common/run_wrf.ksh

#
# Run UPP in docker-space.
#
docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/sandy_20121027:/home/scripts/case \
 -v ${CASE_DIR}/wrfprd:/home/wrfprd -v ${CASE_DIR}/postprd:/home/postprd \
 --name run-sandy-upp dtc-upp /home/scripts/common/run_upp.ksh

#
# Run NCL to generate plots from WRF output.
#
docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/sandy_20121027:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd -v ${CASE_DIR}/wrfprd:/home/wrfprd -v ${CASE_DIR}/nclprd:/home/nclprd \
 --name run-sandy-ncl dtc-ncl /home/scripts/common/run_ncl.ksh
 
#
# Run MET script in docker-space.
#
docker run -it --volumes-from sandy \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/sandy_20121027:/home/scripts/case \
 -v ${CASE_DIR}/postprd:/home/postprd -v ${CASE_DIR}/metprd:/home/metprd \
 --name run-sandy-met dtc-met /home/scripts/common/run_met.ksh

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
#
