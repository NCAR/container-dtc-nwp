#!/bin/ksh

#
# Simplified script to run WRF in Docker world
# Optional arguments: -np, -slots, -hosts, -face
#

# Constants
WRF_BUILD="/wrf"
INPUT_DIR="/case_data"
SCRIPT_DIR="/scripts/common"
CASE_DIR="/scripts/case"
WRFPRD_DIR="/wpsprd"
GSIPRD_DIR="/gsiprd"

# Check for the correct container
if [[ ! -e $WRF_BUILD ]]; then
  echo
  echo ERROR: wrf.exe can only be run with the dtc-nwp-wps-wrf container.
  echo
  exit 1
fi

# Check for input directory
if [[ ! -e $CASE_DIR ]]; then
  echo
  echo ERROR: The $CASE_DIR directory is not mounted.
  echo
  exit 1
fi

# Check for output directory
if [[ ! -e $WRFPRD_DIR ]]; then
  echo
  echo ERROR: The $WRFPRD_DIR directory is not mounted.
  echo
  exit 1
fi
cd $WRFPRD_DIR

# Include case-specific settings
. $CASE_DIR/set_env.ksh

# Initalize command line options
num_procs=4
process_per_host=1
iface=eth0
hosts=127.0.0.1

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
echo "hosts         = " $hosts
# End sample argument list

# start ssh
/usr/sbin/sshd

##################################
#   Run the WRF forecast model.  #
##################################

echo Running wrf.exe 

ln -sf $WRF_BUILD/WRF-${WRF_VERSION}/run/* .
rm namelist*

cp $CASE_DIR/namelist.input .
sed -e '/nocolons/d' namelist.input > nml
cp namelist.input namelist.nocolons
mv nml namelist.input

# If GSI was run, update the wrfinput file
if [[ -e $GSIPRD_DIR/wrf_inout ]]; then
  mv wrfinput_d01 wrfinput_d01.orig
  cp $GSIPRD_DIR/wrf_inout wrfinput_d01
fi

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

echo Done with wrf.exe
