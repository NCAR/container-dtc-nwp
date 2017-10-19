#
# Run WPS/WRF/UPP (NWP: pre-proc, model, post-proc) script in docker-space.
#
docker run -it --volumes-from wps_geog --volumes-from derecho \
 -v ~/wrfprd:/wrfprd -v ~/postprd:/postprd \
 --name run-dtc-nwp-derecho dtc-nwp /case_data/derecho_20120629/run/run-dtc-nwp

# Run NCL to generate plots from WRF output
docker run --rm  -it -v ~/wrfprd:/wrfprd dtc-ncl

#
# Run MET script in docker-space.
#
docker run -it --volumes-from scripts --volumes-from derecho \
 -v ~/postprd:/postprd -v ~/metprd:/metprd \
 --name run-dtc-met-derecho dtc-met /case_data/derecho_20120629/run/run-dtc-met
 
