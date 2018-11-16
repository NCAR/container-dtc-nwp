#!/bin/ksh
  
#
# Simplified script to run WRF real in Docker world
#

# Constants
WRF_BUILD="/wrf"
INPUT_DIR="/case_data"
SCRIPT_DIR="/scripts/common"
CASE_DIR="/scripts/case"
WPSPRD_DIR="/wpsprd"
WRFPRD_DIR="/wrfprd"

# Check for the correct container
if [[ ! -e $WRF_BUILD ]]; then
  echo
  echo ERROR: real.exe can only be run with the dtc-nwp container.
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
rm namelist*

cp $CASE_DIR/namelist.wps .
cp $CASE_DIR/namelist.input .
sed -e '/nocolons/d' namelist.input > nml
cp namelist.input namelist.nocolons
mv nml namelist.input

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
