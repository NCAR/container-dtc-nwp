#!/bin/ksh
set -x  
#
# Simplified script to run WRF real in Docker world
#

# Constants
WRF_BUILD="/comsoftware/wrf"
INPUT_DIR="/data"
SCRIPT_DIR="/home/scripts/common"
CASE_DIR="/home/scripts/case"
WPSPRD_DIR="/home/wpsprd"
WRFPRD_DIR="/home/wrfprd"

# Check for the correct container
if [[ ! -e $WRF_BUILD ]]; then
  echo
  echo ERROR: real.exe can only be run with the dtc-wps_wrf container.
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

# Check for input directory
if [[ ! -e $WPSPRD_DIR ]]; then
  echo
  echo ERROR: The $WPSPRD_DIR directory is not mounted.
  echo
  exit 1
fi

# Check for output directory
if [[ ! -e $WRFPRD_DIR ]]; then
  echo
  echo ERROR: The $WRFPRD_DIR directory is not mounted.
  echo
  exit 1
fi
cd $WRFPRD_DIR

# Include case-specific settings
. $CASE_DIR/set_env.ksh

##################################
#     Run the WRF real program   #
##################################

ln -sf $WRF_BUILD/WRF-${WRF_VERSION}/run/* .

if [[ ! -e namelist.wps ]]; then
  cp $CASE_DIR/namelist.wps .
fi
#If namelist is a symlink, remove it, we don't want it
if [[ -L namelist.input ]]; then
  rm namelist.input
fi
if [[ ! -e namelist.input ]]; then
  cp $CASE_DIR/namelist.input .
  sed -e '/nocolons/d' namelist.input > nml
  cp namelist.input namelist.nocolons
  mv nml namelist.input
fi

echo Running real.exe

# Link data from WPS
ln -sf $WPSPRD_DIR/met_em.d0* .

# Remove old files
if [ -e wrfinput_d* ]; then
  rm -rf wrfi* wrfb*
fi

# Command for real
./real.exe > run_real.log 2>&1

# Check success
ls -ls wrfinput_d01
OK_wrfinput=$?

ls -ls wrfbdy_d01
OK_wrfbdy=$?

if [ $OK_wrfinput -eq 0 ] && [ $OK_wrfbdy -eq 0 ]; then
  tail run_real.log
  echo
  echo OK real ran fine at `date`
  echo
else
  cat run_real.log
  echo
  echo ERROR: real.exe did not complete
  echo
  exit 44 
fi

echo Done with real.exe
