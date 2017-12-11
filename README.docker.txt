#
# Note:  Not intended to be run on super computers or clusters where docker engine may not be running.
# these are tutorial steps for learning on a personal workstation or laptop where Docker engine
# has been installed and running.
#
# You can obtain Docker (current Mac and Windows 10 users) at:
#   https://www.docker.com/products/overview
#
# Or Docker Tools (for older Mac and Windows users) at:
#   https://www.docker.com/products/docker-toolbox
#
# These are manual steps to build your personal docker MET container image.
#

git clone https://github.com/NCAR/container-dtc-met
cd container-dtc-met/MET
docker build -t met-6.1 .

#
# Rather than writing the MET tutorial data in the docker environment, we will write it to your
# local machine.  Create a directory for the tutorial data and define it as an environment variable:
#
#   setenv MET_TUTORIAL_DIR /path/for/tutorial/data # c-shell syntax  
#   export MET_TUTORIAL_DIR=/path/for/tutorial/data # bash syntax  
#
# Once MET_TUTORIAL_DIR is set, run the following commands to retrieve the data.
#

mkdir -p ${MET_TUTORIAL_DIR}
curl -SL http://www.dtcenter.org/met/users/support/online_tutorial/tutorial_data/METv6.1_tutorial_data.tar.gz | \
  tar zxC ${MET_TUTORIAL_DIR}

#
# Next, open up a shell in the docker environment and point to your tutorial output directory.
#

docker run -it --rm \
 -v ${MET_TUTORIAL_DIR}/MET_Tutorial:/met/met-6.1/MET_Tutorial \
 --name met-6.1-tutorial met-6.1 /bin/bash
cd /met/met-6.1

#
# Open a browser and navigate to the MET online tutorial:
#   http://www.dtcenter.org/met/users/support/online_tutorial/METv6.1/index.php
# 
# Users are encouraged to open two shells, one in the docker environment and one on their local machine
# in the $MET_TUTORIAL_DIR/tutorial directory.  The tutorial exercises generate ascii, NetCDF, and PostScript
# output files which may be viewed on your local machine.
#
# MET has already been compiled, the test scripts have been run, and the tutorial data has been downloaded.
# You may skip over all steps in the "Compilation" section.
#
# * NOTE * that in the docker environment...
#   - All tutorial commands should be run from the /met/met-6.1 directory.
#   - MET is installed in /usr/local/bin.
#   - MET creates PostScript ouput image which may be difficult to view on your local machine.
#     The convert or ps2pdf may be used to convert PostScript images to PDF or other image file formats.
#       convert -background white in.ps out.png
#       ps2pdf -dPDFSETTINGS=/prepress in.ps [out.pdf] 
#
