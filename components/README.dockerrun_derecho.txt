#
# Setup environment
#
setenv PROJ_DIR "/path/to/working/directory"
cd ${PROJ_DIR}
mkdir -p wrfprd postprd metprd metviewer/mysql

#
# Run WPS/WRF/UPP (NWP: pre-proc, model, post-proc) script in docker-space.
#
docker run -it --volumes-from wps_geog --volumes-from derecho \
 -v ${PROJ_DIR}/wrfprd:/wrfprd -v ${PROJ_DIR}/postprd:/postprd \
 --name run-dtc-nwp-derecho dtc-nwp /case_data/derecho_20120629/run/run-dtc-nwp

#
# Run NCL to generate plots from WRF output
#
docker run --rm -it -v ${PROJ_DIR}/wrfprd:/wrfprd dtc-ncl

#
# Run MET script in docker-space.
#
docker run -it --volumes-from scripts --volumes-from derecho \
 -v ${PROJ_DIR}/postprd:/postprd -v ${PROJ_DIR}/metprd:/metprd \
 --name run-dtc-met-derecho dtc-met /case_data/derecho_20120629/run/run-dtc-met

#
# Run docker compose to launch METViewer.
#
setenv METVIEWER_DATA ${PROJ_DIR}/metprd
setenv METVIEWER_DIR  ${PROJ_DIR}/metviewer
setenv MYSQL_DIR      ${PROJ_DIR}/metviewer/mysql
cd ${PROJ_DIR}/container-dtc-nwp/components/metviewer
docker-compose run --rm --service-ports metviewer

#
# You can access all METViewer modules in /METViewer/bin
# MET and/or VSDB output are in /data directory
# You can use METViewer web application using your URL http://localhost:8080/metviewer/metviewer1.jsp
# MySQL database can be accessed with this command : mysql -h mysql_mv -uroot -pmvuser
#
