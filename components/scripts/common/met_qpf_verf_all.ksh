#!/bin/ksh -l

##########################################################################
#
# Script Name: met_qpf_verf_all.ksh
#
#      Author: John Halley Gotway
#              NCAR/RAL/DTC
#
#    Released: 10/26/2010
#
# Description:
#    This script runs the MET/Grid-Stat and MODE tools to verify gridded
#    precipitation forecasts against gridded precipitation analyses.
#    The precipitation fields must first be placed on a common grid prior
#    to running this script.
#
#             START_TIME = The cycle time to use for the initial time.
#              FCST_TIME = The two-digit forecast that is to be verified.
#             ACCUM_TIME = The two-digit accumulation time: 03 or 24.
#            BUCKET_TIME = The accumulation time in the model (bucket): 6.
#            DOMAIN_LIST = A list of domains to be verified.
#                GRID_VX =
#           MET_EXE_ROOT = The full path of the MET executables.
#             MET_CONFIG = The full path of the MET configuration files.
#               DATAROOT = Directory containing /postprd and /metprd.
#                RAW_OBS = Directory containing observations to be used.
#                  MODEL = The model being evaluated.
#
##########################################################################

LS=/usr/bin/ls
MKDIR=/usr/bin/mkdir
ECHO=/usr/bin/echo
CUT=/usr/bin/cut
DATE=/usr/bin/date
CALC_DATE=/scripts/common/calc_date.ksh
RUN_CMD=/scripts/common/run_command.ksh

typeset -Z2 FCST_TIME
typeset -Z2 ACCUM_TIME
typeset -Z2 BUCKET_TIME

# Print run parameters
${ECHO}
${ECHO} "met_qpf_verf_all.ksh started at `${DATE}`"
${ECHO}
${ECHO} "    START_TIME = ${START_TIME}"
${ECHO} "     FCST_TIME = ${FCST_TIME}"
${ECHO} "    ACCUM_TIME = ${ACCUM_TIME}"
${ECHO} "   BUCKET_TIME = ${BUCKET_TIME}"
${ECHO} "   DOMAIN_LIST = ${DOMAIN_LIST}"
${ECHO} "       GRID_VX = ${GRID_VX}"
${ECHO} "  MET_EXE_ROOT = ${MET_EXE_ROOT}"
${ECHO} "    MET_CONFIG = ${MET_CONFIG}"
${ECHO} "      DATAROOT = ${DATAROOT}"
${ECHO} "       RAW_OBS = ${RAW_OBS}"
${ECHO} "         MODEL = ${MODEL}"

# Make sure $DATAROOT exists
if [ ! -d "${DATAROOT}" ]; then
  ${ECHO} "ERROR: DATAROOT, ${DATAROOT} does not exist"
  exit 1
fi

# Make sure RAW_OBS directory exists
if [ ! -d ${RAW_OBS} ]; then
  ${ECHO} "ERROR: RAW_OBS, ${RAW_OBS}, does not exist!"
  exit 1
fi

# Create output directories
GS_DIR=${DATAROOT}/metprd/grid_stat
${MKDIR} -p ${GS_DIR}
PCP_COMBINE_DIR=${DATAROOT}/metprd/pcp_combine
${MKDIR} -p ${PCP_COMBINE_DIR}

export MODEL
export FCST_TIME
export ACCUM_TIME

########################################################################
# Compute VX date - only need to calculate once
########################################################################

# Compute the verification date
VDATE=`     ${CALC_DATE} ${START_TIME} +${FCST_TIME}`
VYYYYMMDD=` ${ECHO} ${VDATE} | ${CUT} -c1-8`
VHH=`       ${ECHO} ${VDATE} | ${CUT} -c9-10`
PVYYYYMMDD=`${CALC_DATE} ${VDATE} -24 -fmt %Y%m%d`
${ECHO} 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

########################################################################
# Run pcp_combine on ccpa obs file - only need to run once
########################################################################

