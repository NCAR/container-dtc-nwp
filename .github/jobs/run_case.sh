#! /bin/bash

source ${GITHUB_WORKSPACE}/.github/jobs/bash_functions.sh
export RUN_METVIEWER="false"

#
# Run all commands for a particular tutorial case.
#

# If not set, set PROJ_DIR to one directory above ${GITHUB_WORKSPACE}
# so that it contains the container-dtc-nwp directory.
if [[ ! -e $PROJ_DIR ]]; then
  export PROJ_DIR=${GITHUB_WORKSPACE}/..
fi

# Make sure there is exactly 1 argument and store the case name
if [ $# -ne 1 ]; then
  echo
  echo "ERROR: Must specify the case to run (sandy, derecho, or snow)."
  echo
  exit 1
fi
CASE_NAME=$1

# Check required environment variables
if [ -z ${SOURCE_BRANCH+x} ]; then
   echo "ERROR: Required environment variables not set!"
   echo "ERROR:    \${SOURCE_BRANCH} = \"${SOURCE_BRANCH}\""
   exit 1
fi

CMD_LOGFILE=${GITHUB_WORKSPACE}/run_${CASE_NAME}.log

# Determine case data file name
if [ "${CASE_NAME}" == "sandy" ]; then
   CASE_DATA_FILE="container-dtc-nwp-sandydata_20121027.tar.gz"
elif [ "${CASE_NAME}" == "snow" ; then
   CASE_DATA_FILE="container-dtc-nwp-snowdata_20160123.tar.gz"
elif [ "${CASE_NAME}" == "derecho" ]; then
   CASE_DATA_FILE="container-dtc-nwp-derechodata_20120629.tar.gz"
else
  echo
  echo "ERROR: Unsupported case name = ${CASE_NAME}"
  echo
  exit 1
fi

# Retrieve input data
DATA_DIR=${PROJ_DIR}/container-dtc-nwp/data
time_command mkdir -p ${DATA_DIR}
time_command cd ${DATA_DIR}

# Pull input data tar files
for TAR_FILE in `echo "wps_geog.tar.gz CRTM_v2.3.0.tar.gz shapefiles.tar.gz ${CASE_DATA_FILE}"`; do
  time_command wget -q https://dtcenter.ucar.edu/dfiles/container_nwp_tutorial/tar_files/${TAR_FILE}
  time_command tar -xzf ${TAR_FILE}
  time_command rm -f ${TAR_FILE}
done

# Locate case-specific scripts
CASE_SCRIPT=`basename ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*`

# Setup the environment
export CASE_DIR=${PROJ_DIR}/container-dtc-nwp/${CASE_NAME}
time_command mkdir -p ${CASE_DIR}
time_command cd ${CASE_DIR}
time_command mkdir -p wpsprd wrfprd gsiprd postprd pythonprd metprd metviewer/mysql

# WPS/WRF image name
if [ "${BUILD_WPS_WRF}" == "true" ]; then
   WPS_WRF_IMAGE=dtcenter/container-dtc-nwp-dev:wps_wrf_${SOURCE_BRANCH}
else
   WPS_WRF_IMAGE=dtcenter/wps_wrf:latest
fi

# Run WPS
time_command \
docker run --rm -i -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/data/WPS_GEOG:/data/WPS_GEOG \
-v ${PROJ_DIR}/container-dtc-nwp/data:/data \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/wpsprd:/home/wpsprd \
--name run-${CASE_NAME}-wps ${WPS_WRF_IMAGE} \
/home/scripts/common/run_wps.ksh

# Run Real
time_command \
docker run --rm -i -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/data:/data \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/wpsprd:/home/wpsprd \
-v ${CASE_DIR}/wrfprd:/home/wrfprd \
--name run-${CASE_NAME}-real ${WPS_WRF_IMAGE} \
/home/scripts/common/run_real.ksh

# GSI image name
if [ "${BUILD_GSI}" == "true" ]; then
   GSI_IMAGE=dtcenter/container-dtc-nwp-dev:gsi_${SOURCE_BRANCH}
else
   GSI_IMAGE=dtcenter/gsi:latest
fi

# Run GSI
time_command \
docker run --rm -i -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/data:/data \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/gsiprd:/home/gsiprd \
-v ${CASE_DIR}/wrfprd:/home/wrfprd \
--name run-${CASE_NAME}-gsi ${GSI_IMAGE} \
/home/scripts/common/run_gsi.ksh

# Run WRF
time_command \
docker run --rm -i -e LOCAL_USER_ID=`id -u $USER` \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd \
 -v ${CASE_DIR}/gsiprd:/home/gsiprd \
 -v ${CASE_DIR}/wrfprd:/home/wrfprd \
 --name run-${CASE_NAME}-wrf ${WPS_WRF_IMAGE} /home/scripts/common/run_wrf.ksh -np 2

# UPP image name
if [ "${BUILD_UPP}" == "true" ]; then
   UPP_IMAGE=dtcenter/container-dtc-nwp-dev:upp_${SOURCE_BRANCH}
else
   UPP_IMAGE=dtcenter/upp:latest
fi

# Run UPP 
time_command \
docker run --rm -i -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/wrfprd:/home/wrfprd \
-v ${CASE_DIR}/postprd:/home/postprd \
--name run-${CASE_NAME}-upp ${UPP_IMAGE} /home/scripts/common/run_upp.ksh

# Python image name
if [ "${BUILD_PYTHON}" == "true" ]; then
   PYTHON_IMAGE=dtcenter/container-dtc-nwp-dev:python_${SOURCE_BRANCH}
else
   PYTHON_IMAGE=dtcenter/python:latest
fi

# Run Python
time_command \
docker run --rm -i -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${PROJ_DIR}/container-dtc-nwp/data/shapefiles:/home/data/shapefiles \
-v ${CASE_DIR}/postprd:/home/postprd \
-v ${CASE_DIR}/pythonprd:/home/pythonprd \
--name run-${CASE_NAME}-python ${PYTHON_IMAGE} /home/scripts/common/run_python.ksh

# MET image name
if [ "${BUILD_MET}" == "true" ]; then
   MET_IMAGE=dtcenter/container-dtc-nwp-dev:met_${SOURCE_BRANCH}
else
   MET_IMAGE=dtcenter/nwp-container-met:latest
fi

# Run MET
time_command \
docker run --rm -i -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/data:/data \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/postprd:/home/postprd \
-v ${CASE_DIR}/metprd:/home/metprd \
--name run-${CASE_NAME}-met ${MET_IMAGE} /home/scripts/common/run_met.ksh

# Copy docker-compose.yml to working directory
time_command cp ${PROJ_DIR}/container-dtc-nwp/components/metviewer/docker-compose.yml .

# METviewer image name
if [ "${BUILD_METVIEWER}" == "true" ]; then
   METVIEWER_IMAGE=dtcenter/container-dtc-nwp-dev:metviewer_${SOURCE_BRANCH}
   cat docker-compose.yml | sed "s%dtcenter/nwp-container-metviewer:latest%${METVIEWER_IMAGE}%g" > docker-compose.tmp
   mv docker-compose.tmp docker-compose.yml
fi

# Launch METviewer
time_command docker-compose up -d

# Load data and plot via METviewer only if configured to do so 
if [ "${RUN_METVIEWER}" == "true" ]; then

   echo "Running the METviewer database loading and plotting steps."

   # Sleep for 2 minutes before loading data
   time_command sleep 120

   # Load data into METviewer
   time_command docker exec -i metviewer /scripts/common/metv_load_all.ksh mv_${CASE_NAME}

   # Run METviewer to create plots
   for XML_FILE in `ls ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}/metviewer/*.xml`; do
      time_command docker exec -i metviewer /METviewer/bin/mv_batch.sh /scripts/${CASE_SCRIPT}/metviewer/`basename ${XML_FILE}`
   done
else
   echo "Skipping the METviewer database loading and plotting steps." 
fi

echo "Done with the ${CASE_NAME} case."
