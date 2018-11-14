#!/bin/bash
#
# Common script to run wps, real, and/or wrf in Docker world
#
# Examples in block below.
# ./run-dtc-wps-wrf.ksh -np 2 -slots 2 -face eth0 -run wps -namelist /path/to/namelist -run real

#Initalize options
num_procs=4
process_perhost=1
iface=eth0
run_wps=false
run_real=false
run_wrf=false
my_namelist=false
hosts=127.0.0.1

# Variables need to match docker container volume names:
WPS_VERSION="4.0.2"
WRF_VERSION="4.0.2"

WRF_BUILD="/wrf"
INPUT_DIR="/case_data"
NML_DIR="/scripts/case/param"
SCRIPT_DIR="/scripts/case/run"

WPSPRD_DIR="/wpsprd"
WRFPRD_DIR="/wrfprd"

# Read in command line options
while (( $# > 1 ))
do

opt="$1"
case $opt in

   "-np")
        num_procs="$2"
        shift
        ;;

    "-slots")
        process_per_host="$2"
        shift
        ;;
   
   "-hosts")
        hosts="$2"
        shift
        ;;
        
   "-iface")
        iface="$2"
        shift
        ;;

   "-run")
        run_stuff="$2"
	   if [[ $run_stuff == "wps" ]]; then
             run_wps=true
           fi
           if [[ $run_stuff == "real" ]]; then
             run_real=true
           fi
           if [[ $run_stuff == "wrf" ]]; then
             run_wrf=true
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

echo "slots         = " $process_per_host
echo "iface         = " $iface
echo "num_procs     = " $num_procs
echo "run_wps       = " $run_wps
echo "run_real      = " $run_real
echo "run_wrf       = " $run_wrf
echo "my_namelist   = " $my_namelist
echo "namelist dir  = " $NML_DIR
# End sample argument list

# start ssh
/usr/sbin/sshd

# Set input data contain location

# To run the test, bring in the correct namelist.wps, and link the Grib data,
# select the right Vtable.

if [ $run_wps = "true" ]; then # Run wps
echo Running WPS 

mkdir -p $WPSPRD_DIR
cd $WPSPRD_DIR

ln -sf $WRF_BUILD/WPS-${WPS_VERSION}/*.exe .

# Get namelist and correct Vtable based on data
# The Vtable is dependent on the data that is used
# Will need to pull this in dynamically somehow, tie to data/namelist

cp -f $NML_DIR/namelist.wps .
cp -f $NML_DIR/Vtable.GFS Vtable

# Link input data
$WRF_BUILD/WPS-${WPS_VERSION}/link_grib.csh $INPUT_DIR/model_data/gfs/*_*

##################################
#     Run the geogrid program    #
##################################

echo Starting geogrid

# Remove old files
  if [ -e geo_em.d*.nc ]; then
	rm -rf geo_em.d*.nc
  fi

# Command for geogrid
  ./geogrid.exe >& print.geogrid.txt

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
  if [ -e met_em.d*.${file_date}:00:00.nc ]; then
	rm -rf met_em.d*
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

fi # end if run_wps = true

##################################
#    Move to WRF                 #
##################################

echo Running WRF

# Go to test directory where tables, data, etc. exist
# Perform wrf run here.

mkdir -p $WRFPRD_DIR
cd $WRFPRD_DIR

ln -sf $WRF_BUILD/WRF-${WRF_VERSION}/run/* .
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

if [ $run_real = "true" ]; then # Run real 
echo Running real

# Link data from WPS
  ln -sf $WPSPRD_DIR/met_em.d0* .

# Remove old files
  if [ -e wrfinput_d* ]; then
	rm -rf wrfi* wrfb*
  fi

# Command for real
    ./real.exe >& print.real.txt

# Check success
  ls -ls wrfinput_d01
  OK_wrfinput=$?

  ls -ls wrfbdy_d01
  OK_wrfbdy=$?

  if [ $OK_wrfinput -eq 0 ] && [ $OK_wrfbdy -eq 0 ]; then
	tail print.real.txt
        echo
	echo OK real ran fine
        echo

  else
	cat print.real.txt
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

if [ $run_wrf = "true" ]; then # Run wrf
echo Running wrf.exe 

# generate machine list
IFS=,
ary=($hosts)
for key in "${!ary[@]}"; do echo "${ary[$key]} slots=${process_per_host}" >> $WRFPRD_DIR/hosts; done

# Command for openmpi wrf in Docker world
cp namelist.nocolons namelist.input
mpirun --allow-run-as-root -np $num_procs ./wrf.exe
time mpirun --allow-run-as-root -hostfile /wrf/hosts -np $num_procs --mca btl self,tcp --mca btl_tcp_if_include $iface ./wrf.exe

# Command for serial wrf in Docker world
#./wrf.exe >& print.wrf.txt

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

fi # end run_wrf = true 

echo Done
 
