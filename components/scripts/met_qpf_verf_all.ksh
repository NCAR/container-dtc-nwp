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
#              FCST_TIME = The three-digit forecasts that is to be verified.
#             ACCUM_TIME = The two-digit accumulation time: 03 or 24.
#            BUCKET_TIME = The accumulation time in the model (bucket): 6.
#            DOMAIN_LIST = A list of domains to be verified.
#           MET_EXE_ROOT = The full path of the MET executables.
#             MET_CONFIG = The full path of the MET configuration files.
#               DATAROOT = Top-level data directory of WRF output.
#                RAW_OBS = Directory containing observations to be used.
#                  MODEL = The model being evaluated.
#
##########################################################################

MKDIR=/bin/mkdir
ECHO=/bin/echo
CUT=`which cut`
DATE=/bin/date
CALC_DATE=/scripts/calc_date.ksh
LD_LIBRARY_PATH=/glade/p/ral/jnt/tools/MET_external_libs_intel/lib
export LD_LIBRARY_PATH

# Print run parameters
${ECHO}
${ECHO} "met_qpf_verf_all.ksh started at `${DATE}`"
${ECHO}
${ECHO} "    START_TIME = ${START_TIME}"
${ECHO} "     FCST_TIME = ${FCST_TIME}"
${ECHO} "    ACCUM_TIME = ${ACCUM_TIME}"
${ECHO} "   BUCKET_TIME = ${BUCKET_TIME}"
${ECHO} "   DOMAIN_LIST = ${DOMAIN_LIST}"
${ECHO} "  MET_EXE_ROOT = ${MET_EXE_ROOT}"
${ECHO} "    MET_CONFIG = ${MET_CONFIG}"
${ECHO} "      DATAROOT = ${DATAROOT}"
${ECHO} "       GRID_VX = ${GRID_VX}"
${ECHO} "       RAW_OBS = ${RAW_OBS}"
${ECHO} "         MODEL = ${MODEL}"

# Make sure $DATAROOT exists
if [ ! -d "${DATAROOT}" ]; then
  ${ECHO} "ERROR: DATAROOT, ${DATAROOT} does not exist"
  exit 1
fi

# Make sure $DATAROOT/postprd exists
if [ ! -d "${DATAROOT}/postprd" ]; then
  ${ECHO} "ERROR: DATAROOT/postprd, ${DATAROOT}/postprd does not exist"
  exit 1
fi

# Make sure RAW_OBS directory exists
if [ ! -d ${RAW_OBS} ]; then
  ${ECHO} "ERROR: RAW_OBS, ${RAW_OBS}, does not exist!"
  exit 1
fi

# Go to working directory
workdir=${DATAROOT}/metprd/grid_stat
${MKDIR} -p ${workdir}/pcp_combine
pcp_combine_dir=${MOAD_DATAROOT}/pcp_combine
${MKDIR} -p ${pcp_combine_dir}
cd ${workdir}

export MODEL
${ECHO} "MODEL=${MODEL}"

# Loop through the forecast times
#for FCST_TIME in ${FCST_TIME_LIST}; do

export FCST_TIME

