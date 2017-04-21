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

# By cloning the repository
git clone https://github.com/NCAR/container-dtc-met
cd ./container-dtc-met/met
git checkout tags/met-6.0

# By pulling a released tar file
wget https://github.com/NCAR/container-dtc-met/archive/6.0.tar.gz
tar -xvzf 6.0.tar.gz
cd container-dtc-met-6.0/met

# Execute the docker build
docker build -t met-6.0-tutorial .

#
# Rather than writing the MET tutorial output in the docker environment, we will write it to your
# local machine.  Create a directory for the tutorial output and define it as an environment variable:
#
#   setenv MET_TUTORIAL_DIR /path/for/tutorial/output # c-shell syntax  
#   export MET_TUTORIAL_DIR=/path/for/tutorial/output # bash syntax  
#
# Once MET_TUTORIAL_DIR is set, run the following commands to set up the output directory structure.
#

# For Linux Users
mkdir -p ${MET_TUTORIAL_DIR}
curl -SL http://www.dtcenter.org/met/users/support/online_tutorial/tutorial_data/METv6.0_tutorial_data.tar.gz | \
  tar zxC ${MET_TUTORIAL_DIR} tutorial

# For Windows Users
# We recommend you place the tutorial directory in the container-dtc-met folder, which will likely be
# located in C:\Users\your-name\container-dtc-met\met-6.0 (where you are after executing docker build  
curl -SL http://www.dtcenter.org/met/users/support/online_tutorial/tutorial_data/METv6.0_tutorial_data.tar.gz | \
  tar zxC ./ tutorial

#
# Next, open up a shell in the docker environment and point to your tutorial output directory.
#

# For Linux Users
docker run -it -v ${MET_TUTORIAL_DIR}/tutorial:/met/met-6.0/tutorial met-6.0-tutorial /bin/bash
cd /met/met-6.0

# For Windows Users
docker run -it -v /c/Users/your-name/container-dtc-met/met-6.0/tutorial:/met/met-6.0/tutorial met-6.0-tutorial /bin/bash
cd /met/met-6.0

#
# Open a browser and navigate to the MET online tutorial:
#   http://www.dtcenter.org/met/users/support/online_tutorial/METv6.0/index.php
# 
# Users are encouraged to open two shells, one in the docker environment and one on their local machine
# in the $MET_TUTORIAL_OUT/tutorial directory.  The tutorial exercises generate ascii, NetCDF, and PostScript
# output files which may be viewed on your local machine.
#
# MET has already been compiled, the test scripts have been run, and the tutorial data has been downloaded.
# You may skip over all steps in the "Compilation" section.
#
# * NOTE * that in the docker environment...
#   - All tutorial commands should be run from the /met/met-6.0 directory.
#   - MET is installed in /usr/local/bin.
#     Therefore, the "bin/" prefix should be ommitted from all tutorial commands.
#     For example, run "grid_stat" instead of "bin/grid_stat".
#   - MET creates PostScript ouput image which may be difficult to view on your local machine.
#     The convert or ps2pdf may be used to convert PostScript images to PDF or other image file formats.
#       convert -background white in.ps out.png
#       ps2pdf -dPDFSETTINGS=/prepress in.ps [out.pdf] 
#

