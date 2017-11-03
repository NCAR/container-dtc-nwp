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

if [ $# != 2 ]; then
  echo "ERROR: Must specify the database name and load XML file."
  exit 1
fi

dbname=$1
loadxml=$2
hostname=mysql_mv

# Drop existing database
mysql -h${hostname} -uroot -pmvuser -e"drop database ${dbname};"

# Create the database
mysql -h${hostname} -uroot -pmvuser -e"create database ${dbname};"

# Apply the METViewer schema
mysql -h${hostname} -uroot -pmvuser ${dbname} < /METViewer/sql/mv_mysql.sql

# Load the database
/METViewer/bin/mv_load.sh ${loadxml}
