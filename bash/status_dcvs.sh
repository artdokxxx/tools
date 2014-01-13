#!/bin/bash
# --------------------------------------
#
#    Title: Script for list status repository
#    Author: Artem Leontiev [aleontiev/artdokxxx]
#
#     Name: status_dcvs
#     File: status_dcvs
#     Created: January 13, 2014
#
# --------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
CLEAR_COLOR='\033[0;0m'
bold=`tput bold`
normal=`tput sgr0`


echo -e "\n"

if [ $# -lt 1 ]
then
    echo ' Error - incorect count parameters ($1 - projects dir;)'

    echo " Commandline parameters:"
    echo $1' -> echo $1'

    exit
fi

if ! [ -d $1 ]; then
    echo " !!Error - not isset project dir $1 !!"
    exit
fi

project_dir=$1
now_str=$(date +"%d-%m-%Y %H:%M")

echo " !!!! $now_str - START SCAN STATUS DCVS !!!!"
for folder in $(ls $project_dir); do
    if [ -d $project_dir/$folder/.git ]; then
        cd $project_dir/$folder
        count_untracked_file=$(git status -s | wc -l)
        echo -e "${GREEN}$project_dir/$folder/ -> ${bold}${RED}$count_untracked_file ${CLEAR_COLOR}${normal}"
    fi
done

now_str=$(date +"%d-%m-%Y %H:%M")
echo " !!!! $now_str - START SCAN STATUS DCVS !!!!"
echo -e "\n"
