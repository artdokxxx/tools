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
    local now_str=$(date +"%d-%m-%Y %H:%M")
    echo " ==== $now_str Start reload nginx ==== "
    nginx -s reload

    now_str=$(date +"%d-%m-%Y %H:%M")
    echo " ==== $now_str Finish reload nginx ==== "
}

translit_ru_en() {
    if [ $# -lt 1 ]
    then
        echo ' Error - incorect count parameters ($1 - string; $2 - nginx reload [not require, ex.: --nginx-reload])'

        echo " Commandline parameters:"
        echo $1 ' -> echo $1'

        exit
    fi

    STRING=`echo $1 | sed "y/абвгдезийклмнопрстуфхцы /abvgdezijklmnoprstufxcy /"`
    STRING=`echo $STRING | sed "y/АБВГДЕЗИЙКЛМНОПРСТУФХЦЫ /ABVGDEZIJKLMNOPRSTUFXCY /"`
    STRING=${STRING//ч/ch};
    STRING=${STRING//Ч/CH} STRING=${STRING//ш/sh};
    STRING=${STRING//Ш/SH} STRING=${STRING//ё/jo};
    STRING=${STRING//Щ/SСH};
    STRING=${STRING//Ё/JO} STRING=${STRING//ж/zh};
    STRING=${STRING//Ж/ZH} STRING=${STRING//щ/sch\'};
    STRING=${STRING//э/je};
    STRING=${STRING//Э/JE} STRING=${STRING//ю/ju};
    STRING=${STRING//Ю/JU} STRING=${STRING//я/ja};
    STRING=${STRING//Я/JA} STRING=${STRING//ъ/\`};
    STRING=${STRING//ъ\`} STRING=${STRING//ь/\'};
    STRING=${STRING//Ь/\'}

    echo $STRING
}

if [ $# -lt 1 ]
then
    echo ' Error - incorect count parameters ($1 - dir for download)'

    echo " Commandline parameters:"
    echo $1 ' -> echo $1'

    exit
fi

if [ "$1" = "--help" ];
then
    echo "Script for update/download DB geoip";
    echo "Author: Artem Leontiev [aleontiev/artdokxxx]";
    echo "Example: ";
    echo "geoip_geobase /etc/nginx/geobase/ --nginx-reload OR geoip_geobase /etc/nginx/geobase/";

    exit
fi

if [ "$2" = "--nginx-reload" ];
then
    NGINX_RELOAD=true
else
    NGINX_RELOAD=false
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
find $dir_download -type 'f' | grep -v 'RU.conf' | grep -v "region.conf" | grep -v '.flag_start' | while read -r line;
do
    echo "remove line - $line";
    rm -r $line
done
echo " ==== Finish remove old files ==== "


cd $dir_download
wget http://ipgeobase.ru/files/db/Main/geo_files.tar.gz
tar zxf geo_files.tar.gz
recode WINDOWS-1251..utf8 *.txt
cat cidr_optim.txt | awk '{if ($7 != "-") print $3$4$5" "$7";"}' > region.conf.tmp;
cat cities.txt | awk -F"\t" '{gsub(" ", "_", $2); a = ""$1" "$2";"; print a}' | while read -r line;
do
    TRS=$(translit_ru_en "$line")
    echo $TRS >> RU.conf.tmp
done

if [ -s "$dir_download/RU.conf.tmp" ];
then
    rm $dir_download/RU.conf
    mv $dir_download/RU.conf.tmp $dir_download/RU.conf
else
    echo " !!! ALERT - EMPTY NEW RU.conf !!!"
fi

if [ -s "$dir_download/region.conf.tmp" ];
then
    rm $dir_download/region.conf
    mv $dir_download/region.conf.tmp $dir_download/region.conf
else
        echo " !!! ALERT - EMPTY NEW region.conf !!!"
fi

echo " ==== Start remove tempory files ==== "
find $dir_download -type 'f' | grep -v 'RU.conf' | grep -v "region.conf" | while read -r line;
do
    echo "remove line - $line";
    rm -r $line
done
echo " ==== Finish remove tempory files ==== "

if $NGINX_RELOAD;
then
    nginx_reload
fi

now_str=$(date +"%d-%m-%Y %H:%M")
echo "$now_str" > $dir_download/.flag_start
echo "!!!! $now_str FINISH UPDATE GEOIP, PATH - $1  [IPGEOBASE] !!!!"
