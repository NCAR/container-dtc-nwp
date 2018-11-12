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
# These are manual steps to build your personal docker MySql and METviewer container images.
#
git clone https://github.com/NCAR/container-dtc-metviewer

# From container-dtc-metviewer/METviewer, build METviewer image.
cd container-dtc-metviewer/METviewer
docker build -t metviewer .

# Rather than writing the METviewer output and MySQL tables in the docker environment, we will write it to your
# local machine.  Create a directory for the output and define it as an environment variable:

setenv MYSQL_DIR /path/for/mysql/tables # c-shell syntax
export MYSQL_DIR=/path/for/mysql/tables # bash syntax

setenv METVIEWER_DIR /path/for/metviewer/output # c-shell syntax
export METVIEWER_DIR=/path/for/metviewer/output # bash syntax

# Set the data directory which contains MET or VSDB data.
setenv METVIEWER_DATA /path/for/data # c-shell syntax
export METVIEWER_DATA=/path/for/data # bash syntax

# From container-dtc-metviewer, start the containers:
  - #It  opens up a shell in the docker environment and point to METviewer home directory
    cd ..
    docker-compose run --rm --service-ports metviewer
  - #It  starts the containers in the background
      cd ..
      docker-compose up -d
      #To open a shell in the docker environment
      docker exec -it metviewer_1 /bin/bash

# You can access all METviewer modules in /METviewer/bin
# MET and/or VSDB output are in /data directory
# You can use METviewer web application using your URL http://localhost:8080/metviewer/metviewer1.jsp
# MySQL database can be accessed with this command : mysql -h mysql_mv -uroot -pmvuser

# To stop containers and removes containers, networks, volumes, and images
docker-compose down
