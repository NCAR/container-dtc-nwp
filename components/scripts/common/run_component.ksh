#!/bin/ksh
#
# Common script for running wps, real, gsi, wrf, upp, ncl, and met in Docker world
#
# Examples in block below.
# ./run_component.ksh                           -namelist /path/to/namelist -run wps -run real
# ./run_component.ksh                           -namelist /path/to/namelist -run gsi
# ./run_component.ksh -np 2 -slots 2 -face eth0 -namelist /path/to/namelist -run wrf 

#Initalize options
num_procs=4
process_per_host=1
iface=eth0
run_wps=false
run_real=false
run_gsi=false
run_wrf=false
run_upp=false
run_ncl=false
run_met=false
my_namelist=false
hosts=127.0.0.1

# Variables need to match docker container volume names:
WPS_VERSION="4.0.2"
WRF_VERSION="4.0.2"

WRF_BUILD="/wrf"
INPUT_DIR="/case_data"
NML_DIR="/scripts/case"
SCRIPT_DIR="/scripts/common"

# Output directories
WPSPRD_DIR="/wpsprd"
WRFPRD_DIR="/wrfprd"
GSIPRD_DIR="/gsiprd"
POSTPRD_DIR="/postprd"
NCLPRD_DIR="/nclprd"
METPRD_DIR="/metprd"

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
           if [[ $run_stuff == "gsi" ]]; then
             run_gsi=true
           fi
           if [[ $run_stuff == "wrf" ]]; then
             run_wrf=true
           fi
           if [[ $run_stuff == "upp" ]]; then
             run_upp=true
           fi
           if [[ $run_stuff == "ncl" ]]; then
             run_ncl=true
           fi
           if [[ $run_stuff == "met" ]]; then
             run_met=true
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
        exit 1
        ;;
esac
shift
done

echo "slots         = " $process_per_host
echo "iface         = " $iface
echo "num_procs     = " $num_procs
echo "run_wps       = " $run_wps
echo "run_real      = " $run_real
echo "run_gsi       = " $run_gsi
echo "run_wrf       = " $run_wrf
echo "run_upp       = " $run_upp
echo "run_ncl       = " $run_ncl
echo "run_met       = " $run_met
echo "my_namelist   = " $my_namelist
echo "namelist dir  = " $NML_DIR
# End sample argument list

# start ssh
/usr/sbin/sshd

# Set input data contain location

# To run the test, bring in the correct namelist.wps, and link the Grib data,
# select the right Vtable.

##################################
#     Run the WPS programs       #
##################################