# Loop through the domain list
for DOMAIN in ${DOMAIN_LIST}; do
   
    export DOMAIN
    export GRID_VX
    ${ECHO} "DOMAIN=${DOMAIN}"
    ${ECHO} "GRID_VX=${GRID_VX}"
    ${ECHO} "FCST_TIME=${FCST_TIME}"

    # Compute the verification date
    YYYYMMDD=`${ECHO} ${START_TIME} | ${CUT} -c1-8`
    HH=`${ECHO} ${START_TIME} | ${CUT} -c9-10`
    VDATE=`${CALC_DATE} ${START_TIME} +${FCST_TIME}`
    VYYYYMMDD=`${ECHO} ${VDATE} | ${CUT} -c1-8`
    VYYYY=`${ECHO} ${VDATE} | ${CUT} -c1-4`
    VMM=`${ECHO} ${VDATE} | ${CUT} -c5-6`
    VDD=`${ECHO} ${VDATE} | ${CUT} -c7-8`
    VHH=`${ECHO} ${VDATE} | ${CUT} -c9-10`
    ${ECHO} 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

    PVDATE=`${CALC_DATE} ${VDATE} -24`
    PVYYYYMMDD=`${ECHO} ${PVDATE} | ${CUT} -c1-8`

    # Specify the MET Grid-Stat and MODE configuration files to be used
    GS_CONFIG_LIST="${MET_CONFIG}/GridStatConfig_${ACCUM_TIME}h"

    #######################################################################
    #
    #  Run PCP-Combine
    #
    #######################################################################
    # Run pcp_combine on 1-hourly HRRR model output to make appropriate accumulation times
    #FCST_GRIB_FILE_DIR=${DATAROOT}/postprd/wrfprs_${DOMAIN}.${FCST_TIME}
    FCST_GRIB_FILE_DIR=${DATAROOT}/postprd
    if [ ! -e ${FCST_GRIB_FILE_DIR} ]; then
       ${ECHO} "ERROR: ${FCST_GRIB_FILE_DIR} does not exist!"
       exit 1
    fi	 

    FCST_FILE=${DATAROOT}/metprd/pcp_combine/wrfprs_${DOMAIN}_${START_TIME}_f${FCST_TIME}_APCP_${ACCUM_TIME}h.nc
    PCP_COMBINE_ARGS="-sum ${YYYYMMDD}_${HH}0000 ${BUCKET_TIME} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${FCST_GRIB_FILE_DIR} -pcprx \"wrfprs\" -name \"APCP_${ACCUM_TIME}\" ${FCST_FILE}"

    # Run the PCP-Combine command
    ${ECHO} "CALLING: ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}"

    ${MET_EXE_ROOT}/pcp_combine -sum ${YYYYMMDD}_${HH}0000 ${BUCKET_TIME} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${FCST_GRIB_FILE_DIR} -pcprx "wrfprs" -name "APCP_${ACCUM_TIME}" ${FCST_FILE}

    error=$?
    if [ ${error} -ne 0 ]; then
        ${ECHO} "${MET_EXE_ROOT}/pcp_combine crashed!  Exit status=${error}"
        exit ${error}
    fi

    # Create a PCP-COMBINE output file name
    OBS_FILE=${pcp_combine_dir}/GaugeCorr_QPE_${ACCUM_TIME}H_00.00_${VYYYYMMDD}-${VHH}0000.nc

    if [ ! -e ${OBS_FILE} ]; then
      # Run pcp_combine on 1-hourly MRMS observations to make appropriate accumulation times
      RAW_OBS_DIR=${RAW_OBS}/${VYYYYMMDD}
      if [ ! -e ${RAW_OBS_DIR} ]; then
         ${ECHO} "ERROR: ${RAW_OBS_DIR} does not exist!"
         exit 1
      fi	 
      PREV_RAW_OBS_DIR=${RAW_OBS}/${PVYYYYMMDD}
      if [ ! -e ${PREV_RAW_OBS_DIR} ]; then
         ${ECHO} "ERROR: ${PREV_RAW_OBS_DIR} does not exist!"
         exit 1
      fi	 

      PCP_COMBINE_ARGS="-sum 00000000_000000 ${BUCKET_TIME} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${RAW_OBS_DIR} -pcpdir ${PREV_RAW_OBS_DIR} -field 'name=\"GaugeCorrQPE01H\"; level=\"L0\";' -name \"APCP_${ACCUM_TIME}\" ${OBS_FILE}"

      # Run the PCP-Combine command
      ${ECHO} "CALLING: ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}"

      ${MET_EXE_ROOT}/pcp_combine -sum 00000000_000000 ${BUCKET_TIME} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${RAW_OBS_DIR} -pcpdir ${PREV_RAW_OBS_DIR} -field 'name="GaugeCorrQPE01H"; level="L0";' -name "APCP_${ACCUM_TIME}" ${OBS_FILE}

      error=$?
      if [ ${error} -ne 0 ]; then
          ${ECHO} "${MET_EXE_ROOT}/pcp_combine crashed!  Exit status=${error}"
          exit ${error}
      fi
    fi 

    #######################################################################
    #
    #  Run Grid-Stat
    #
    #######################################################################

    for CONFIG_FILE in ${GS_CONFIG_LIST}; do

        # Make sure the Grid-Stat configuration file exists
        if [ ! -e ${CONFIG_FILE} ]; then
            ${ECHO} "ERROR: ${CONFIG_FILE} does not exist!"
            exit 1
        fi

####jkw Passing it G130 to regrid but that is RAP and this is HRRR - needs to be fixed!!####
        ${ECHO} "CALLING: ${MET_EXE_ROOT}/grid_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

        ${MET_EXE_ROOT}/grid_stat \
          ${FCST_FILE} \
          ${OBS_FILE} \
          ${CONFIG_FILE} \
          -outdir . \
          -v 2

        error=$?
        if [ ${error} -ne 0 ]; then
            ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/grid_stat crashed  Exit status: ${error}"
            exit ${error}
        fi

    done

done
#done

##########################################################################

${ECHO} "met_qpf_verf_all.ksh completed at `${DATE}`"

exit 0