# Create a pcp_combine output file name
OBS_FILE="${PCP_COMBINE_DIR}/STAGEII_${ACCUM_TIME}H_${VYYYYMMDD}${VHH}.nc"

if [ ! -e ${OBS_FILE} ]; then

  # Run pcp_combine sum to make desired accumulation interval
  RAW_OBS_DIR=${RAW_OBS}/${VYYYYMMDD}
  if [ ! -e ${RAW_OBS_DIR} ]; then
    ${ECHO} "ERROR: ${RAW_OBS_DIR} does not exist!"
  exit 1
  fi

  # Only point to previous date directory if it exists
  PRV_RAW_OBS_DIR=${RAW_OBS}/${PVYYYYMMDD}
  if [ -e ${PRV_RAW_OBS_DIR} ]; then
    PRV_DIR_ARGS="-pcpdir ${PRV_RAW_OBS_DIR}"
  else
    PRV_DIR_ARGS=""
  fi

  PCP_COMBINE_ARGS="-sum 00000000_000000 ${BUCKET_TIME} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} \
                    -pcpdir ${RAW_OBS_DIR} ${PRV_DIR_ARGS} \
                    -name APCP_${ACCUM_TIME} ${OBS_FILE}"

  # Call pcp_combine 
  ${RUN_CMD} /usr/bin/time ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}
  if [ $? -ne 0 ]; then
    exit 1
  fi

fi

########################################################################
# Run grid_stat for each domain
########################################################################

# Loop through the domain list
for DOMAIN in ${DOMAIN_LIST}; do
   
  export DOMAIN
  export GRID_VX
  ${ECHO} "DOMAIN=${DOMAIN}"

  # Check for pcp_combine output forecast file name
  FCST_FILE=${DATAROOT}/metprd/pcp_combine/wrfprs_${DOMAIN}_${START_TIME}_f${FCST_TIME}_APCP_${ACCUM_TIME}h.nc

  if [ ! -e ${FCST_FILE} ]; then

    # Run pcp_combine subtract to make desired accumulation interval
    POSTPRD_DIR=${DATAROOT}/postprd
    if [ ! -e ${POSTPRD_DIR} ]; then
      ${ECHO} "ERROR: ${POSTPRD_DIR} does not exist!"
      exit 1
    fi	 

    # Get the current and previous post-processed files
    typeset -Z2 PRV_FCST_TIME
    PRV_FCST_TIME=$(( $FCST_TIME - $ACCUM_TIME ))
    CUR_POST_FILE=${POSTPRD_DIR}/wrfprs_${DOMAIN}.${FCST_TIME}
    PRV_POST_FILE=${POSTPRD_DIR}/wrfprs_${DOMAIN}.${PRV_FCST_TIME}

    # Run the pcp_combine subtract command
    ${RUN_CMD} /usr/bin/time ${MET_EXE_ROOT}/pcp_combine -subtract \
               ${CUR_POST_FILE} ${FCST_TIME} \
               ${PRV_POST_FILE} ${PRV_FCST_TIME} \
               ${FCST_FILE} -name APCP_${ACCUM_TIME} -v 2
    if [ $? -ne 0 ]; then
      exit 1
    fi

  fi

  #######################################################################
  # Run Grid-Stat
  #######################################################################

  GS_CONFIG_LIST="${MET_CONFIG}/GridStatConfig_${ACCUM_TIME}h"

  for CONFIG_FILE in ${GS_CONFIG_LIST}; do

    # Make sure the Grid-Stat configuration file exists
    if [ ! -e ${CONFIG_FILE} ]; then
      ${ECHO} "ERROR: ${CONFIG_FILE} does not exist!"
       exit 1
    fi

    ${RUN_CMD} /usr/bin/time ${MET_EXE_ROOT}/grid_stat \
               ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
               -outdir ${GS_DIR} -v 2
    if [ $? -ne 0 ]; then
      exit 1
    fi

  done # for CONFIG_FILE

done # for DOMAIN

##########################################################################

${ECHO} "met_qpf_verf_all.ksh completed at `${DATE}`"

exit 0
