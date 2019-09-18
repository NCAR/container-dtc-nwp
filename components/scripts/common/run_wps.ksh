#!/bin/ksh
set -x
#
# Simplified script to run WPS in Docker world
#

# Constants
WRF_BUILD="/comsoftware/wrf"
INPUT_DIR="/data/"
SCRIPT_DIR="/home/scripts/common"
CASE_DIR="/home/scripts/case"
WPSPRD_DIR="/home/wpsprd"

# Check for the correct container
if [[ ! -e $WRF_BUILD ]]; then
  echo
  echo ERROR: WPS can only be run with the dtc-wps_wrf container.
  echo
  exit 1
fi

# Check for input directory
if [[ ! -e $CASE_DIR ]]; then
  echo
  echo ERROR: The $CASE_DIR directory is not mounted.
  echo
  exit 1
fi

# Check for output directory
if [[ ! -e $WPSPRD_DIR ]]; then
  echo
  echo ERROR: The $WPSPRD_DIR directory is not mounted.
  echo
  exit 1
fi
cd $WPSPRD_DIR

# Include case-specific settings
. $CASE_DIR/set_env.ksh

##################################
#     Run the WPS programs       #
##################################

echo Running WPS

ln -sf $WRF_BUILD/WPS-${WPS_VERSION}/*.exe .

# Get namelist and correct Vtable based on data
# The Vtable is dependent on the data that is used
# Will need to pull this in dynamically somehow, tie to data/namelist

if [[ ! -e namelist.wps ]]; then
  cp -f $CASE_DIR/namelist.wps .
fi

cp -f $CASE_DIR/Vtable.GFS Vtable

# Link input data
$WRF_BUILD/WPS-${WPS_VERSION}/link_grib.csh $INPUT_DIR/model_data/gfs/*_*

##################################
#     Run the geogrid program    #
##################################

echo Starting geogrid

# Remove old files
if [ -e geo_em.d*.nc ]; then
  rm -rf geo_em.d*.nc
fi

# Command for geogrid
./geogrid.exe > run_geogrid.log 2>&1

# Check success
ls -ls geo_em.d01.nc
OK_geogrid=$?

if [ $OK_geogrid -eq 0 ]; then
  tail run_geogrid.log
  echo
  echo OK geogrid ran fine at `date`
  echo Completed geogrid, Starting ungrib
  echo
else
  echo
  echo ERROR: geogrid.exe did not complete
  echo
  cat geogrid.log
  echo
  exit 11 
fi

##################################
#    Run the ungrib program      #
##################################

echo Starting ungrib

# Remove old files
file_date=`cat namelist.wps | grep -i start_date | cut -d"'" -f2 | cut -d":" -f1`
if [ -e PFILE:${file_date} ]; then
  rm -rf PFILE*
fi
if [ -e FILE:${file_date} ]; then
  rm -rf FILE*
fi

# Command for ungrib
./ungrib.exe > run_ungrib.log 2>&1

ls -ls FILE:*
OK_ungrib=$?

if [ $OK_ungrib -eq 0 ]; then
  tail run_ungrib.log
  echo
  echo OK ungrib ran fine at `date`
  echo Completed ungrib, Starting metgrid
  echo
else
  echo
  echo ERROR: ungrib.exe did not complete
  echo
  cat ungrib.log
  echo
  exit 22 
fi

##################################
#     Run the metgrid program    #
##################################

echo Starting metgrid 

# Remove old files
if [ -e met_em.d*.${file_date}:00:00.nc ]; then
  rm -rf met_em.d*
fi

# Command for metgrid
./metgrid.exe > run_metgrid.log 2>&1

# Check sucess
ls -ls met_em.d01.*
OK_metgrid=$?

if [ $OK_metgrid -eq 0 ]; then
  tail run_metgrid.log
  echo
  echo OK metgrid ran fine at `date`
  echo Completed metgrid
  echo
else
  echo
  echo ERROR: metgrid.exe did not complete
  echo
  cat metgrid.log
  echo
  exit 33 
fi

echo Done with WPS
