#
# Setup environment
#
setenv PROJ_DIR "/path/to/working/directory"
cd ${PROJ_DIR}
mkdir -p wrfprd postprd metprd metviewer/mysql

#
# Run WPS/WRF/UPP (NWP: pre-proc, model, post-proc) script in docker-space.
#
docker run -it --volumes-from wps_geog --volumes-from derecho --volumes-from scripts \
 -v ${PROJ_DIR}/wrfprd:/wrfprd -v ${PROJ_DIR}/postprd:/postprd \
 --name run-dtc-nwp-derecho dtc-nwp /scripts/derecho_20120629/run/run-dtc-nwp.ksh

#
# Run NCL to generate plots from WRF output.
#
docker run --rm -it --volumes-from scripts \
 -v ${PROJ_DIR}/wrfprd:/wrfprd -v ${PROJ_DIR}/nclprd:/nclprd \
 --name run-dtc-ncl-derecho dtc-ncl /scripts/common/ncl_run_all.ksh

#
# Run MET script in docker-space.
#
docker run -it --volumes-from derecho --volumes-from scripts \
 -v ${PROJ_DIR}/postprd:/postprd -v ${PROJ_DIR}/metprd:/metprd \
 --name run-dtc-met-derecho dtc-met /scripts/derecho_20120629/run/run-dtc-met.ksh

#
# Run docker compose to launch METViewer and open a shell inside the container.
# METViewer container exits when the shell is closed.
# METViewer GUI URL http://localhost:8080/metviewer/metviewer1.jsp
#
cd ${PROJ_DIR}/container-dtc-nwp/components/metviewer
docker-compose run --rm --service-ports metviewer

#
# In a separate terminal window, run the METViewer load script.
#
docker exec -it metviewer_metviewer_run_1 /scripts/common/metv_load_all.ksh mv_derecho

#
# In the METViewer GUI browser window, click "Reload Databases" button.
# John, add instructions for running a batch plot.
#

#
# You can access all METViewer modules in /METViewer/bin
# MET and/or VSDB output are in /data directory
# You can use METViewer web application using your URL http://localhost:8080/metviewer/metviewer1.jsp
# MySQL database can be accessed with this command : mysql -h mysql_mv -uroot -pmvuser
#
