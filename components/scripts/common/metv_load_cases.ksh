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
# Description: This script provides functionality for creating and loading
#              METviewer database(s) from multiple sets of MET output.
#              This script should be used with the docker-compose-cases.yml.
#
##########################################################################

# Argument list:
# 1) database name
# 2) path in Docker space for top-level MET output directory
#    This option is used when loading MET output from multiple cases.
# 3) flag whether to drop, create, and apply schema to new
#    database or load data into an existing database. This option is used
#    when loading MET output from multiple cases. If set to YES, the 
#    MET output will be loaded into a new database. If set to NO, the 
#    MET output will be loaded into a pre-existing database specified in
#    command argument 1.

if [ $# != 3 ]; then
  echo "ERROR: Must specify the database name, path in Docker space for top-level MET output directory, \
        and whether data will be loaded into a new or pre-existing database."
  exit 1
fi

dbname=$1
datadir=`basename $2`
mvflag=$3

hostname=mysql_mv

if [[ ${mvflag} == "YES"  ]]; then
  # Drop existing database
  mysql -h${hostname} -uroot -pmvuser -e"drop database ${dbname};"

  # Create the database
  mysql -h${hostname} -uroot -pmvuser -e"create database ${dbname};"

  # Apply the METViewer schema
  mysql -h${hostname} -uroot -pmvuser ${dbname} < /METviewer/sql/mv_mysql.sql
fi

# Update the load xml file
cat /scripts/common/load_metv_TMPL.xml | sed "s/DATABASE_NAME/${dbname}/g" | \
  sed "s/\/data\/{met_tool}/\/data\/${datadir}\/{met_tool}/g" \
  > /data/load_${dbname}.xml

# Load the database
/METviewer/bin/mv_load.sh /data/load_${dbname}.xml

