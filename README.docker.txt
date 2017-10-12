#
# Note:  Not intended to be run on super computers or clusters where docker engine may not be running.
# These are tutorial steps for learning on a personal workstation or laptop where Docker engine has
# been installed and running.
#
# You can obtain Docker (current Mac and Windows 10 users) at:
#   https://www.docker.com/products/overview
#
# Or Docker Tools (for older Mac and Windows users) at:
#   https://www.docker.com/products/docker-toolbox
#
# These are manual steps to build your personal docker MySql and METViewer container images.
#
git clone https://github.com/NCAR/container-dtc-metviewer

# From container-dtc-metviewer/MySQL, build MySQL image.
cd container-dtc-metviewer/MySQL
docker build -t mysql_mv .

# From container-dtc-metviewer/METViewer, build METViewer image.
cd ../METViewer
docker build -t metviewer .

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
# You can use METViewer web application using your URL http://localhost:8080
# MySQL database can be accessed with this command : mysql -h mysql_mv -uroot -pmvuser
