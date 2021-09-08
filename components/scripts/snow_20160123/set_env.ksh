#!/bin/ksh

# WRF settings
########################################################################
export WPS_VERSION="4.3"
export WRF_VERSION="4.3"
export input_data="GFS"
export case_name="snow"

# GSI settings
########################################################################
export OBS_ROOT=/data/obs_data/prepbufr
export PREPBUFR=/data/obs_data/prepbufr/2016012300/ndas.t00z.prepbufr.tm06.nr

# UPP settings
########################################################################
# Set input format from model
export inFormat="netcdf"
export outFormat="grib2"

# Set domain lists
export domain_list="d01"

# Set date/time information
export startdate_d01=2016012300
export fhr_d01=00
export lastfhr_d01=24
export incrementhr_d01=01

# NCL settings
#########################################################################
# Binning for temperature plots
export tmin=0
export tmax=90
export tint=5

# Python settings
#########################################################################
export init_time=2016012300
export fhr_beg=00
export fhr_end=24
export fhr_inc=01

# MET settings
#########################################################################
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
