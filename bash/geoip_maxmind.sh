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

wget -P /etc/nginx/geo/ http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
wget -P /etc/nginx/geo/ http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
gunzip -f /etc/nginx/geo/GeoIP.dat.gz
gunzip -f /etc/nginx/geo/GeoLiteCity.dat.gz
echo "$now_str" > /etc/nginx/geo/.flag_start

echo "!!!! $now_str FINISH UPDATE GEOIP [MAXMIND] !!!!"
