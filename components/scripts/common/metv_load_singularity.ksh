#!/bin/ksh -l

##########################################################################
#
# Script Name: metv_load_singlualrity.ksh
#
#      Author: John Halley Gotway & Michelle Harrold
#              NCAR/RAL & DTC
#
#    Released: 06/07/2022
#
# Description: Script to format METviewer XML to be run with Singularity.
#
##########################################################################

if [ $# != 2 ]; then
  echo "ERROR: Must specify the database name and case directory."
  exit 1
fi

dbName=$1
caseDir=$2
hostname=localhost

# Drop existing database
mysql -h${hostname} -uroot -pmvuser -e"drop database ${dbName};"

# Create the database
mysql -h${hostname} -uroot -pmvuser -e"create database ${dbName};"

# Apply the METViewer schema
mysql -h${hostname} -uroot -pmvuser ${dbName} < /METviewer/sql/mv_mysql.sql

# Update the load xml file
cat load_metv_mariadb_TMPL.xml | sed "s%DATABASE_NAME%${dbName}%g;s%CASE_DIR%${caseDir}%g" \
    > ${caseDir}/metviewer/load_${dbName}.xml

# Load the database
/METviewer/bin/mv_load.sh ${caseDir}/metviewer/load_${dbName}.xml
