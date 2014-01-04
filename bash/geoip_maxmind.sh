#!/bin/bash
# --------------------------------------
#
#    Title: Script for update/download DB geoip [MAXMIND]
#    Author: Artem Leontiev [aleontiev/artdokxxx]
#
#     Name: geoip_update_maxmind
#     File: geoip_maxmind.sh
#     Created: September 10, 2013
#
# --------------------------------------

now_str=$(date +"%d-%m-%Y %H:%M")
echo "!!!! $now_str START UPDATE GEOIP [MAXMIND] !!!!"

check_install() {
    local I=`dpkg -s $1 | grep "Status" `
    if [ -n "$I" ]
    then
        return 0
    else
        return 1
    fi
}

if [ $# -lt 1 ]
then
    echo ' Error - incorect count parameters ($1 - dir for download)'

    echo " Commandline parameters:"
    echo $1 ' -> echo $1'

    exit
fi

check_install gzip
if [ $? -ne 0 ];
then
    echo " !!! ERROR - Not found package GZIP [Please install] !!!"
    exit 1
fi

check_install wget
if [ $? -ne 0 ];
then
    echo " !!! ERROR - Not found package WGET [Please install] !!!"
    exit 1
fi

dir_download=$1

if ! [ -d $1 ];
then
    echo " !!! ERROR - Not isset directory /etc/nginx/geo/ !!!"
    exit 1
fi

echo " ==== Start remove old files ==== "
rm $dir_download/*.gz > /dev/null
rm $dir_download/*.gz.* > /dev/null
echo " ==== Finish remove old files ==== "

wget -P $dir_download http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
wget -P $dir_download http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
gunzip -f $dir_download/GeoIP.dat.gz
gunzip -f $dir_download/GeoLiteCity.dat.gz
echo "$now_str" > $dir_download/.flag_start

echo "!!!! $now_str FINISH UPDATE GEOIP, PATH - $1  [MAXMIND] !!!!"
