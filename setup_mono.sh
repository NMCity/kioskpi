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


function install_mono {
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
        echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list
        
        echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list

        if [[$(grep -E 'VERSION=' /etc/os-release) == *"jessie"*]]; then
                echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list
        else
                echo "deb http://download.mono-project.com/repo/debian wheezy-libtiff-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list
        fi

        sudo apt-get update

        # The package mono-devel should be installed to compile code.
        check_for_package "mono-devel"
        # The package mono-complete should be installed to install everything - this should cover most cases of “assembly not found” errors.
        check_for_package "mono-complete"
        # The package referenceassemblies-pcl should be installed for PCL compilation support 
        # - this will resolve most cases of “Framework not installed: .NETPortable” errors during software compilation.
        check_for_package "referenceassemblies-pcl" 
        # The package ca-certificates-mono should be installed to get SSL certificates for HTTPS connections.
        # Install this package if you run into trouble making HTTPS connections.
        check_for_package "ca-certificates-mono"
        # The module mono-xsp4 should be installed for running ASP.NET applications.
        #check_for_package "mono-xsp4"   
}


# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

install_mono