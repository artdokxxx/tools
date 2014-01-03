#!/bin/bash
# --------------------------------------
#
#    Title: Script for backup
#    Author: Artem Leontiev [aleontiev/artdokxxx]
#
#     Name: backup_projects
#     File: backups.sh
#     Created: December 10, 2013
#
# --------------------------------------

if [ $# -lt 3 ]
then
    echo ' Error - incorect count parameters ($1 - projects dir; $2 - dir for backup; $3 - owner group for files)'

    echo " Commandline parameters:"
    echo $1 $2 $3 ' -> echo $1 $2 $3'

    exit
fi

if ! [ $(getent group $3 ) ]; then
    echo " !!Error - group $3 not isset !!"
    exit
fi

if ! [ -d $1 ]; then
    echo " !!Error - not isset project dir $1 !!"
    exit
fi

if ! [ -d $2 ]; then
    echo " !!Error - not isset dir for backup $2 !!"
    exit
fi

project_dir=$1
location_back=$2
now=$(date +"%d_%m_%Y_%H")
now_str=$(date +"%d-%m-%Y %H:%M")
owner_group=$3

clear_old () {
    local now_str=$(date +"%d-%m-%Y %H:%M")

    echo " $now_str Start search old files and remove"

    if [ $# -lt 3 ]
    then
        echo ' Error - incorect count parameters ($1 - dir; $2 - file`s mask; $3 - count keep files)'

        echo " Commandline parameters:"
        echo $1 $2 $3 ' -> echo $1 $2 $3'

        exit
    fi

    local i=0
    local x=1
    local path=$1
    local filemask=$2
    local keep=$3

    for i in `ls -t $path/$filemask`
    do
        if [ $x -le $keep ]
        then
            ((x++))
            continue
        fi
        rm $i
        echo " Remove file - $i "
    done
}

echo " !!!! $now_str - START BUILD PROJECTS BACKUP !!!!"
for folder in $(ls $project_dir); do
    if test -e $project_dir$folder/.setting.back; then
        . $project_dir$folder/.setting.back
        if [ -n "$NAME" ]; then
            echo " ======== Start backup project $NAME ==========="
            `rm -rf /tmp/backup`
            `mkdir -p /tmp/backup/$NAME`

            if [ -n "$DB_NAME" ] && [ -n "$DB_USER" ] && [ -n "$DB_PWD" ] && [ -n "$DB_HOST" ]; then
                echo " Backup database $DB_NAME for project $NAME"
                `mysqldump -u$DB_USER -h$DB_HOST -p$DB_PWD $DB_NAME > /tmp/backup/$NAME/$DB_NAME.sql`
            fi

            `tar -czf /tmp/backup/$NAME/$NAME.tar.gz $project_dir$folder/ --exclude '.git/*'`
            `mkdir -p /$location_back/$NAME/`
            `tar -cf /$location_back/$NAME/$now.tar /tmp/backup/$NAME`

            `chown :$owner_group $location_back`
            echo "$now" > /$location_back/$NAME/.backup_flag

            echo " ======== Finish backup project $NAME ==========="
            echo " !! Clear old backups for project $NAME !!"
            clear_old /$location_back/$NAME/ *.tar 5

            unset DB_NAME
            unset DB_USER
            unset DB_PWD
            unset DB_HOST
            unset NAME
        fi
    fi
done

now_str=$(date +"%d-%m-%Y %H:%M")
echo "$now_str" > /$location_back/.backup_flag
echo " !!!! $now_str - FINISH BUILD PROJECTS BACKUP !!!!"
