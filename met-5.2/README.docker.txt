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
# Next, open up a shell in the docker environment. 
#

docker run -it my-met /bin/bash

