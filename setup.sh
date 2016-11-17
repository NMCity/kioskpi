#!/bin/bash

#Setup script for setup minimal Kioskmode

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

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

check_platform

update_apt
system_upgrade
install_min_x

