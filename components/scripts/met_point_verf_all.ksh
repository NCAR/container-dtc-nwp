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
#             FCST_TIME  = The two-digit forecast that is to be verified.
#            DOMAIN_LIST = A list of domains to be verified.
#           MET_EXE_ROOT = The full path of the MET executables.
#             MET_CONFIG = The full path of the MET configuration files.
#           UNIPOST_EXEC = The full path of the UPP executables.
#               DATAROOT = Top-level data directory of WRF output.
#                RAW_OBS = Directory containing observations to be used.
#                  MODEL = The model being evaluated.
#
##########################################################################

LS=/bin/ls
MKDIR=/bin/mkdir
ECHO=/bin/echo
CUT=`which cut`
DATE=/bin/date
CALC_DATE=/scripts/calc_date.ksh
LD_LIBRARY_PATH=/glade/p/ral/jnt/tools/MET_external_libs_intel/lib
export LD_LIBRARY_PATH

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
${ECHO} "  UNIPOST_EXEC = ${UNIPOST_EXEC}"
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

# Go to working directory
workdir=/metprd
${MKDIR} -p ${workdir}
cd ${workdir}

export MODEL
export FCST_TIME
${ECHO} "MODEL=${MODEL}"
${ECHO} "FCST_TIME=${FCST_TIME}"

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

# Go to prepbufr dir
pb2nc=/metprd/pb2nc
${MKDIR} -p ${pb2nc}

# Create a PB2NC output file name
OBS_FILE="${pb2nc}/prepbufr.ndas.${VYYYYMMDD}.t${VHH}z.nc"

if [ ! -e ${OBS_FILE} ]; then

  # Specify the MET PB2NC configuration file to be used
  export CONFIG_PB2NC="${MET_CONFIG}/PB2NCConfig_RefConfig"

  # Make sure the MET configuration files exists
  if [ ! -e ${CONFIG_PB2NC} ]; then
    echo "ERROR: ${CONFIG_PB2NC} does not exist!"
    exit 1
  fi

  # Process time information -- NDAS specific
  # For retro NDAS vx, use "late" files, which are tm09 and tm12.
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

  NDAS_YMD=`${DATE} -ud '1970-01-01 UTC '${NDAS_UT}' seconds' +%Y%m%d`
  NDAS_HR=` ${DATE} -ud '1970-01-01 UTC '${NDAS_UT}' seconds' +%H`

  # List observation file to be run through pb2nc
  PB_FILE=`${LS} ${RAW_OBS}/${NDAS_YMDH}/ndas.t${NDAS_HR}z.prepbufr.${TMMARK}.nr | head -1`
  if [ ! -e ${PB_FILE} ]; then
    echo "ERROR: Could not find observation file: ${PB_FILE}"
    exit 1
  fi

  # Call PB2NC
  echo "CALLING: ${MET_EXE_ROOT}/pb2nc ${PB_FILE} ${OBS_FILE} ${CONFIG_PB2NC} -v 2"

  ${MET_EXE_ROOT}/pb2nc ${PB_FILE} ${OBS_FILE} ${CONFIG_PB2NC} -v 2

fi

########################################################################
# Run point stat for each domain
########################################################################

# Loop through the domain list
for DOMAIN in ${DOMAIN_LIST}; do

   export DOMAIN
   export ${GRID_VX}
   ${ECHO} "DOMAIN=${DOMAIN}"
   ${ECHO} "GRID_VX=${GRID_VX}"
   ${ECHO} "FCST_TIME=${FCST_TIME}"

   # Specify the MET Point-Stat configuration files to be used
   CONFIG_ADPUPA="${MET_CONFIG}/PointStatConfig_ADPUPA"
   CONFIG_ADPSFC="${MET_CONFIG}/PointStatConfig_ADPSFC"
   CONFIG_ADPSFC_MPR="${MET_CONFIG}/PointStatConfig_ADPSFC_MPR"
   CONFIG_WINDS="${MET_CONFIG}/PointStatConfig_WINDS"

   # Make sure the Point-Stat configuration files exists
   if [ ! -e ${CONFIG_ADPUPA} ]; then
       ${ECHO} "ERROR: ${CONFIG_ADPUPA} does not exist!"
       exit 1
   fi
   if [ ! -e ${CONFIG_ADPSFC} ]; then
       ${ECHO} "ERROR: ${CONFIG_ADPSFC} does not exist!"
       exit 1
   fi
   if [ ! -e ${CONFIG_ADPSFC_MPR} ]; then
       ${ECHO} "ERROR: ${CONFIG_ADPSFC_MPR} does not exist!"
       exit 1
   fi
   if [ ! -e ${CONFIG_WINDS} ]; then
       ${ECHO} "ERROR: ${CONFIG_WINDS} does not exist!"
       exit 1
   fi

   # Check the RAP prepbufr observation file (created from previous command to run pb2nc)
   ${ECHO} "OBS_FILE: ${OBS_FILE}"

   if [ ! -e ${OBS_FILE} ]; then
     ${ECHO} "ERROR: Could not find observation file: ${OBS_FILE}"
     exit 1
   fi

   # Get the forecast to verify
   FCST_FILE=${DATAROOT}/wrfprs_${DOMAIN}.${FCST_TIME}

   if [ ! -e ${FCST_FILE} ]; then
     ${ECHO} "ERROR: Could not find UPP output file: ${FCST_FILE}"
     exit 1
   fi

   #######################################################################
   #
   #  Run Point-Stat
   #
   #######################################################################

   # Verify upper air variables only at 00Z and 12Z
   if [ "${VHH}" == "00" -o "${VHH}" == "12" ]; then
     CONFIG_FILE=${CONFIG_ADPUPA}

     /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
       -outdir . -v 2

     error=$?
     if [ ${error} -ne 0 ]; then
       ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
       exit ${error}
     fi
   fi

   # Verify surface variables for each forecast hour
   CONFIG_FILE=${CONFIG_ADPSFC}

   ${ECHO} "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

   /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
      -outdir . -v 2

   error=$?
   if [ ${error} -ne 0 ]; then
     ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
     exit ${error}
   fi

   # Verify surface variables for each forecast hour - MPR output
   CONFIG_FILE=${CONFIG_ADPSFC_MPR}

   ${ECHO} "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

   /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
     -outdir . -v 2

   error=$?
   if [ ${error} -ne 0 ]; then
     ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
     exit ${error}
   fi

   # Verify winds for each forecast hour
   CONFIG_FILE=${CONFIG_WINDS}

   ${ECHO} "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

   /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
     -outdir . -v 2

   error=$?
   if [ ${error} -ne 0 ]; then
     ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
     exit ${error}
   fi

done

##########################################################################

${ECHO} "met_point_verf_all.ksh completed at `${DATE}`"

exit 0

