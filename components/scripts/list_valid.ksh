#!/bin/ksh

DATE=date

# Make sure there are exactly 3 arguments
if [ $# -lt 3 ]; then
  echo
  echo "ERROR: Incorrect number of arguments."
  echo "       Usage: $0 beg end inc [-fmt str]"
  echo "          where \"beg\" and \"end\" are times in YYYYMMDD, YYYYMMDDHH, YYYYMMDD_HH, or YYYYMMDD_HHMMSS format"
  echo "                \"inc\" is in HH[MM[SS]] format"
  echo "                \"-fmt str\" specifies the output time format"
  echo
  exit 1
fi

BegDate=$1
EndDate=$2
IncTime=$3
OutFmt="NA"

# Look for format option
while [ $# -gt 0 ]
do
  case "$1" in
    -fmt)  shift; OutFmt=$1;;
  esac
  shift
done

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

Len=`   echo $BegDate | wc -c`
BegUt=` parse_yyyymmdd_hhmmss $BegDate`
EndUt=` parse_yyyymmdd_hhmmss $EndDate`
IncSec=`parse_hhmmss $IncTime`

# Loop through the times
CurUt=$BegUt
while [[ $CurUt -le $EndUt ]]; do
   if [ $OutFmt != "NA" ]; then
      echo `${DATE} -ud '1970-01-01 UTC '$CurUt' seconds' +${OutFmt}`
   elif [ $Len -ge 16 ]; then
      echo `${DATE} -ud '1970-01-01 UTC '$CurUt' seconds' +%Y%m%d_%H%M%S`
   elif [ $Len -ge 14 ]; then
      echo `${DATE} -ud '1970-01-01 UTC '$CurUt' seconds' +%Y%m%d_%H%M`
   elif [ $Len -ge 12 ]; then
      echo `${DATE} -ud '1970-01-01 UTC '$CurUt' seconds' +%Y%m%d_%H`
   elif [ $Len -ge 11 ]; then
      echo `${DATE} -ud '1970-01-01 UTC '$CurUt' seconds' +%Y%m%d%H`
   else
      echo `${DATE} -ud '1970-01-01 UTC '$CurUt' seconds' +%Y%m%d`
   fi

   # Increment lead time
   CurUt=`expr $CurUt + $IncSec`
done
