#! /bin/bash

source ${GITHUB_WORKSPACE}/.github/jobs/bash_functions.sh

DOCKERHUB_TAG=${DOCKERHUB_REPO}:${SOURCE_BRANCH}

CMD_LOGFILE=${GITHUB_WORKSPACE}/docker_build.log

# Base image
if [ "${BULID_BASE}" == "true" ]; then
   time_command docker build -t dtcenter/base_image \
      -f ${GITHUB_WORKSPACE}/components/base/Dockerfile
else
   time_command docker pull dtcenter/base_image:latest
fi

# WPS/WRF image
if [ "${BULID_WPS_WRF}" == "true" ]; then
   time_command docker build -t dtcenter/wps_wrf \
      -f ${GITHUB_WORKSPACE}/components/wps_wrf/Dockerfile
else
   time_command docker pull dtcenter/wps_wrf:latest
fi

# GSI
# UPP
# PYTHON
# MET
# METVIEWER
