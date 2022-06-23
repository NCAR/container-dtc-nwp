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

# GSI image
if [ "${BULID_GSI}" == "true" ]; then
   time_command docker build -t dtcenter/gsi \
      -f ${GITHUB_WORKSPACE}/components/gsi/Dockerfile
else
   time_command docker pull dtcenter/gsi:latest
fi

# UPP image
if [ "${BULID_UPP}" == "true" ]; then
   time_command docker build -t dtcenter/upp \
      -f ${GITHUB_WORKSPACE}/components/upp/Dockerfile
else
   time_command docker pull dtcenter/upp:latest
fi

# Python image
if [ "${BULID_PYTHON}" == "true" ]; then
   time_command docker build -t dtcenter/python \
      -f ${GITHUB_WORKSPACE}/components/python/Dockerfile
else
   time_command docker pull dtcenter/python:latest
fi

# MET image
if [ "${BULID_MET}" == "true" ]; then
   time_command docker build -t dtcenter/nwp-container-met \
      -f ${GITHUB_WORKSPACE}/components/met/MET/Dockerfile
else
   time_command docker pull dtcenter/nwp-container-met:latest
fi

# METviewer image
if [ "${BULID_METVIEWER}" == "true" ]; then
   time_command docker build -t dtcenter/nwp-container-metviewer \
      -f ${GITHUB_WORKSPACE}/components/metviewer/METviewer/Dockerfile
else
   time_command docker pull dtcenter/nwp-container-metviewer:latest
fi

# List the images
docker images
