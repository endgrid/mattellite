#!/bin/sh
date=`date +%F`
cd /root/scans
nmap -v -T4 -sn 192.168.0.0/24 -oX scan-$date.xml > /dev/null
if [ -e scan-prev.xml ] ; then
        ndiff -v scan-prev.xml scan-$date.xml > diff-$date
        echo -e "Network changes since last scan: \n$(cat diff-$date)" | mail -s "$(date +%D) Network report" recipient@gmail.com
fi
mv -f scan-$date.xml scan-prev.xml
rm -f scan-2*
rm -f diff*
