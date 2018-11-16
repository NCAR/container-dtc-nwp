#!/bin/ksh

# UPP settings

# Set input format from model
export inFormat="netcdf"
export outFormat="grib2"

# Set date/time information
export startdate=2012062912
export fhr=00
export lastfhr=24
export incrementhr=03

# Set domain lists
export domain_list="d01 d02"

# MET settings

export START_TIME=2012062912
export DOMAIN_LIST=d01
export GRID_VX=FCST
export MODEL=ARW
export ACCUM_TIME=3
export BUCKET_TIME=1
export OBTYPE=ST2

# Forecast hours to evaluate
export FCST_HR_BEG=0
export FCST_HR_END=24
export FCST_HR_INC=3 
