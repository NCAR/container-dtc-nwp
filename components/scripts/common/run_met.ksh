#!/bin/ksh -x
  
#
# Simplified script to run MET in Docker world
#

# Constants
MET_BUILD="/comsoftware/met"
SCRIPT_DIR="/home/scripts/common"
CASE_DIR="/home/scripts/case"
POSTPRD_DIR="/home/postprd"
METPRD_DIR="/home/metprd"
LOG_FILE="${METPRD_DIR}/run_met.log"
OBS_BASE_DIR="/data/obs_data"

# Check for the correct container
if [[ ! -e $MET_BUILD ]]; then
  echo
  echo ERROR: MET can only be run with the dtc-met container.
  echo
  exit 1
fi

# Check for input directory
if [[ ! -e $POSTPRD_DIR ]]; then
  echo
  echo ERROR: The $POSTPRD_DIR directory is not mounted.
  echo
  exit 1
fi

# Check for output directory
if [[ ! -e $METPRD_DIR ]]; then
  echo
  echo ERROR: The $METPRD_DIR directory is not mounted.
  echo
  exit 1
fi

# Include case-specific settings
. $CASE_DIR/set_env.ksh

##################################
#   Run MET                      #
##################################

echo "Running MET and writing log file: ${LOG_FILE}" | tee $LOG_FILE

# Constants for all cases
export MET_EXE_ROOT=${MET_BUILD}/bin
export MET_CONFIG=/home/scripts/case/met_config
export DATAROOT=/home/
export CALC_DATE=${SCRIPT_DIR}/calc_date.ksh
export RUN_CMD=${SCRIPT_DIR}/run_command.ksh

cd $METPRD_DIR

cp $SCRIPT_DIR/met_qpf_verf_all.ksh .
cp $SCRIPT_DIR/met_point_verf_all.ksh .

# Define times as 2-digits
typeset -Z2 FCST_TIME
typeset -Z2 ACCUM_TIME
typeset -Z2 BUCKET_TIME

# Loop through the forecast hours
FCST_TIME=$FCST_HR_BEG
while [ $FCST_TIME -le $FCST_HR_END ] ; do

  echo "FCST_TIME = $FCST_TIME" | tee -a $LOG_FILE
  export FCST_TIME

  # Do point verification
  export RAW_OBS=${OBS_BASE_DIR}/prepbufr
  ./met_point_verf_all.ksh | tee -a $LOG_FILE

  # Do qpf verification
  if [ $FCST_TIME -ge $ACCUM_TIME ]; then
    echo "ACCUM_TIME = $ACCUM_TIME" | tee -a $LOG_FILE
    echo "BUCKET_TIME = $BUCKET_TIME" | tee -a $LOG_FILE
    export ACCUM_TIME
    export BUCKET_TIME
    export RAW_OBS=${OBS_BASE_DIR}/qpe
    ./met_qpf_verf_all.ksh | tee -a $LOG_FILE
  fi

  # Increment the forecast hour
  FCST_TIME=$(( $FCST_TIME + $FCST_HR_INC ))

done

echo Done with MET
 
