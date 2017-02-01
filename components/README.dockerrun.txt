#
# Run WPS/WRF/UPP (NWP: pre-proc, model, post-proc) script in docker-space.
#
docker run -it --volumes-from wps_geog --volumes-from sandy \
 -v ~/wrfprd:/wrfprd -v ~/postprd:/postprd \
 --name run-dtc-nwp-sandy dtc-nwp /case_data/sandy_20121027/scripts/run-dtc-nwp

#
# Run MET script in docker-space.
#
docker run -it --volumes-from wps_geog --volumes-from sandy \
 -v ~/postprd:/postprd -v ~/metprd:/metprd \
 --name run-dtc-met-sandy dtc-met /case_data/sandy_20121027/scripts/run-dtc-met
 