if [[ $run_wps == "true" ]]; then
  echo Running WPS

  # Check for WPS output directory
  if [[ ! -e $WPSPRD_DIR ]]; then
    echo
    echo ERROR: The output $WPSPRD_DIR directory is not mounted.
    echo
  fi
  cd $WPSPRD_DIR

  ln -sf $WRF_BUILD/WPS-${WPS_VERSION}/*.exe .

  # Check for the correct container
  if [[ ! -e /wrf ]]; then
    echo
    echo ERROR: WPS can only be run with the dtc-nwp-wps-wrf container.
    echo
  fi

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
    echo OK geogrid ran fine at `date`
    echo Completed geogrid, Starting ungrib
    echo
  else
    echo
    echo ERROR: geogrid.exe did not complete
    echo
    cat geogrid.log
    echo
    exit 11 
  fi

  ##################################
  #    Run the ungrib program      #
  ##################################

  echo Starting ungrib

  # Remove old files
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
    echo OK ungrib ran fine at `date`
    echo Completed ungrib, Starting metgrid
    echo
  else
    echo
    echo ERROR: ungrib.exe did not complete
    echo
    cat ungrib.log
    echo
    exit 22 
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
    echo OK metgrid ran fine at `date`
    echo Completed metgrid, Starting program real
    echo
  else
    echo
    echo ERROR: metgrid.exe did not complete
    echo
    cat metgrid.log
    echo
    exit 33 
  fi

fi # end if run_wps == true

##################################
#    Setup WRF environment       #
##################################

if [[ $run_real == "true" || $run_wrf == "true" ]]; then


  # Check for WPS input directory
  if [[ ! -e $WPSPRD_DIR ]]; then
    echo
    echo ERROR: The input $WPSPRD_DIR directory is not mounted.
    echo
  fi

  # Check for WRF output directory
  if [[ ! -e $WRFPRD_DIR ]]; then
    echo
    echo ERROR: The output $WRFPRD_DIR directory is not mounted.
    echo
  fi
  cd $WRFPRD_DIR
  
  ln -sf $WRF_BUILD/WRF-${WRF_VERSION}/run/* .
  rm namelist*

  cp $NML_DIR/namelist.wps .
  cp $NML_DIR/namelist.input .
  sed -e '/nocolons/d' namelist.input > nml
  cp namelist.input namelist.nocolons
  mv nml namelist.input

fi

##################################
#     Run the real program       #
##################################

if [[ $run_real == "true" ]]; then
  echo Running real.exe

  # Check for the correct container
  if [[ ! -e /wrf ]]; then
    echo
    echo ERROR: real.exe can only be run with the dtc-nwp-wps-wrf container.
    echo
  fi

  # Check for WPS input directory
  if [[ ! -e $WPSPRD_DIR ]]; then
    echo
    echo ERROR: The output $WPSPRD_DIR directory is not mounted.
    echo
  fi

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
    echo OK real ran fine at `date`
    echo
  else
    cat print.real.txt
    echo
    echo ERROR: real.exe did not complete
    echo
    exit 44 
  fi

fi # end run_real == true 

##################################
#     Run GSI                    #
##################################

if [[ $run_gsi == "true" ]]; then
  echo Running GSI 

  # Check for the correct container
  if [[ ! -e /gsi ]]; then
    echo
    echo ERROR: GSI can only be run with the dtc-nwp-gsi container.
    echo
  fi

  # Check for input data
  if [[ ! -e /gsi_data ]]; then
    echo
    echo ERROR: The /gsi_data input directory is not mounted.
    echo
  fi

  # Check for WRF input directory
  if [[ ! -e $WRFPRD_DIR ]]; then
    echo
    echo ERROR: The input $WRFPRD_DIR directory is not mounted.
    echo
  fi

  # Check for GSI output directory
  if [[ ! -e $GSIPRD_DIR ]]; then
    echo
    echo ERROR: The output $GSIPRD_DIR directory is not mounted.
    echo
  fi
  cd $GSIPRD_DIR

  # Run GSI
  $SCRIPT_DIR/run_gsi.ksh >& print.gsi.txt

  # Check return status
  OK_gsi=$?

  if [ $OK_gsi -eq 0 ]; then
    tail print.gsi.txt
    echo
    echo OK GSI ran fine at `date`
    echo
  else
    echo
    echo ERROR: GSI did not complete
    echo
    exit 55 
  fi

fi # end run_gsi == true

##################################
#   Run the WRF forecast model.  #
##################################

if [[ $run_wrf == "true" ]]; then
  echo Running wrf.exe 

  # Check for the correct container
  if [[ ! -e /wrf ]]; then
    echo
    echo ERROR: wrf.exe can only be run with the dtc-nwp-wps-wrf container.
    echo
  fi

  # Check for WRF output directory
  if [[ ! -e $WRFPRD_DIR ]]; then
    echo
    echo ERROR: The output $WRFPRD_DIR directory is not mounted.
    echo
  fi
  cd $WRFPRD_DIR

  # If GSI was run, update the wrfinput file
  if [[ -e $GSIPRD_DIR/wrf_inout ]]; then
    mv wrfinput_d01 wrfinput_d01.orig
    cp $GSIPRD_DIR/wrf_inout wrfinput_d01
  fi

  # Command for openmpi wrf in Docker world
  cp namelist.nocolons namelist.input

  if [ num_procs -eq 1 ]; then
    # Run serial wrf
    ./wrf.exe >& print.wrf.txt
  else

    # Generate machine list
    IFS=,
    ary=($hosts)
    for key in "${!ary[@]}"; do echo "${ary[$key]} slots=${process_per_host}" >> $WRFPRD_DIR/hosts; done
  
    # Run wrf using mpi
    mpirun --allow-run-as-root -np $num_procs ./wrf.exe
    time mpirun --allow-run-as-root -hostfile $WRFPRD_DIR/hosts -np $num_procs --mca btl self,tcp --mca btl_tcp_if_include $iface ./wrf.exe
  fi

  # Check success
  ls -ls $WRFPRD_DIR/wrfo*
  OK_wrfout=$?

  if [ $OK_wrfout -eq 0 ]; then
    tail rsl.error.0000
    echo
    echo OK wrf ran fine at `date`
    echo Completed WRF model
    echo
  else
    cat rsl.error.0000
    echo
    echo ERROR: wrf.exe did not complete
    echo
    exit 66 
  fi

fi # end run_wrf == true 

##################################
#   Run UPP                      #
##################################

if [[ $run_upp == "true" ]]; then
  echo Running UPP

  # Check for the correct container
  if [[ ! -e /upp ]]; then
    echo
    echo ERROR: UPP can only be run with the dtc-nwp-upp container.
    echo
  fi

  # Check for input WRF directory 
  if [[ ! -e $WRFPRD_DIR ]]; then
    echo
    echo ERROR: The input $WRFPRD_DIR directory is not mounted.
    echo
  fi

  # Check for output POST directory
  if [[ ! -e $POSTPRD_DIR ]]; then
    echo
    echo ERROR: The output $POSTPRD_DIR directory is not mounted.
    echo
  fi
  cd $POSTPRD_DIR

  cp $SCRIPT_DIR/run_upp.ksh .
  ./run_upp.ksh >& print.upp.txt

  # Check success
  OK_upp=$?

  if [ $OK_upp -eq 0 ]; then
    tail print.upp.txt
    echo
    echo OK UPP ran fine at `date`
    echo
  else
    echo
    echo ERROR: UPP did not complete
    echo
    exit 77 
  fi

fi # end run_upp == true

##################################
#   Run NCL                      #
##################################

if [[ $run_ncl == "true" ]]; then
  echo Running NCL 

  # Check for the correct container
  if [[ ! -e /ncl ]]; then
    echo
    echo ERROR: NCL can only be run with the dtc-nwp-ncl container.
    echo
  fi

  # Check for input UPP directory
  if [[ ! -e $POSTPRD_DIR ]]; then
    echo
    echo ERROR: The input $POSTPRD_DIR directory is not mounted.
    echo
  fi

  # Check for output NCL directory
  if [[ ! -e $NCLPRD_DIR ]]; then
    echo
    echo ERROR: The output $NCLPRD_DIR directory is not mounted.
    echo
  fi
  cd $NCLPRD_DIR

  $SCRIPT_DIR/run_ncl.ksh >& print.ncl.txt

  # Check success
  OK_ncl=$?

  if [ $OK_ncl -eq 0 ]; then
    tail print.ncl.txt
    echo
    echo OK NCL ran fine at `date`
    echo
  else
    echo
    echo ERROR: NCL did not complete
    echo
    exit 88 
  fi

fi # end run_ncl == true

##################################
#   Run MET                      #
##################################

if [[ $run_met == "true" ]]; then
  echo Running MET 

  # Check for the correct container
  if [[ ! -e /met ]]; then
    echo
    echo ERROR: MET can only be run with the dtc-nwp-met container.
    echo
  fi

  # Check for input UPP directory
  if [[ ! -e $POSTPRD_DIR ]]; then
    echo
    echo ERROR: The input $POSTPRD_DIR directory is not mounted.
    echo
  fi

  # Check for output MET directory
  if [[ ! -e $METPRD_DIR ]]; then
    echo
    echo ERROR: The output $METPRD_DIR directory is not mounted.
    echo
  fi
  cd $METPRD_DIR

  $SCRIPT_DIR/run_met.ksh >& print.met.txt

  # Check success
  OK_met=$?

  if [ $OK_met -eq 0 ]; then
    tail print.met.txt
    echo
    echo OK MET ran fine at `date`
    echo
  else
    echo
    echo ERROR: MET did not complete
    echo
    exit 99 
  fi

fi # end run_met == true 
 
echo Done
