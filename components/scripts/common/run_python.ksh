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
for file in `ls -1 *png`
do
  convert $file -trim $file
done

# Generate animated gifs
for domain in ${domain_list}
do
  convert -delay 100 10mwin_${domain}*.png 10mwin_${domain}.gif
  convert -delay 100 250wind_${domain}*.png 250wind_${domain}.gif
  convert -delay 100 2mdew_${domain}*.png 2mdew_${domain}.gif
  convert -delay 100 2mt_${domain}*.png 2mt_${domain}.gif
  convert -delay 100 500_${domain}*.png 500_${domain}.gif
  convert -delay 100 maxuh25_${domain}*.png maxuh25_${domain}.gif
  convert -delay 100 qpf_${domain}*.png qpf_${domain}.gif
  convert -delay 100 refc_${domain}*.png refc_${domain}.gif
  convert -delay 100 sfcape_${domain}*.png sfcape_${domain}.gif
  convert -delay 100 slp_${domain}*.png slp_${domain}.gif
done   

ls -alh *gif

echo Done with Python plotting
