#!/bin/ksh
  
#
# Simplified script to run Python in Docker world
#

# Constants
PYTHON_BIN="/usr/local/bin/python"
SCRIPT_DIR="/home/scripts/common"
CASE_DIR="/home/scripts/case"
POSTPRD_DIR="/home/postprd"
PYTHONPRD_DIR="/home/pythonprd"
CARTOPY_DIR="$SCRIPT_DIR/python/shapefiles"

# Check for the correct container
if [[ ! -e $PYTHON_BIN ]]; then
  echo
  echo ERROR: Python can only be run with the DTC Python container.
  echo
  exit 1
fi

# Check for input directory
if [[ ! -e $POSTPRD_DIR ]]; then
  echo
  echo ERROR: The $POSTPRD_DIR directory is not mounted.
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

# Include case-specific settings
. $CASE_DIR/set_env.ksh

# Loop through the forecast hours
fcst_time=$fhr_beg
while [ $fcst_time -le $fhr_end ] ; do

  for domain in ${domain_list}
  do

    # Run all Python scripts found
    for pythonscript in `ls -1 $SCRIPT_DIR/python/plot_*.py`; do
      python $pythonscript $init_time $fcst_time $POSTPRD_DIR $CARTOPY_DIR $domain
    done
  done

  # Increment the forecast hour
  fcst_time=$(( $fcst_time + $fhr_inc ))

done


echo convert to animated gif

# Trim images
#for file in `ls -1 *png`
#do
#  convert $file -trim $file
#done

# Generate animated gifs
#for domain in ${domain_list}
#do
#  convert -delay 100 plt_Surface_multi_${domain}*.png Surface_multi_${domain}.gif
#  convert -delay 100 plt_Precip_multi_total_${domain}*.png Precip_total_${domain}.gif
#  convert -delay 100 plt_dbz1*${domain}*.png DBZ1_${domain}.gif
#done   

#ls -alh *gif

echo Done with Python plotting
