#!/bin/ksh

export NCARG_ROOT=/usr/local
#
#
cd /nclprd
for nclscript in `ls -1 /scripts/sandy_20121027/run/*png.ncl`
do
   ncl $nclscript
done
#
echo convert to animated gif
for file in `ls -1 *png`
do
   base=`basename $file .png`
   convert -trim $file $base.jpg
done

convert -delay 100 plt_Surface_multi_d01*.jpg Surface_multi_d01.gif
rm -f plt_Surface_multi*.jpg

convert -delay 100 plt_Precip_multi_total_d01*.jpg Precip_total_d01.gif
rm -f plt_Precip_multi_total*.jpg

ls -alh *gif

echo Done.
