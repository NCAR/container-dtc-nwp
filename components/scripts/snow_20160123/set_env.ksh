#!/bin/ksh

# WRF settings

export WPS_VERSION="4.0.2"
export WRF_VERSION="4.0.2"

# UPP settings

# Set input format from model
export inFormat="netcdf"
export outFormat="grib"

# Set date/time information
export startdate=2016012300
export fhr=00
export lastfhr=06
export incrementhr=01

# Set domain lists
export domain_list="d01"

# MET settings

export START_TIME=2016012300
export DOMAIN_LIST=d01
export GRID_VX=FCST
export MODEL=ARW
export ACCUM_TIME=3
export BUCKET_TIME=1
export OBTYPE=MRMS

# Forecast hours to evaluate
export FCST_HR_BEG=0
export FCST_HR_END=24
export FCST_HR_INC=3
