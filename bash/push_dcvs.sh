#!/bin/bash
# --------------------------------------
#
#    Title: Script for auto push in DCVS
#    Author: Artem Leontiev [aleontiev/artdokxxx]
#
#     Name: push_dcvs
#     File: push_dcvs
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

if [ $# -lt 2 ]
then
    echo ' Error - incorect count parameters ($1 - projects dir; $2 - remote[ ex. origin]; $3 - branch [ default master ])'

    echo " Commandline parameters:"
    echo $1 $2' -> echo $1 $2'

    exit 0
fi


remote=$2
if [ -n "$3" ]
then
    branch=$3
else
    branch='master'
fi

if ! [ -d $1 ]; then
    echo " !!Error - not isset project dir $1 !!"
    exit 0
fi



project_dir=$1
now_str=$(date +"%d-%m-%Y %H:%M")

echo " !!!! $now_str - START AUTO PUSH DCVS !!!!"
for folder in $(ls $project_dir); do
    if [ -d $project_dir/$folder/.git ]; then
        cd $project_dir/$folder
        isset_branch=$(git branch --list | grep $branch | wc -l)
        if ! [ $isset_branch -gt 0 ]; then
            echo -e "${RED} !!! [ERR $project_dir/$folder] Not found branch - $branch !!! ${CLEAR_COLOR}"
        else
            isset_remote=$(git remote show -n | grep $remote | wc -l)
            if ! [ $isset_remote -gt 0 ]; then
                echo -e "${RED} !!! [ERR $project_dir/$folder] Not found remote - $remote !!! ${CLEAR_COLOR}"
            else
                count_commits=$(git rev-list HEAD --not --remotes | wc -l)
                if [ $count_commits -gt 0 ]; then
                    now_ci_str=$(date +"%d-%m-%Y")
                    echo -e "Found commits for push ${GREEN}$project_dir/$folder/ -> ${RED}$count_commits ${CLEAR_COLOR}"
                    git push $remote $branch

                    count_commits=$(git rev-list HEAD --not --remotes | wc -l)
                    if [ $count_commits -gt 0 ]; then
                        echo -e "${RED} !!! [ERR] Auto push failed !!! ${CLEAR_COLOR}"
                    else
                        echo -e "${GREEN} !!! [OK] Success auto push !!! ${CLEAR_COLOR}"
                    fi
                else
                    echo -e "Not found changes for push ${CYAN}$project_dir/$folder/ -> ${bold}${CYAN}$count_commits ${CLEAR_COLOR}${normal}"
                fi
            fi
        fi
    fi
done

now_str=$(date +"%d-%m-%Y %H:%M")
echo " !!!! $now_str - FINISH AUTO PUSH DCVS !!!!"
echo -e "\n"
