#!/bin/ksh
  
#
# Simplified script to run Python in Docker world
#

# Print start time
echo "Python plotting starting at: `date`"

# Constants
PYTHON_BIN="/usr/local/bin/python"
SCRIPT_DIR="/home/scripts/common"
CASE_DIR="/home/scripts/case"
POSTPRD_DIR="/home/postprd"
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

# Loop through the 2-digit forecast hours
typeset -Z2 fcst_time
fcst_time=$fhr_beg
while [ $fcst_time -le $fhr_end ]; do

  for domain in ${domain_list}; do

    # Get the filename to be plotted
    cur_file="${POSTPRD_DIR}/wrfprs_${domain}.${fcst_time}"

    # Skip files that do not exist
    if [[ ! -e ${cur_file} ]]; then
      continue
    fi

    # Run Python script(s)
    # To run individual plots, uncomment the line below and comment out the ALL* line.
    # This option is slower than plotting with the ALL_plot_allvars.py script,
    # but allows for more flexibility in choosing what variables to plot.
#    for pythonscript in `ls -1 $SCRIPT_DIR/python/plot_*.py`; do
    # The ALL_plot_allvars.py script plots all 10 plot types in one script,
    # reducing I/O and allowing for a shorter run time.
    for pythonscript in `ls -1 $SCRIPT_DIR/python/ALL_*.py`; do
      python $pythonscript $init_time $fcst_time $cur_file $CARTOPY_DIR $domain
    done
  done

  # Increment the forecast hour
  fcst_time=$(( $fcst_time + $fhr_inc ))

done


echo convert to animated gif

# Trim images
for file in `ls -1 *png`; do
  convert $file -trim $file
done

# Generate animated gifs
for domain in ${domain_list}; do
  convert -delay 100 10mwind_${domain}*.png 10mwind_${domain}.gif
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

# Print done time
echo "Python plotting done at: `date`"
