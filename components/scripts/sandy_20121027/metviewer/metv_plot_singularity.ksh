#!/bin/ksh -l

##########################################################################
#
# Script Name: metv_plot_singlualrity.ksh
#
#      Author: John Halley Gotway & Michelle Harrold
#              NCAR/RAL & DTC
#
#    Released: 06/07/2022
#
# Description: Script to format METviewer XML to be run with Singularity.
#
##########################################################################

if [ $# != 1 ]; then
  echo "ERROR: Must specify the case directory."
  exit 1
fi

caseDir=$1

METVDir=${caseDir}/metviewer

# Make the necessary output directories
mkdir -p ${METVDir}/plots
mkdir -p ${METVDir}/data
mkdir -p ${METVDir}/scripts
mkdir -p ${METVDir}/xml

# Update the load xml file
cat plot_APCP_03_ETS_singularity.xml | sed "s%METV_OUT_PATH%${METVDir}%g" \
    > ${METVDir}/xml/plot_APCP_03_ETS_singularity.xml

cat plot_WIND_Z10_singularity.xml | sed "s%METV_OUT_PATH%${METVDir}%g" \
    > ${METVDir}/xml/plot_WIND_Z10_singularity.xml

# Plot the data
/METviewer/bin/mv_batch.sh ${METVDir}/xml/plot_APCP_03_ETS_singularity.xml
/METviewer/bin/mv_batch.sh ${METVDir}/xml/plot_WIND_Z10_singularity.xml

