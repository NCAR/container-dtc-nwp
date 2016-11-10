#
# Note:  Not intended to be run on super computers or clusters where docker engine may not be running.
# these are tutorial steps for learning on a personal workstation or laptop where Docker engine
# has been installed and running.
#
# These are manual steps to build your personal docker MET container image.
#

git clone https://github.com/NCAR/container-dtc-met
cd ./container-dtc-met/met-5.2
docker build -t met-5.2-tutorial .

#
# Rather than writing the MET tutorial output in the docker environment, we will write it to your
# local machine.  Create a directory for the tutorial output and define it as an environment variable:
#
#   setenv MET_TUTORIAL_DIR /path/for/tutorial/output # c-shell syntax  
#   export MET_TUTORIAL_DIR=/path/for/tutorial/output # bash syntax  
#
# Once MET_TUTORIAL_DIR is set, run the following commands to set up the output directory structure.
#

mkdir -p ${MET_TUTORIAL_DIR}
curl -SL http://www.dtcenter.org/met/users/support/online_tutorial/tutorial_data/METv5.2_tutorial_data.tar.gz | \
  tar zxC ${MET_TUTORIAL_DIR} tutorial
 
#
# Next, open up a shell in the docker environment and point to your tutorial output directory.
#

docker run -it -v ${MET_TUTORIAL_DIR}/tutorial:/met/met-5.2/tutorial met-5.2-tutorial /bin/bash
cd /met/met-5.2

#
# Open a browser and navigate to the MET online tutorial:
#   http://www.dtcenter.org/met/users/support/online_tutorial/METv5.2/index.php
# 
# Users are encouraged to open two shells, one in the docker environment and one on their local machine
# in the $MET_TUTORIAL_OUT/tutorial directory.  The tutorial exercises generate ascii, NetCDF, and PostScript
# output files which may be viewed on your local machine.
#
# MET has already been compiled, the test scripts have been run, and the tutorial data has been downloaded.
# You may skip over all steps in the "Compilation" section.
#
# * NOTE * that in the docker environment...
#   - All tutorial commands should be run from the /met/met-5.2 directory.
#   - MET is installed in /usr/local/bin.
#     Therefore, the "bin/" prefix should be ommitted from all tutorial commands.
#     For example, run "grid_stat" instead of "bin/grid_stat".
#

