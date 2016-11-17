#!/bin/bash

#Setup script for setup minimal Kioskmode


#Paramerters

# Window Manager: Examples are "dwm", "openbox", ...
window_manger="dmw"
# Install Mono: yes or no
install_mono="yes"



#Functions

function update_apt {
        echo -e "\e[1;91mUpdate Packages\e[0m"
        apt-get update
}

function system_upgrade {
        echo -e "\e[1;91mUpgrade System\e[0m"
        apt-get dist-upgrade --yes
}

function check_platform {
        PLATFORM="$(grep -E 'Hardware' /proc/cpuinfo | awk '{print $3}')"

        case $PLATFORM in
        "BCM2709")
                echo "This is a Raspberry Pi 2 or 3"
                ;;
        "BCM2708")
                echo "This is a Raspberry Pi A, B, B+ or Zero"
                ;;
        "sun7i")
                echo "This is a A20 device"
                ;;
        *)
                echo "Unknown System maybe not supported"
                ;;
        esac
}

function check_for_package {
        check="$(dpkg-query -W -f='${Status} ${Version}\n' $1)"
        version="$(echo "$check" | awk '{print $4}' )"
        if [[ $check == *"ok"* ]]; then
                echo -e "\e[1;91m$1 \e[0mis installed with version: $version -- installation is skiped"
        else
                echo -e "install \e[1;91m$1\e[0m: ..."
                apt-get install --yes $1
        fi
}

function install_min_x {
        check_for_package "xserver-xorg"
        check_for_package "xinit"
        check_for_package "xserver-xorg-video-fbdev"
}

function install_window_manger {
        check_for_package "$window_manger"
}

function install_mono {
        if [[ -r setup_mono.sh ]]; then
                echo -e "\e[1;91mFound Mono Setup Script\e[0m"
                if [[ -x setup_mono.sh ]]; then 
                        setup_mono.sh
                else
                       echo -e "\e[1;91mMono Setup Script was not executable ... try to set\e[0m"
                       chmod +x setup_mono.sh 
                       setup_mono.sh
                fi
        else
                echo -e "\e[1;91mMono Setup Script was not found ... skip install mono\e[0m"
        fi
}


# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

check_platform

update_apt
system_upgrade
install_min_x
install_window_manger
install_mono

