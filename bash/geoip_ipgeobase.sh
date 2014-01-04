#!/bin/bash
# --------------------------------------
#
#    Title: Script for update/download DB geoip [IPGEOBASE]
#    Author: Artem Leontiev [aleontiev/artdokxxx]
#
#     Name: geoip_update_ipgeobase
#     File: geoip_geobase.sh
#     Created: September 11, 2013
#
# --------------------------------------

now_str=$(date +"%d-%m-%Y %H:%M")
echo "!!!! $now_str START UPDATE GEOIP [IPGEOBASE] !!!!"

check_install() {
    local I=`dpkg -s $1 | grep "Status" `
    if [ -n "$I" ]
    then
        return 0
    else
        return 1
    fi
}

nginx_reload() {
    echo " ==== Start reload nginx ==== "
    nginx -s reload
    echo " ==== Finish reload nginx ==== "
}


# TODO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
translit_ru_en() {
    if [ $# -lt 1 ]
    then
        echo ' Error - incorect count parameters ($1 - string)'

        echo " Commandline parameters:"
        echo $1 ' -> echo $1'

        exit
    fi
}

if [ $# -lt 1 ]
then
    echo ' Error - incorect count parameters ($1 - dir for download)'

    echo " Commandline parameters:"
    echo $1 ' -> echo $1'

    exit
fi

check_install tar
if [ $? -ne 0 ];
then
    echo " !!! ERROR - Not found package TAR [Please install] !!!"
    exit 1
fi

check_install wget
if [ $? -ne 0 ];
then
    echo " !!! ERROR - Not found package WGET [Please install] !!!"
    exit 1
fi

check_install recode
if [ $? -ne 0 ];
then
    echo " !!! ERROR - Not found package RECODE [Please install] !!!"
    exit 1
fi

dir_download=$1

if ! [ -d $dir_download ];
then
    echo " !!! ERROR - Not isset directory $dir_download !!!"
    exit 1
fi

echo " ==== Start remove old files ==== "
rm $dir_download/*.gz > /dev/null
rm $dir_download/*.gz.* > /dev/null
echo " ==== Finish remove old files ==== "

cd $dir_download
wget http://ipgeobase.ru/files/db/Main/geo_files.tar.gz
tar zxf geo_files.tar.gz
recode WINDOWS-1251..utf8 *.txt
cat cidr_optim.txt | awk '{if ($7 != "-") print $3$4$5" "$7";"}' > region.conf;
cat cities.txt | awk -F"\t" '{gsub(" ", "_", $2); a = "\""$1" "$2";\"";  system("/usr/local/scripts/translit " a)}' > RU.conf # TODO - replace for function

echo " ==== Start remove tempory files ==== "
rm -f geo_files.tar.gz
rm -f cidr_optim.txt
rm -f cities.txt
echo " ==== Finish remove tempory files ==== "
nginx_reload

echo "$now_str" > $dir_download/.flag_start
echo "!!!! $now_str FINISH UPDATE GEOIP, PATH - $1  [IPGEOBASE] !!!!"
