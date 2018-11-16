#!/bin/ksh -x

#
# Simplified script to run MET in Docker world
#

# Include case-specific settings
. /scripts/case/set_env.ksh

# Variables need to match docker container volume names:
SCRIPT_DIR="/scripts/common"
METPRD_DIR="/metprd"
LOG_FILE="${METPRD_DIR}/run_met.log"

##################################
#   Run MET                      #
##################################

mkdir -p $METPRD_DIR
cd $METPRD_DIR

echo "Running MET and writing log file: ${LOG_FILE}" | tee $LOG_FILE

cp $SCRIPT_DIR/met_qpf_verf_all.ksh .
cp $SCRIPT_DIR/met_point_verf_all.ksh .

# Constants for all cases
export MET_EXE_ROOT=/usr/local/bin
export MET_CONFIG=/scripts/case/met_config

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
  export RAW_OBS=/case_data/sandy_20121027/obs_data/prepbufr
  ./met_point_verf_all.ksh | tee -a $LOG_FILE

  # Do qpf verification
  if [ $FCST_TIME -ge $ACCUM_TIME ]; then
    echo "ACCUM_TIME = $ACCUM_TIME" | tee -a $LOG_FILE
    echo "BUCKET_TIME = $BUCKET_TIME" | tee -a $LOG_FILE
    export ACCUM_TIME
    export BUCKET_TIME
    export RAW_OBS=/case_data/sandy_20121027/obs_data/qpe
    ./met_qpf_verf_all.ksh | tee -a $LOG_FILE
  fi

  # Increment the forecast hour
  FCST_TIME=$(( $FCST_TIME + $FCST_HR_INC ))

done

echo Done | tee -a $LOG_FILE
 
