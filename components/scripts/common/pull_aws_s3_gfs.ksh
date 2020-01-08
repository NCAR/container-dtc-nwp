#!/bin/ksh

# GFS AWS Info: https://registry.opendata.aws/noaa-gfs-pds
# README File:  https://docs.opendata.aws/noaa-gfs-pds/readme.html
# GFS AWS Data: http://awsopendata.s3-website-us-west-2.amazonaws.com/noaa-gfs

typeset -Z3 CUR_FHR

# Check arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 -> Must specify initialization time (YYYYMMDDHH) and maximum forecast hour."
  exit
fi

INIT_YMDH=$1
MAX_FHR=$2
FHR_INC=3

GFS_URL_TMPL=`dirname $0`/pull_aws_s3_gfs_tmpl.txt

# Loop over and pull all requested forecast lead hours
CUR_FHR=0
INIT_YM=`expr $INIT_YMDH | cut -c1-6`
INIT_YMD=`expr $INIT_YMDH | cut -c1-8`
INIT_H=`expr $INIT_YMDH | cut -c9-10`
while [[ $CUR_FHR -le $MAX_FHR ]]; do
  echo "PULLING: GFS data for the $INIT_YMDH initialization $CUR_FHR forecast hour."
  CUR_TMP_DIR=gfs_f${CUR_FHR}
  CUR_FILE_LIST=aws_s3_gfs_files_${INIT_YMDH}_f${CUR_FHR}.txt

  # Delete directory in case it already exists
  rm -rf $CUR_TMP_DIR
  mkdir $CUR_TMP_DIR

  # Customize the file list for the current times
  cat $GFS_URL_TMPL | sed "s/{INIT_YMD}/${INIT_YMD}/g" | \
     sed "s/{INIT_H}/${INIT_H}/g" | sed "s/{FHR}/${CUR_FHR}/g" > \
     $CUR_TMP_DIR/$CUR_FILE_LIST
  cd $CUR_TMP_DIR

  # Pull the files
  wget -i $CUR_FILE_LIST
  cd ..

  # Concatenate all the files for this time
  cat $CUR_TMP_DIR/${CUR_FHR}* > gfs_4_${INIT_YMD}_${INIT_H}00_${CUR_FHR}.grb2

  CUR_FHR=$(($CUR_FHR + $FHR_INC))
done
