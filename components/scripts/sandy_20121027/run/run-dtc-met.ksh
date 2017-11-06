#!/bin/ksh -x

#
# Simplified script to run MET for Sandy case in Docker world
#

# Variables need to match docker container volume names:
SCRIPT_DIR="/scripts/common"
METPRD_DIR="/metprd"
LOG_FILE="${METPRD_DIR}/run-dtc-met.log"

##################################
#   Run MET                      #
##################################

mkdir -p $METPRD_DIR
cd $METPRD_DIR

echo "Running MET and writing log file: ${LOG_FILE}" | tee $LOG_FILE

cp $SCRIPT_DIR/met_qpf_verf_all.ksh .
cp $SCRIPT_DIR/met_point_verf_all.ksh .

# Constants for the 2012102712 case
export START_TIME=2012102712
export DOMAIN_LIST=d01
export GRID_VX=FCST
export MET_EXE_ROOT=/usr/local/bin
export MET_CONFIG=/scripts/sandy_20121027/param/met_config
export UNIPOST_EXEC=/wrf/UPPV3.1/bin
export DATAROOT=/
export MODEL=ARW
export ACCUM_TIME=3
export BUCKET_TIME=1

# Forecast hours to evaluate
FCST_HR_BEG=0
FCST_HR_END=6
FCST_HR_INC=3

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
 
