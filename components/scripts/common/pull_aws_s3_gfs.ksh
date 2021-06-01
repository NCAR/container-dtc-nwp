#!/bin/ksh

# GFS AWS Info: https://registry.opendata.aws/noaa-gfs-bdp-pds/

typeset -Z3 CUR_FHR

# Check arguments
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 -> Must specify initialization time (YYYYMMDDHH), maximum forecast hour, and forecast hour increment."
  exit
fi

INIT_YMDH=$1
MAX_FHR=$2
FHR_INC=$3

# Loop over and pull all requested forecast lead hours
CUR_FHR=0
INIT_YMD=`expr $INIT_YMDH | cut -c1-8`
INIT_H=`expr $INIT_YMDH | cut -c9-10`
while [[ $CUR_FHR -le $MAX_FHR ]]; do

  # Set temp files for the current time
  echo "PULLING: GFS data for the $INIT_YMDH initialization $CUR_FHR forecast hour."
  CUR_GRB_FILE=gfs.t${INIT_H}z.pgrb2.0p25.f${CUR_FHR}
  CUR_GRB_RENAME=${INIT_YMD}_i${INIT_H}_f${CUR_FHR}_gfs0p25.grb2

  # Pull the files
  echo "RUNNING: time wget https://noaa-gfs-bdp-pds.s3.amazonaws.com/gfs.${INIT_YMD}/${INIT_H}/atmos/${CUR_GRB_FILE}"
  time wget https://noaa-gfs-bdp-pds.s3.amazonaws.com/gfs.${INIT_YMD}/${INIT_H}/atmos/${CUR_GRB_FILE}

  mv ${CUR_GRB_FILE} ${CUR_GRB_RENAME}

  # Increment the forecast hour
  CUR_FHR=$(($CUR_FHR + $FHR_INC))

done
