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

# Locate run_command.ksh script 
SCRIPT_DIR=`dirname $0`
export RUN_CMD=${SCRIPT_DIR}/run_command.ksh

# Setup the environment
${RUN_CMD} setenv CASE_DIR ${PROJ_DIR}/${CASE_NAME}; mkdir -p ${CASE_DIR}; cd ${CASE_DIR}
${RUN_CMD} mkdir -p wpsprd wrfprd gsiprd postprd nclprd metprd metviewer/mysql

# Run WPS 
${RUN_CMD} time \
 docker run --rm -it --volumes-from wps_geog --volumes-from ${CASE_NAME} \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd \
 --name run-${CASE_NAME}-wps dtc-wps_wrf /home/scripts/common/run_wps.ksh

# Run Real
${RUN_CMD} time \
 docker run --rm -it --volumes-from ${CASE_NAME} \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd -v ${CASE_DIR}/wrfprd:/home/wrfprd \
 --name run-${CASE_NAME}-real dtc-wps_wrf /home/scripts/common/run_real.ksh

# Run GSI
${RUN_CMD} time \
 docker run --rm -it --volumes-from gsi_data --volumes-from ${CASE_NAME} \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*:/home/scripts/case \
 -v ${CASE_DIR}/gsiprd:/home/gsiprd -v ${CASE_DIR}/wrfprd:/home/wrfprd \
 --name run-${CASE_NAME}-gsi dtc-gsi /home/scripts/common/run_gsi.ksh

# Run WRF
${RUN_CMD} time \
 docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd -v ${CASE_DIR}/gsiprd:/home/gsiprd -v ${CASE_DIR}/wrfprd:/home/wrfprd \
 --name run-${CASE_NAME}-wrf dtc-wps_wrf /home/scripts/common/run_wrf.ksh

# Run UPP 
${RUN_CMD} time \
 docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*:/home/scripts/case \
 -v ${CASE_DIR}/wrfprd:/home/wrfprd -v ${CASE_DIR}/postprd:/home/postprd \
 --name run-${CASE_NAME}-upp dtc-upp /home/scripts/common/run_upp.ksh

# Run NCL
${RUN_CMD} time \
 docker run --rm -it \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*:/home/scripts/case \
 -v ${CASE_DIR}/wpsprd:/home/wpsprd -v ${CASE_DIR}/wrfprd:/home/wrfprd -v ${CASE_DIR}/nclprd:/home/nclprd \
 --name run-${CASE_NAME}-ncl dtc-ncl /home/scripts/common/run_ncl.ksh

# Run MET
${RUN_CMD} time \
 docker run --rm -it --volumes-from ${CASE_NAME} \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
 -v ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*:/home/scripts/case \
 -v ${CASE_DIR}/postprd:/home/postprd -v ${CASE_DIR}/metprd:/home/metprd \
 --name run-${CASE_NAME}-met dtc-met /home/scripts/common/run_met.ksh

# Load MET output into METviewer
${RUN_CMD} cd ${PROJ_DIR}/container-dtc-nwp/components/metviewer
${RUN_CMD} docker-compose up -d
${RUN_CMD} time docker exec -it metviewer /scripts/common/metv_load_all.ksh mv_${CASE_NAME}

# Run METviewer to create plots
for XML_FILE in `ls ${PROJ_DIR}/container-dtc-nwp/components/scripts/${CASE_NAME}*/metviewer/*.xml`; do
  ${RUN_CMD} time docker exec -it metviewer /METviewer/bin/mv_batch.sh /home/scripts/case/metviewer/`basename ${XML_FILE}` 
done

echo "Done with the ${CASE_NAME} case."
 
