#
# Note:  Not intended to be run on super computers or clusters where docker engine may not be running.
# these are tutorial steps for learning on a personal workstation or laptop where Docker engine
# has been installed and running.
#
# These are manual steps to build your personal docker wrf container images.
#
# to simply run a WPS, WRF, UPP demo:
# using pre-built NCAR docker-wrf container images, see the docker-compose-wps-wrf-upp.yml file
# and the file README.dockerrun.wps-wrf-upp.txt
#
# The steps below are NOT necessary to run the docker demo, but instead for learning how to build docker images.
#  using "Dockerfile" and commands such as "docker build -t <>"
#
git clone  https://github.com/NCAR/container-wrf
cd ./container-wrf/3.7.1/datasets
cd wpsgeog ; docker build -t my-wpsgeog .
cd ../wrfinputsandy ; docker build -t my-wrfinputsandy .
#cd ../mmet-20120629 ; docker build -t my-mmet-20120629 .
#cd ../../ncl-mmet ; docker build -t my-ncl-mmet .
#
# now compile wrf from source
cd ../ncar-wrf ; docker build -t my-wps-wrf-upp .
#
#
# The steps below are ONLY if you successfully completed all steps above cleanly.
# Manual steps to instantiate local docker containers from your personal docker wrf images follow:
#
docker create -v /WPS_GEOG --name wpsgeog my-wpsgeog
docker create -v /wrfinput --name wrfinputsandy my-wrfinputsandy
#docker create -v /wrfinput --name mmet-20120629 my-mmet-20120629
#
docker run -it --volumes-from wpsgeog --volumes-from wrfinputsandy -v ~/wrfoutput:/wrfoutput \
 --name mywrfsandy my-wps-wrf-upp /wrf/run-wps-wrf-upp
#docker run -it --volumes-from wpsgeog --volumes-from mmet-20120629 -v ~/wrfoutput:/wrfoutput \
# --name my-mmet-20120629 my-wrf /wrf/run-wrf
#
# below a Windows directory mapping example:
# docker run -it --volumes-from wpsgeog --volumes-from mmet-20120629 -v c:/Users/myid/wrfoutput:/wrfoutput \
#   --name my-mmet-20120629 my-wrf /wrf/run-wrf
#
# Now plot the .nc files
#docker run -it --rm=true -v ~/wrfoutput:/wrfoutput --name nclplot my-ncl
#
# Windows:
# docker run -it --rm=true -v c:/Users/myid/wrfoutput:/wrfoutput --name nclplot my-ncl
#
# A more automated method using pre-built NCAR docker-wrf container images,
# edit the docker-compose-mmet.yml file to reflect wrfoutput directory, number of cores, etc
# again, see the file README.dockerrun.mmet.txt
#
