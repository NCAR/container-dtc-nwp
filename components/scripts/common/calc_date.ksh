#!/bin/ksh

DATE=date

usage() {
  echo
  echo "Usage: $0 beg +|-inc [-fmt str]"
  echo "  where \"beg\"      in YYYYMMDD, YYYYMMDDHH, YYYYMMDD_HH, or YYYYMMDD_HHMMSS format"
  echo "        \"+|-\"      for addition or subtraction"
  echo "        \"inc\"      in HH[MM[SS]] format"
  echo "        \"-fmt str\" for the output time format"
  echo
  exit 1
}

parse_hhmmss() {
  Len=`echo $1 | wc -c`
  SEC=0
  if [ $Len -ge 2 ]; then
    N=`echo $1 | cut -c1-2`
    INC=`expr $N \* 3600`
    SEC=`expr $SEC + $INC`
  fi
  if [ $Len -ge 4 ]; then
    N=`echo $1 | cut -c3-4`
    INC=`expr $N \* 60`
    SEC=`expr $SEC + $INC`
  fi
  if [ $Len -ge 6 ]; then
    N=`echo $1 | cut -c5-6`
    SEC=`expr $SEC + $N`
  fi
  echo $SEC
}

parse_yyyymmdd_hhmmss() {
  Len=`echo $1 | wc -c`
  YR=` echo $1 | cut -c1-4`
  MM=` echo $1 | cut -c5-6`
  DD=` echo $1 | cut -c7-8`
  UT=` ${DATE} -ud ''${YR}-${MM}-${DD}' UTC '00:00:00'' +%s`
  # Format: YYYYMMDDHH
  if [ $Len -eq 11 ]; then
    HMS=`echo $1 | cut -c9-10`
    UT=$(($UT + `parse_hhmmss $HMS`))
  # Format: YYYYMMDD_HHMMSS
  elif [ $Len -ge 12 ]; then
    HMS=`echo $1 | cut -c10-15`
    UT=$(($UT + `parse_hhmmss $HMS`))
  fi
  echo $UT
}

# Make sure there are exactly 2 arguments
if [ $# -lt 2 ]; then
  echo "ERROR: Incorrect number of arguments."
  usage
  exit 1
fi

# Store arguments
BegDate=$1
TimeOp=`echo $2 | cut -c1`
IncTime=`echo $2 | cut -c2-10`
OutFmt="NA"

# Look for format option
while [ $# -gt 0 ]
do
  case "$1" in
    -fmt)  shift; OutFmt=$1;;
  esac
  shift
done

# Parse input times
Len=`   echo $BegDate | wc -c`
BegUt=` parse_yyyymmdd_hhmmss $BegDate`
IncSec=`parse_hhmmss $IncTime`

# Process time operator
if [[ $TimeOp == '+' ]]; then
  NewUt=`expr $BegUt + $IncSec`
elif [[ $TimeOp == '-' ]]; then
  NewUt=`expr $BegUt - $IncSec`
else
  echo "ERROR: Unexpected time operator: $TimeOp"
  exit 1
fi

# Write output time
if [ $OutFmt != "NA" ]; then
  echo `${DATE} -ud '1970-01-01 UTC '$NewUt' seconds' +${OutFmt}`
elif [ $Len -ge 16 ]; then
  echo `${DATE} -ud '1970-01-01 UTC '$NewUt' seconds' +%Y%m%d_%H%M%S`
elif [ $Len -ge 14 ]; then
  echo `${DATE} -ud '1970-01-01 UTC '$NewUt' seconds' +%Y%m%d_%H%M`
elif [ $Len -ge 12 ]; then
  echo `${DATE} -ud '1970-01-01 UTC '$NewUt' seconds' +%Y%m%d_%H`
elif [ $Len -ge 11 ]; then
  echo `${DATE} -ud '1970-01-01 UTC '$NewUt' seconds' +%Y%m%d%H`
else
  echo `${DATE} -ud '1970-01-01 UTC '$NewUt' seconds' +%Y%m%d`
fi

