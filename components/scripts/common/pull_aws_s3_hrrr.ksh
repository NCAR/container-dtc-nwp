#!/bin/ksh

# HRRR AWS Info: https://registry.opendata.aws/noaa-hrrr-pds/

typeset -Z2 CUR_FHR

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
  echo "PULLING: HRRR data for the $INIT_YMDH initialization $CUR_FHR forecast hour."
  CUR_GRB_FILE=hrrr.t${INIT_H}z.wrfnatf${CUR_FHR}.grib2
  CUR_GRB_RENAME=hrrr.t${INIT_H}z.wrfnatf${CUR_FHR}.grb2

  # Pull the files
  echo "RUNNING: time wget https://noaa-hrrr-bdp-pds.s3.amazonaws.com/hrrr.${INIT_YMD}/conus/hrrr.t${INIT_H}z.wrfnatf${CUR_FHR}.grib2"
  time wget -q -i wget https://noaa-hrrr-bdp-pds.s3.amazonaws.com/hrrr.${INIT_YMD}/conus/hrrr.t${INIT_H}z.wrfnatf${CUR_FHR}.grib2

  mv ${CUR_GRB_FILE} ${CUR_GRB_RENAME}

  # Increment the forecast hour
  CUR_FHR=$(($CUR_FHR + $FHR_INC))

done
