#!/bin/bash
#
# Simplified script to run wrf test Sandy case in Docker world
#
# Examples in block below.
# ./run-dtc-nwp -np 1 -skip wps -namelist /path/to/namelist -skip real

#Initalize options
num_procs=1
skip_wps=false
skip_real=false
skip_wrf=false
skip_upp=false
my_namelist=false

# Variables need to match docker container volume names:
WRF_BUILD="/wrf"
NML_DIR="/scripts/sandy_20121027/param"
SCRIPT_DIR="/scripts/sandy_20121027/run"
WPSPRD_DIR="/wpsprd"
INPUT_DIR="/case_data/sandy_20121027"
WRFPRD_DIR="/wrfprd"
OUTPUT_DIR="/wrfoutput"
POSTPRD_DIR="/postprd"

# Read in command line options
while (( $# > 1 ))
do

opt="$1"
case $opt in

   "-np")
        num_procs="$2"
        shift
        ;;

   "-skip")
        skip_stuff="$2"
	   if [[ $skip_stuff == "wps" ]]; then
             skip_wps=true
           fi
           if [[ $skip_stuff == "real" ]]; then
             skip_real=true
           fi
           if [[ $skip_stuff == "wrf" ]]; then
             skip_wrf=true
           fi
           if [[ $skip_stuff == "upp" ]]; then
             skip_upp=true
           fi
       shift
       ;;

   "-namelist")
       my_namelist=true
       NML_DIR="$2"
       shift
       ;;

   *)
        echo "Usage: Incorrect"
        exit 15
        ;;
esac
shift
done

echo "num_procs     = " $num_procs
echo "skip_wps      = " $skip_wps
echo "skip_real     = " $skip_real
echo "skip_wrf      = " $skip_wrf
echo "skip_upp      = " $skip_upp
echo "my_namelist   = " $my_namelist
echo "namelist dir  = " $NML_DIR
# End sample argument list

# Set input data contain location

# To run the test, bring in the correct namelist.wps, and link the Grib data,
# select the right Vtable.

if [ $skip_wps = "false" ]; then # Don't skip wps
echo Running WPS 

mkdir -p $WPSPRD_DIR
cd $WPSPRD_DIR

