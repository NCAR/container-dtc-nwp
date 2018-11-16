#!/bin/ksh

export NCARG_ROOT=/usr/local
#
#
cd /nclprd
for nclscript in `ls -1 /nclscripts/*png.ncl`
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

for domain in `ls -1 *.png | awk '{print substr($0, length($0)-6)}' | cut -d'.' -f1 | sort -u`
do
  convert -delay 100 plt_Surface_multi_${domain}*.jpg Surface_multi_${domain}.gif
  convert -delay 100 plt_Precip_multi_total_${domain}*.jpg Precip_total_${domain}.gif
  convert -delay 100 plt_dbz1*${domain}*.jpg DBZ1_${domain}.gif
done   
rm -f plt_Surface_multi*.jpg
rm -f plt_Precip_multi_total*.jpg
rm -f plt_dbz1*.jpg

ls -alh *gif

echo Done.
