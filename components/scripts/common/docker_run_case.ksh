#!/bin/ksh 

#
# Run all commands for a particular tutorial case.
# This script should be run OUTSIDE of the containers.
#

# Make sure that ${PROJ_DIR} has been set
if [[ ! -e $PROJ_DIR ]]; then
  echo 
  echo "ERROR: The ${PROJ_DIR} environment variable must be set."
  echo
  exit 1
fi

# Make sure there is exactly 1 argument and store the case name
if [ $# -ne 1 ]; then
  echo
  echo "ERROR: Must specify the case to run (sandy, derecho, or snow)."
  echo
  exit 1
fi
CASE_NAME=$1

# Determine if on AWS based on the user name
if [ $USER == "ec2-user" ]; then
  echo "Running on AWS."
  IS_AWS="true"
fi

# Function for executing and timing commands
RUN_CMD () {

  if [ $# -eq 0 ]; then
    echo
    echo "ERROR: ${SCRIPT} zero arguments."
    echo
    exit 1
  fi

  # Run the command
  echo
  echo "RUNNING: time $*"
  echo
  time $*

  # Check the return status
  error=$?
  if [ ${error} -ne 0 ]; then
    echo "ERROR:"
    echo "ERROR: $* exited with status = ${error}"
    echo "ERROR:"
    exit ${error}
  fi
}

# Locate case-specific scripts
CASE_SCRIPT=`basename ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*`

# Setup the environment
RUN_CMD export CASE_DIR=${PROJ_DIR}/${CASE_NAME}
RUN_CMD mkdir -p ${CASE_DIR}; cd ${CASE_DIR}
RUN_CMD mkdir -p wpsprd wrfprd gsiprd postprd nclprd metprd metviewer/mysql

# Run WPS
RUN_CMD \
docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/data/WPS_GEOG:/data/WPS_GEOG \
-v ${PROJ_DIR}/container-dtc-nwp/data:/data \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/wpsprd:/home/wpsprd \
--name run-${CASE_NAME}-wps dtcenter/wps_wrf:3.4 \
/home/scripts/common/run_wps.ksh

# Run Real
RUN_CMD \
docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/data:/data \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/wpsprd:/home/wpsprd \
-v ${CASE_DIR}/wrfprd:/home/wrfprd \
--name run-${CASE_NAME}-real dtcenter/wps_wrf:3.4 \
/home/scripts/common/run_real.ksh

# Run GSI
RUN_CMD \
docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/data:/data \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/gsiprd:/home/gsiprd \
-v ${CASE_DIR}/wrfprd:/home/wrfprd \
--name run-${CASE_NAME}-gsi dtcenter/gsi:3.4 \
/home/scripts/common/run_gsi.ksh

# Run WRF
RUN_CMD \
docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd \
 -v ${CASE_DIR}/gsiprd:/home/gsiprd \
 -v ${CASE_DIR}/wrfprd:/home/wrfprd \
 --name run-${CASE_NAME}-wrf dtcenter/wps_wrf:3.4 /home/scripts/common/run_wrf.ksh

# Run UPP 
RUN_CMD \
docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/wrfprd:/home/wrfprd \
-v ${CASE_DIR}/postprd:/home/postprd \
--name run-${CASE_NAME}-upp dtcenter/upp:3.4 /home/scripts/common/run_upp.ksh

# Run NCL
RUN_CMD \
docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/postprd:/home/postprd \
-v ${CASE_DIR}/pythonprd:/home/pythonprd \
--name run-${CASE_NAME}-python dtcenter/python:3.4 /home/scripts/common/run_python.ksh

# Run MET
RUN_CMD \
docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/data:/data \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}:/home/scripts/case \
-v ${CASE_DIR}/postprd:/home/postprd \
-v ${CASE_DIR}/metprd:/home/metprd \
--name run-${CASE_NAME}-met dtcenter/nwp-container-met:3.4 /home/scripts/common/run_met.ksh

# Load MET output into METviewer
RUN_CMD cd ${PROJ_DIR}/container-dtc-nwp/components/metviewer
if [ -n "${IS_AWS}" ]; then
  RUN_CMD docker-compose -f docker-compose-AWS.yml up -d
else
  RUN_CMD docker-compose up -d
fi

# Sleep for 2 minutes before loading data
RUN_CMD sleep 120

# Load data into METviewer
RUN_CMD docker exec -it metviewer /scripts/common/metv_load_all.ksh mv_${CASE_NAME}

# Run METviewer to create plots
for XML_FILE in `ls ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_SCRIPT}/metviewer/*.xml`; do
  RUN_CMD docker exec -it metviewer /METviewer/bin/mv_batch.sh /home/scripts/case/metviewer/`basename ${XML_FILE}`
done

echo "Done with the ${CASE_NAME} case."
 
