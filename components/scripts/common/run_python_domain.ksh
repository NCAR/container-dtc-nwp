#!/bin/ksh
  
#
# Simplified script to run Python to create plot of WPS/WRF domain in Docker world
#

# Constants
PYTHON_BIN="/usr/local/bin/python"
SCRIPT_DIR="/home/scripts/common"
CASE_DIR="/home/scripts/case"
PYTHONPRD_DIR="/home/pythonprd"
DATA_DIR="/home/data"
CARTOPY_DIR="$DATA_DIR"
mkdir -p $CARTOPY_DIR

# Check for the correct container
if [[ ! -e $PYTHON_BIN ]]; then
  echo
  echo ERROR: Python can only be run with the DTC Python container.
  echo
  exit 1
fi

# Check for output directory
if [[ ! -e $PYTHONPRD_DIR ]]; then
  echo
  echo ERROR: The $PYTHONPRD_DIR directory is not mounted.
  echo
  exit 1
fi

# Check for shapefiles needed by cartopy 
if [[ ! -e $CARTOPY_DIR ]]; then
  echo
  echo ERROR: The $CARTOPY_DIR directory is not mounted.
  echo
  exit 1
fi

cd $PYTHONPRD_DIR

# Run Python script
python $SCRIPT_DIR/python/plot_WRF_domain.py
