#!/bin/ksh

#
# Run docker load for all tutorial data and software containers.
# This script should be run OUTSIDE of the containers.
#

# URL for container image tarballs
DTC_NWP_URL=https://dtcenter.org/sites/default/files/community-code/nwp_containers

# Locate run_command.ksh script
SCRIPT_DIR=`dirname $0`
export RUN_CMD=${SCRIPT_DIR}/run_command.ksh

# WPS geog data
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-nwp-wps_geog.tar.gz
${RUN_CMD} time docker load -i dtc-nwp-wps_geog.tar.gz
${RUN_CMD} time docker create -v /WPS_GEOG --name wps_geog dtc-nwp-wps_geog
${RUN_CMD} rm -f dtc-nwp-wps_geog.tar.gz

# GSI static data
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-nwp-gsi_data.tar.gz
${RUN_CMD} time docker load -i dtc-nwp-gsi_data.tar.gz
${RUN_CMD} time docker create -v /gsi_data --name gsi_data dtc-nwp-gsi_data
${RUN_CMD} rm -f dtc-nwp-gsi_data.tar.gz

# Sandy data
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-nwp-sandy.tar.gz
${RUN_CMD} time docker load -i dtc-nwp-sandy.tar.gz
${RUN_CMD} time docker create -v /case_data/sandy_20121027 --name sandy dtc-nwp-sandy
${RUN_CMD} rm -f dtc-nwp-sandy.tar.gz

# Snow data
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-nwp-snow.tar.gz
${RUN_CMD} time docker load -i dtc-nwp-snow.tar.gz
${RUN_CMD} time docker create -v /case_data/snow_20160123 --name snow dtc-nwp-snow
${RUN_CMD} rm -f dtc-nwp-snow.tar.gz

# Derecho data
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-nwp-derecho.tar.gz
${RUN_CMD} time docker load -i dtc-nwp-derecho.tar.gz
${RUN_CMD} time docker create -v /case_data/derecho_20120629 --name derecho dtc-nwp-derecho
${RUN_CMD} rm -f dtc-nwp-derecho.tar.gz

# WPS/WRF image
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-nwp.tar.gz
${RUN_CMD} time docker load -i dtc-nwp.tar.gz
${RUN_CMD} rm -f dtc-nwp.tar.gz

# GSI image
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-gsi.tar.gz
${RUN_CMD} time docker load -i dtc-gsi.tar.gz
${RUN_CMD} rm -f dtc-gsi.tar.gz

# UPP image
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-upp.tar.gz
${RUN_CMD} time docker load -i dtc-upp.tar.gz
${RUN_CMD} rm -f dtc-upp.tar.gz

# NCL image
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-ncl.tar.gz
${RUN_CMD} time docker load -i dtc-ncl.tar.gz
${RUN_CMD} rm -f dtc-ncl.tar.gz

# MET image
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-met.tar.gz
${RUN_CMD} time docker load -i dtc-met.tar.gz
${RUN_CMD} rm -f dtc-met.tar.gz

# METviewer image
${RUN_CMD} time wget -q ${DTC_NWP_URL}/dtc-metviewer.tar.gz
${RUN_CMD} time docker load -i dtc-metviewer.tar.gz
${RUN_CMD} rm -f dtc-metviewer.tar.gz

# List images
docker images

# List containers
docker ps -a

echo "Done with Docker load."

