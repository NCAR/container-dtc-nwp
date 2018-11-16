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
   convert $file -trim $file
done

for domain in `ls -1 *.png | awk '{print substr($0, length($0)-6)}' | cut -d'.' -f1 | sort -u`
do
  convert -delay 100 plt_Surface_multi_${domain}*.png Surface_multi_${domain}.gif
  convert -delay 100 plt_Precip_multi_total_${domain}*.png Precip_total_${domain}.gif
  convert -delay 100 plt_dbz1*${domain}*.png DBZ1_${domain}.gif
done   

ls -alh *gif

echo Done.
