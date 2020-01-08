#!/bin/ksh

# GFS AWS Info: https://registry.opendata.aws/noaa-gfs-pds
# README File:  https://docs.opendata.aws/noaa-gfs-pds/readme.html
# GFS AWS Data: http://awsopendata.s3-website-us-west-2.amazonaws.com/noaa-gfs

# This script attempts to wget all URL's from pull_aws_s3_gfs_tmpl.txt.
# However, not all files actually exist for each forecast hour.
# The list of URL's was generated with these commands:
#
#   rm pull_aws_s3_gfs_tmpl.txt
#   for VAR in `aws s3 ls s3://noaa-gfs-pds | sed -r 's/^ +PRE //g' | cut -d '/' -f1`; do
#     for LEV in `aws s3 ls s3://noaa-gfs-pds/$VAR/ | sed -r 's/^ +PRE //g' | sed -r 's/ /%20/g' | cut -d '/' -f1`; do
#       echo http://noaa-gfs-pds.s3.amazonaws.com/${VAR}/${LEV}/{INIT_YMD}/{INIT_H}00/{FHR}
#       echo http://noaa-gfs-pds.s3.amazonaws.com/${VAR}/${LEV}/{INIT_YMD}/{INIT_H}00/{FHR} >> pull_aws_s3_gfs_tmpl.txt
#     done
#  done

typeset -Z3 CUR_FHR

# Check arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 -> Must specify initialization time (YYYYMMDDHH) and maximum forecast hour."
  exit
fi

INIT_YMDH=$1
MAX_FHR=$2
FHR_INC=3

WGRIB2=/home/ec2-user/utilities/grib2/wgrib2/wgrib2

GFS_URL_TMPL=`dirname $0`/pull_aws_s3_gfs_tmpl.txt

# Loop over and pull all requested forecast lead hours
CUR_FHR=0
INIT_YM=`expr $INIT_YMDH | cut -c1-6`
INIT_YMD=`expr $INIT_YMDH | cut -c1-8`
INIT_H=`expr $INIT_YMDH | cut -c9-10`
while [[ $CUR_FHR -le $MAX_FHR ]]; do

  # Set temp files for the current time
  echo "PULLING: GFS data for the $INIT_YMDH initialization $CUR_FHR forecast hour."
  CUR_TMP_DIR=gfs_f${CUR_FHR}
  CUR_FILE_LIST=aws_s3_gfs_files_${INIT_YMDH}_f${CUR_FHR}.txt
  CUR_GRB_FILE=gfs_0p25_${INIT_YMD}_${INIT_H}00_${CUR_FHR}.grb2

  # Pull 0-hour forecast from NOMADS since s3 does not contain them
  if [[ $CUR_FHR -eq 0 ]]; then 

    echo "RUNNING: time wget -q https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${INIT_YMD}/${INIT_H}/gfs.t${INIT_H}z.pgrb2.0p25.f${CUR_FHR}"
    time wget -q https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${INIT_YMD}/${INIT_H}/gfs.t${INIT_H}z.pgrb2.0p25.f${CUR_FHR}

    # Rename this file
    mv gfs.t${INIT_H}z.pgrb2.0p25.f${CUR_FHR} $CUR_GRB_FILE

  else

    # Delete directory in case it already exists
    rm -rf $CUR_TMP_DIR
    mkdir $CUR_TMP_DIR

    # Customize the file list for the current times
    cat $GFS_URL_TMPL | sed "s/{INIT_YMD}/${INIT_YMD}/g" | \
       sed "s/{INIT_H}/${INIT_H}/g" | sed "s/{FHR}/${CUR_FHR}/g" > \
       $CUR_TMP_DIR/$CUR_FILE_LIST
    cd $CUR_TMP_DIR

    # Pull the files
    echo "RUNNING: time wget -q -i $CUR_FILE_LIST"
    time wget -q -i $CUR_FILE_LIST
    cd ..

    # Concatenate all the files for this time
    cat $CUR_TMP_DIR/${CUR_FHR}* > $CUR_GRB_FILE

    # Delete the temporary directory 
    rm -rf $CUR_TMP_DIR

  fi

  echo "WRITING: $CUR_GRB_FILE with `$WGRIB2 $CUR_GRB_FILE | wc -l` records."

  # Increment the forecast hour
  CUR_FHR=$(($CUR_FHR + $FHR_INC))

done
