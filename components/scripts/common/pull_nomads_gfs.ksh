#!/bin/ksh
  
typeset -Z3 CUR_FHR

# Check arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 -> Must specify initialization time (YYYYMMDDHH) and maximum forecast hour."
  exit
fi

INIT_YMDH=$1
MAX_FHR=$2
FHR_INC=3

# Loop over and pull all requested forecast lead hours
CUR_FHR=0
INIT_YM=`expr $INIT_YMDH | cut -c1-6`
INIT_YMD=`expr $INIT_YMDH | cut -c1-8`
INIT_H=`expr $INIT_YMDH | cut -c9-10`
while [[ $CUR_FHR -le $MAX_FHR ]]; do
  echo "PULLING: curl -LO https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${INIT_YMD}/${INIT_H}/atmos/gfs.t${INIT_H}z.pgrb2.0p25.f${CUR_FHR}"
  curl -LO https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${INIT_YMD}/${INIT_H}/atmos/gfs.t${INIT_H}z.pgrb2.0p25.f${CUR_FHR}
  CUR_FHR=$(($CUR_FHR + $FHR_INC))
done
