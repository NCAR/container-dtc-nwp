#
# Run WPS/WRF/UPP (NWP: pre-proc, model, post-proc) script in docker-space.
#
docker run -it --volumes-from wps_geog --volumes-from derecho \
 -v ~/wrfprd:/wrfprd -v ~/postprd:/postprd \
 --name run-dtc-nwp-derecho dtc-nwp /case_data/derecho_20120629/run/run-dtc-nwp

# Run NCL to generate plots from WRF output
docker run --rm  -it -v ~/wrfprd:/wrfprd dtc-ncl

#
# Run MET script in docker-space.
#
docker run -it --volumes-from scripts --volumes-from derecho \
 -v ~/postprd:/postprd -v ~/metprd:/metprd \
 --name run-dtc-met-derecho dtc-met /case_data/derecho_20120629/run/run-dtc-met
 
#
# Run METViewer in docker-space.
#
# Rather than writing the METViewer output and MySQL tables in the docker environment, we will write it to your
# local machine.  Create a directory for the output and define it as an environment variable:

setenv MYSQL_DIR /path/for/mysql/tables # c-shell syntax
export MYSQL_DIR=/path/for/mysql/tables # bash syntax

setenv METVIEWER_DIR /path/for/metviewer/output # c-shell syntax
export METVIEWER_DIR=/path/for/metviewer/output # bash syntax

# Set the data directory which contains MET or VSDB data.
setenv METVIEWER_DATA /path/for/data # c-shell syntax
export METVIEWER_DATA=/path/for/data # bash syntax

# From container-dtc-metviewer, start the containers.
# It also opens up a shell in the docker environment and point to METViewer home directory
cd ..
docker-compose run --rm --service-ports metviewer

# You can access all METViewer modules in /METViewer/bin
# MET and/or VSDB output are in /data directory
# You can use METViewer web application using your URL http://localhost:8080/metviewer/metviewer1.jsp
# MySQL database can be accessed with this command : mysql -h mysql_mv -uroot -pmvuser
