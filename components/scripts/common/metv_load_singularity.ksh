#!/bin/ksh -l

##########################################################################
#
# Script Name: metv_load_all.ksh
#
#      Author: John Halley Gotway
#              NCAR/RAL/DTC
#
#    Released: 11/03/2017
#
# Description:
#
##########################################################################

if [ $# != 1 ]; then
  echo "ERROR: Must specify the database name."
  exit 1
fi

dbname=$1
hostname=localhost

# Drop existing database
mysql -h${hostname} -uroot -pmvuser -e"drop database ${dbname};"

# Create the database
mysql -h${hostname} -uroot -pmvuser -e"create database ${dbname};"

# Apply the METViewer schema
mysql -h${hostname} -uroot -pmvuser ${dbname} < /METviewer/sql/mv_mysql.sql

# Update the load xml file
cat load_metv_mariadb_TMPL.xml | sed "s/DATABASE_NAME/${dbname}/g" \
  > load_${dbname}.xml

# Load the database
/METviewer/bin/mv_load.sh load_${dbname}.xml
