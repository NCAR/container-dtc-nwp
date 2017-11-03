#!/bin/ksh -l

##########################################################################
#
# Script Name: met_point_verf_all.ksh
#
#      Author: John Halley Gotway
#              NCAR/RAL/DTC
#
#    Released: 10/26/2010
#
# Description:
#    This script runs the MET/Point-Stat tool to verify gridded output
#    from the WRF PostProcessor using point observations.  The MET/PB2NC
#    tool must be run on the PREPBUFR observation files to be used prior
#    to running this script.
#
#             START_TIME = The cycle time to use for the initial time.
#              FCST_TIME = The two-digit forecast that is to be verified.
#            DOMAIN_LIST = A list of domains to be verified.
#               GRID_VX  = 
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

# Print run parameters/masks
${ECHO}
${ECHO} "met_point_verf_all.ksh  started at `${DATE}`"
${ECHO}
${ECHO} "    START_TIME = ${START_TIME}"
${ECHO} "     FCST_TIME = ${FCST_TIME}"
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
PS_DIR=${DATAROOT}/metprd/point_stat
${MKDIR} -p ${PS_DIR}
PB2NC_DIR=${DATAROOT}/metprd/pb2nc
${MKDIR} -p ${PB2NC_DIR}

export MODEL
export FCST_TIME

########################################################################
# Compute VX date - only need to calculate once
########################################################################

# Compute the verification date
VDATE=`    ${CALC_DATE} ${START_TIME} +${FCST_TIME}`
VYYYYMMDD=`${ECHO} ${VDATE} | ${CUT} -c1-8`
VHH=`      ${ECHO} ${VDATE} | ${CUT} -c9-10`
${ECHO} 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

########################################################################
# Run pb2nc on prepbufr obs file - only need to run once
########################################################################

# Check for pb2nc output file name
OBS_FILE="${PB2NC_DIR}/prepbufr.ndas.${VYYYYMMDD}.t${VHH}z.nc"

if [ ! -e ${OBS_FILE} ]; then

  # Specify the MET PB2NC configuration file to be used
  export CONFIG_PB2NC="${MET_CONFIG}/PB2NCConfig_RefConfig"

  # Make sure the MET configuration files exists
  if [ ! -e ${CONFIG_PB2NC} ]; then
    echo "ERROR: ${CONFIG_PB2NC} does not exist!"
    exit 1
  fi

  # Process time information -- NDAS specific
    if [[ ${VHH} == "00" || ${VHH} == "06" || ${VHH} == "12" || ${VHH} == "18" ]]; then
    TMMARK="tm12"
  elif [[ ${VHH} == "03" || ${VHH} == "09" || ${VHH} == "15" || ${VHH} == "21" ]]; then
    TMMARK="tm09"
  else
    echo "ERROR: Valid hour is not compatible with using NDAS data."
    exit 1
  fi

  # Determine the NDAS time stamps
  TM_HR=`echo ${TMMARK} | cut -c3-4`
  NDAS_YMDH=`${CALC_DATE} ${VDATE} +${TM_HR} -fmt %Y%m%d%H`
  NDAS_HR=`  ${CALC_DATE} ${VDATE} +${TM_HR} -fmt %H`

  # List observation file to be run through pb2nc
  PB_FILE=`${LS} ${RAW_OBS}/${NDAS_YMDH}/ndas.t${NDAS_HR}z.prepbufr.${TMMARK}.nr | head -1`
  if [ ! -e ${PB_FILE} ]; then
    echo "ERROR: Could not find observation file: ${PB_FILE}"
    exit 1
  fi

  # Call PB2NC
  ${RUN_CMD} /usr/bin/time ${MET_EXE_ROOT}/pb2nc \
             ${PB_FILE} ${OBS_FILE} ${CONFIG_PB2NC} -v 2
  if [ $? -ne 0 ]; then
    exit 1
  fi

fi

########################################################################
# Run point_stat for each domain
########################################################################

# Loop through the domain list
for DOMAIN in ${DOMAIN_LIST}; do

  export DOMAIN
  export ${GRID_VX}
  ${ECHO} "DOMAIN=${DOMAIN}"

  # Get the forecast to verify
  FCST_FILE=${DATAROOT}/postprd/wrfprs_${DOMAIN}.${FCST_TIME}

  if [ ! -e ${FCST_FILE} ]; then
    ${ECHO} "ERROR: Could not find UPP output file: ${FCST_FILE}"
    exit 1
  fi

  #######################################################################
  # Run Point-Stat
  #######################################################################

  # Specify the MET Point-Stat configuration files to be used
  PS_CONFIG_LIST="${MET_CONFIG}/PointStatConfig_ADPUPA \
                  ${MET_CONFIG}/PointStatConfig_ADPSFC \
                  ${MET_CONFIG}/PointStatConfig_ADPSFC_MPR \
                  ${MET_CONFIG}/PointStatConfig_WINDS"

  for CONFIG_FILE in ${PS_CONFIG_LIST}; do

    # Only verify ADPUPA for 00 and 12
    if [[ ${CONFIG_FILE} =~ "ADPUPA" && ${VHH} != "00" && ${VHH} != "12" ]]; then
      continue
    fi

    # Make sure the configuration file exists
    if [ ! -e ${CONFIG_FILE} ]; then
      ${ECHO} "ERROR: ${CONFIG_FILE} does not exist!"
       exit 1
    fi

    ${RUN_CMD} /usr/bin/time ${MET_EXE_ROOT}/point_stat \
               ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
               -outdir ${PS_DIR} -v 2
    if [ $? -ne 0 ]; then
      exit 1
    fi

  done # for CONFIG_FILE

done # for DOMAIN

##########################################################################

${ECHO} "met_point_verf_all.ksh completed at `${DATE}`"

exit 0

