#!/bin/bash
# --------------------------------------
#
#    Title: Auto set permission
#    Author: Artem Leontiev [aleontiev/artdokxxx]
#
#     Name:
#     File: auto_permission
#     Created: January 14, 2013
#
# --------------------------------------


RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
CLEAR_COLOR='\033[0;0m'
bold=`tput bold`
normal=`tput sgr0`
now_str=$(date +"%d-%m-%Y %H:%M")

if [ "$1" = "--help" ] || ! [ -n "$1" ];
then
    echo -e "\n"
    echo "Script for auto set permission"
    echo -e "Author: ${CYAN}Artem Leontiev${CLEAR_COLOR} [aleontiev/artdokxxx]"
    echo -e "${CYAN}Parameters:${CLEAR_COLOR}"
    echo "1) [Required] Projects dir"
    echo "2) User owner"
    echo "3) Group owner"
    echo -e "4) Chmod mode \n"
    echo -e "${CYAN}Example${CLEAR_COLOR}: "
    echo -e "- ${CYAN}Use config file in project dir${CLEAR_COLOR} (project_dir/.project.setting): auto_permission /var/www/"
    echo -e "- ${CYAN}Use set option in command line: ${CLEAR_COLOR} auto_permission /var/www/ www-data www 775"
    echo -e "\n"

    exit 1
fi

echo " !!!! $now_str - START AUTO CHECK AND SET PERMISSION FOR DIR !!!!"
if [ -n "$1" ]; then
    if [ -d $1 ]; then
        projects_dir=$1
        echo -e "${GREEN} !!! [OK] USE PROJECT DIR - $1 !!! ${CLEAR_COLOR}";
    else
        echo -e "${RED} !!! [ERR] NOT ISSET DIR - $1 !!! ${CLEAR_COLOR}";
        exit 0
    fi
else
    echo -e "${RED} !!! [ERR] SPECIFY THE PATH TO THE PROJECT  - $1 !!! ${CLEAR_COLOR}";
    exit 0;
fi

if [ -n "$2" ]; then
    isset_user= $(egrep -i "^$2" /etc/passwd | wc -l)
    if [$isset_user -gt 0 ]; then
        gl_user=$2
        echo -e "${GREEN} !!! [OK] USE USER - $2 !!! ${CLEAR_COLOR}";
    else
        echo -e "${RED} !!! [ERR] NOT FOUND USER - $2 !!! ${CLEAR_COLOR}";
        exit 0
    fi
fi

if [ -n "$3" ]; then
    isset_group= $(egrep -i "^$3" /etc/group | wc -l)
    if [$isset_group -gt 0 ]; then
        gl_group=$3
        echo -e "${GREEN} !!! [OK] USE GROUP - $3 !!! ${CLEAR_COLOR}";
    else
        echo -e "${RED} !!! [ERR] NOT FOUND GROUP - $3 !!! ${CLEAR_COLOR}";
        exit 0
    fi
fi

if [ -n "$4" ]; then
   if [ $4 -lt 7777 ]; then
        gl_mode=$4
        echo -e "${GREEN} !!! [OK] USE MODE - $4 !!! ${CLEAR_COLOR}";
   else
        echo -e "${RED} !!! [ERR] INCORRECT MODE PERMISSION (CHMOD) - $4 !!! ${CLEAR_COLOR}";
        exit 0
   fi
fi

for folder in $(ls $projects_dir); do
    if test -e $projects_dir/$folder/.project.setting; then
        . $projects_dir/$folder/.project.setting
        if [ -n "$gl_user" ]; then
            user=$gl_user
        else
            if [ -n "$USER_DIR" ]; then
                user=$USER_DIR
            fi
        fi

        if [ -n "$gl_group" ]; then
            group=$gl_group
        else
            if [ -n "$GROUP_DIR" ]; then
                group=$GROUP_DIR
            fi
        fi

        if [ -n "$gl_mode" ]; then
            mode=$gl_mode
        else
            if [ -n "$CHMOD_MODE" ]; then
                if [ $CHMOD_MODE -lt 7777 ]; then
                    mode=$CHMOD_MODE
                fi
            fi
        fi

        if [ -n "$user" -a -n "$group" -a -n "$mode" ]; then
            chown $user:$group $projects_dir/$folder -R
            chmod $mode $projects_dir/$folder -R

            echo -e "${GREEN} $projects_dir/$folder -> [OK] ${CLEAR_COLOR}";
        else
            echo -e "${CYAN} $projects_dir/$folder -> [SKIP] FAILED TO COLLECT ALL OPTIONS [USER - $user; GROUP - $group; CHMOD_MODE - $mode] ${CLEAR_COLOR}";
        fi
    else
        echo -e "${CYAN} $projects_dir/$folder -> [SKIP] NOT FOUND FILE $projects_dir/$folder/.project.setting ${CLEAR_COLOR}";
    fi
done

echo " !!!! $now_str - FINISH AUTO CHECK AND SET PERMISSION FOR DIR !!!!"
