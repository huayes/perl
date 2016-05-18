#!/bin/bash
Yesterday=`date -d yesterday +%Y%m%d`
Twodayago=`date -d '2 days ago' +%Y%m%d`
sed -i "/MatchFiles/ s/${Twodayago}/${Yesterday}/" "/data/callcenter_backup/ftp.pl"
#echo $Yesterday
#echo $Twodayago
