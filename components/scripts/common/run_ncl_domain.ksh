#!/bin/ksh
  
#
# Simplified script to run NCL in Docker world
#

# Constants
NCL_BIN="/usr/local/bin/ncl"
SCRIPT_DIR="/home/scripts/common"
CASE_DIR="/home/scripts/case"
WRFPRD_DIR="/home/wrfprd"
NCLPRD_DIR="/home/nclprd"

# Check for the correct container
if [[ ! -e $NCL_BIN ]]; then
  echo
  echo ERROR: NCL can only be run with the dtc-ncl container.
  echo
  exit 1
fi

# Check for input directory
if [[ ! -e $WRFPRD_DIR ]]; then
  echo
  echo ERROR: The $WRFPRD_DIR directory is not mounted.
  echo
  exit 1
fi

# Check for output directory
if [[ ! -e $NCLPRD_DIR ]]; then
  echo
  echo ERROR: The $NCLPRD_DIR directory is not mounted.
  echo
  exit 1
fi
cd $NCLPRD_DIR

# Include case-specific settings
. $CASE_DIR/set_env.ksh

export NCARG_ROOT=/usr/local

# Run all NCL scripts found
for nclscript in `ls -1 $SCRIPT_DIR/ncl/domains_png.ncl`
do
  ncl $nclscript
done

# Trim images
for file in `ls -1 *png`
do
  convert $file -trim $file
done

echo Done with NCL
