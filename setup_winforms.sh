#!/bin/bash

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

function install_git {
        check_for_package "git"
}

function install_Winforms {
        if [[ -d /home/pi/WinformsTest ]]; then
                echo -e "\e[1;91mUpdate Winforms\e[0m"
                cd /home/pi/WinformsTest
                git pull
                xbuild WinformsTest.sln /t:Rebuild
                cd ..
                chown -R pi:pi WinformsTest
        else
                echo -e "\e[1;91mInstall Winforms\e[0m"
                install_git
                cd /home/pi/
                git clone https://github.com/NMCity/WinformsTest.git
                cd ~/WinformsTest
                xbuild WinformsTest.sln /t:Rebuild
                cd..
                chown -R pi:pi WinformsTest
        fi
}

install_Winforms