ln -sf $WRF_BUILD/WPS/*.exe .

# Get namelist and correct Vtable based on data
# The Vtable is dependent on the data that is used
# Will need to pull this in dynamically somehow, tie to data/namelist

cp -f $NML_DIR/namelist.wps .
cp -f $NML_DIR/Vtable.GFS Vtable

# Link input data
$WRF_BUILD/WPS/link_grib.csh $INPUT_DIR/model_data/gfs/*_*

##################################
#     Run the geogrid program    #
##################################

echo Starting geogrid

# Remove old files
  if [ -e geo_em.d01.nc ]; then
	rm -rf geo_em.d01.nc
  fi

# Command for geogrid
  ./geogrid.exe >& print.geogrid.txt

# KRF: How much "checking" do we want?
# Check success
  ls -ls geo_em.d01.nc
  OK_geogrid=$?

  if [ $OK_geogrid -eq 0 ]; then
	tail print.geogrid.txt
	echo
	echo OK geogrid ran fine
	echo Completed geogrid, Starting ungrib at `date`
	echo
  else
	echo
	echo TROUBLES
	echo geogrid did not complete
	echo
	cat geogrid.log
	echo
	exit 444
  fi

##################################
#    Run the ungrib program      #
##################################

echo Starting ungrib

# checking to remove old files
  file_date=`cat namelist.wps | grep -i start_date | cut -d"'" -f2 | cut -d":" -f1`
  if [ -e PFILE:${file_date} ]; then
	rm -rf PFILE*
  fi
  if [ -e FILE:${file_date} ]; then
	rm -rf FILE*
  fi

# Command for ungrib
  ./ungrib.exe >& print.ungrib.txt

  ls -ls FILE:*
  OK_ungrib=$?

  if [ $OK_ungrib -eq 0 ]; then
	tail print.ungrib.txt
	echo
	echo OK ungrib ran fine
	echo Completed ungrib, Starting metgrid at `date`
	echo
  else
	echo
	echo TROUBLES
	echo ungrib did not complete
	echo
	cat ungrib.log
	echo
	exit 555
  fi

##################################
#     Run the metgrid program    #
##################################

echo Starting metgrid 

# Remove old files
  if [ -e met_em.d01.${file_date}:00:00.nc ]; then
	rm -rf met_em.d01.*
  fi

# Command for metgrid
  ./metgrid.exe >& print.metgrid.txt

# Check sucess
  ls -ls met_em.d01.*
  OK_metgrid=$?

  if [ $OK_metgrid -eq 0 ]; then
	tail print.metgrid.txt
	echo
	echo OK metgrid ran fine
	echo Completed metgrid, Starting program real at `date`
	echo
  else
	echo
	echo TROUBLES
	echo metgrid did not complete
	echo
	cat metgrid.log
	echo
	exit 666
  fi

fi # end if skip_wps = false

##################################
#    Move to WRF                 #
##################################

echo Running WRF

# Go to test directory where tables, data, etc. exist
# Perform wrf run here.

mkdir -p $WRFPRD_DIR
cd $WRFPRD_DIR

ln -sf $WRF_BUILD/WRFV3/run/* .
rm namelist*

# cp $INPUT_DIR/namelist.input .
cp $NML_DIR/namelist.wps .
cp $NML_DIR/namelist.input .
sed -e '/nocolons/d' namelist.input > nml
cp namelist.input namelist.nocolons
mv nml namelist.input

##################################
#     Run the real program       #
##################################

if [ $skip_real = "false" ]; then # Don't skip real
echo Running real

# Link data from WPS
  ln -sf $WPSPRD_DIR/met_em.d0* .

# Remove old files
  if [ -e wrfinput_d01 ]; then
	rm -rf wrfi* wrfb*
  fi

# Command for real
    ./real.exe

# Check success
  ls -ls wrfinput_d01
  OK_wrfinput=$?

  ls -ls wrfbdy_d01
  OK_wrfbdy=$?

  if [ $OK_wrfinput -eq 0 ] && [ $OK_wrfbdy -eq 0 ]; then
	tail rsl.error.0000
        echo
	echo OK real ran fine
        echo

  else
	cat rsl.error.0000
	echo
	echo TROUBLES
	echo the real program did not complete
	echo
	exit 777
  fi

fi # end skip_real = false

##################################
#   Run the WRF forecast model.  #
##################################

if [ $skip_wrf = "false" ]; then # Don't skip wrf
echo Running wrf.exe 

# Command for openmpi wrf in Docker world
cp namelist.nocolons namelist.input
#mpirun --allow-run-as-root -np $num_procs ./wrf.exe
# Command for serial wrf in Docker world
./wrf.exe

# Check success
  ls -ls $WRFPRD_DIR/wrfo*
  OK_wrfout=$?

  if [ $OK_wrfout -eq 0 ]; then
	tail rsl.error.0000
	echo
	echo OK wrf ran fine
	echo Completed WRF model with $FCST_LENGTH_HOURS hour simulation at `date`
	echo
  else
	cat rsl.error.0000
       	echo
	echo TROUBLES
	echo the WRF model did not complete
	echo
	exit 888
  fi

fi # end skip_wrf = false

##################################
#   Run UPP                      #
##################################

if [ $skip_upp = "false" ]; then # Don't skip upp
echo Running UPP

mkdir -p $POSTPRD_DIR
cd $POSTPRD_DIR

cp $SCRIPT_DIR/run_unipost.ksh .
./run_unipost.ksh

fi # end skip_upp = false

echo Done
 
