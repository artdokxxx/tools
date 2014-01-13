#!/bin/bash
# --------------------------------------
#
#    Title: Script for auto commit projects in DCVS
#    Author: Artem Leontiev [aleontiev/artdokxxx]
#
#     Name: commit_dcvs
#     File: commit_dcvs
#     Created: January 13, 2014
#
# --------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
CLEAR_COLOR='\033[0;0m'
bold=`tput bold`
normal=`tput sgr0`


echo -e "\n"

if [ $# -lt 1 ]
then
    echo ' Error - incorect count parameters ($1 - projects dir; $2 - author)'

    echo " Commandline parameters:"
    echo $1' -> echo $1'

    exit
fi

if [ -n "$2" ]
then
    ci_author="$2"
else
    ci_author="Auto commit <admin@example.com>"
fi

if ! [ -d $1 ]; then
    echo " !!Error - not isset project dir $1 !!"
    exit
fi

project_dir=$1
now_str=$(date +"%d-%m-%Y %H:%M")

echo " !!!! $now_str - START AUTO COMMIT DCVS !!!!"
for folder in $(ls $project_dir); do
    if [ -d $project_dir/$folder/.git ]; then
        cd $project_dir/$folder
        count_untracked_file=$(git status -s | wc -l)
        if [ $count_untracked_file -gt 0 ]; then
            now_ci_str=$(date +"%d-%m-%Y")
            echo -e "Found changset ${GREEN}$project_dir/$folder/ -> ${RED}$count_untracked_file ${CLEAR_COLOR}"
            git add . -A
            git commit -m "Auto-commit changset's [$now_ci_str]" --author="$ci_author"

            count_untracked_file=$(git status -s | wc -l)
            if [ $count_untracked_file -gt 0 ]; then
                echo -e "${RED} !!! [ERR $count_untracked_file] Auto commit failed !!! ${CLEAR_COLOR}"
            else
                echo -e "${GREEN} !!! [OK] Success auto commit !!! ${CLEAR_COLOR}"
            fi
        else
            echo -e "Not found changset ${CYAN}$project_dir/$folder/ -> ${bold}${CYAN}$count_untracked_file ${CLEAR_COLOR}${normal}"
        fi
    fi
done

now_str=$(date +"%d-%m-%Y %H:%M")
echo " !!!! $now_str - FINISH AUTO COMMIT DCVS !!!!"
echo -e "\n"
