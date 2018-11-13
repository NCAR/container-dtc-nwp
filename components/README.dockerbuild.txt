#
# Note:  Not intended to be run on super computers or clusters where docker engine may not be running.
# these are tutorial steps for learning on a personal workstation or laptop where Docker engine
# has been installed and running.
#
# These are manual steps to build your personal docker wrf container images.
#
# The following explains how to run an end-to-end NWP test case, running WPS, WRF, UPP, NCL, and MET.
#
# The steps below are NOT necessary to run the docker demo, but instead for learning how to build docker images.
#  using "Dockerfile" and commands such as "docker build -t <>"
#

setenv PROJ_DIR "/path/to/working/directory"  -or-  export PROJ_DIR="/path/to/working/directory"

git clone https://github.com/NCAR/container-dtc-nwp ${PROJ_DIR}/container-dtc-nwp
cd ${PROJ_DIR}/container-dtc-nwp/components

# Build image for WPSGEOG static data
cd wps_geog ; docker build -t dtc-nwp-wps_geog . ; cd ..

# Build image for input Sandy test case data
cd case_data/sandy_20121027 ; docker build -t dtc-nwp-sandy . ; cd ../..

# Build image for input Derecho test case data
cd case_data/derecho_20120629 ; docker build -t dtc-nwp-derecho . ; cd ../..

# Build image for input snow test case data
cd case_data/snow_20160123 ; docker build -t dtc-nwp-snow . ; cd ../..

# Build image which compiles WPS, WRF, and UPP from source
cd wps_wrf_upp ; docker build -t dtc-nwp . ; cd ..

# Build image for NCL
cd ncl ; docker build -t dtc-ncl . ; cd ..

# Build image which compiles MET from source
cd met/MET ; docker build -t dtc-met . ; cd ../..

# Build images for METViewer
cd metviewer/METViewer ; docker build -t dtc-metviewer . ; cd ../..

#
# The steps below are ONLY if you successfully completed all steps above cleanly.
# Instantiate local docker containers from the images you created above:
#

docker create -v /WPS_GEOG --name wps_geog dtc-nwp-wps_geog
docker create -v /case_data/sandy_20121027 --name sandy dtc-nwp-sandy
docker create -v /case_data/derecho_20120629 --name derecho dtc-nwp-derecho

#
# A more automated method using pre-built DTC docker-nwp/met container images,
# edit the docker-compose-dtc.yml file to reflect wrfoutput directory, number of cores, etc
# again, see the file README.dockerrun.txt
#
