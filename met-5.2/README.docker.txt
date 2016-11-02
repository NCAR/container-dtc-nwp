#
# Note:  Not intended to be run on super computers or clusters where docker engine may not be running.
# these are tutorial steps for learning on a personal workstation or laptop where Docker engine
# has been installed and running.
#
# These are manual steps to build your personal docker MET container images.
#

git clone https://github.com/NCAR/container-dtc-met
cd ./container-dtc-met/met-5.2
docker build -t my-met .

#
# Next, open up a shell in the docker environment and proceed through the online tutorial. 
#

docker run -it my-met /bin/bash
cd /met/met-5.2

#
# Use a browser to navigate to the MET online tutorial:
#   http://www.dtcenter.org/met/users/support/online_tutorial/METv5.2/index.php
#
# MET has already been compiled, the test scripts have been run, and the tutorial data has been downloaded.
# You may skip over all steps in the "Compilation" section.
#
# *NOTE* that all tutorial commands should be run from the /met/met-5.2 directory.
# *NOTE* that MET is installed in /usr/local/bin.  Therefore, omit the "bin/" prefix from all of the tutorial commands.
#   For example, rather than "bin/grid_stat" simply run "grid_stat".
#

