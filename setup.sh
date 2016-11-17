#!/bin/bash

#Setup script for setup minimal Kioskmode


#Paramerters

# Window Manager: Examples are "dwm", "openbox", ...
window_manger="openbox"
# Switches: yes or no
install_mono="yes"
install_winformtest="yes"
#Command run in window manager 
execution_command="mono /home/pi/WinformsTest/WinFormsTest/bin/Debug/WinFormsTest.exe"



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
        echo -e "\e[1;91mInstall Mono: $install_mono\e[0m"
        if [[ $install_mono == *"y"* ]];then
                if [[ -r setup_mono.sh ]]; then
                        echo -e "\e[1;91mFound Mono Setup Script\e[0m"
                        if [[ -x setup_mono.sh ]]; then 
                                ./setup_mono.sh
                        else
                                bash ./setup_mono.sh
                        fi
                else
                        echo -e "\e[1;91mMono Setup Script was not found ... skip install mono\e[0m"
                fi
        fi
}

function install_mono_Winform_test {
        echo -e "\e[1;91mInstall WinformsTest Application: $install_winformtest\e[0m"
        if [[ $install_winformtest == *"y"* ]];then
                if [[ -r setup_winforms.sh ]]; then
                        echo -e "\e[1;91mFound Winforms Setup Script\e[0m"
                        if [[ -x setup_winforms.sh ]]; then 
                                ./setup_winforms.sh
                        else 
                                bash ./setup_winforms.sh
                        fi
                else
                        echo -e "\e[1;91mWinforms Setup Script was not found ... skip install mono\e[0m"
                fi
        fi
}

function install_auto_login {
        echo -e "\e[1;91mInstall auto login for pi\e[0m"
        if [[ -r /etc/systemd/system/getty@tty1.service.d/autologin.conf ]]; then
                echo -e "\e[1;91mOld /etc/systemd/system/getty@tty1.service.d/autologin.conf files was deleted\e[0m"
                rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
        fi
        touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
        echo "[Service]" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
        echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
        echo "ExecStart=-/sbin/agetty --autologin pi --noclear %I 38400 linux" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
}

function install_auto_load_openbox {
        echo -e "\e[1;91mInstall auto load $window_manger\e[0m"
        if [[ $window_manger == "openbox" ]]; then
                if [[ -r /etc/rc.local ]]; then
                        echo -e "\e[1;91mOld /etc/rc.local files was deleted\e[0m"
                        rm /etc/rc.local
                fi                
                touch /etc/rc.local
                echo "#!/bin/sh -e" >> /etc/rc.local
                echo "#" >> /etc/rc.local
                echo "# rc.local" >> /etc/rc.local
                echo "#" >> /etc/rc.local
                echo "# This script is executed at the end of each multiuser runlevel." >> /etc/rc.local
                echo "# Make sure that the script will "exit 0" on success or any other" >> /etc/rc.local
                echo "# value on error." >> /etc/rc.local
                echo "#" >> /etc/rc.local
                echo "# In order to enable or disable this script just change the execution" >> /etc/rc.local
                echo "# bits." >> /etc/rc.local
                echo "#" >> /etc/rc.local
                echo "# By default this script does nothing." >> /etc/rc.local
                echo "" >> /etc/rc.local
                echo "# Print the IP address" >> /etc/rc.local
                echo "_IP=$(hostname -I) || true" >> /etc/rc.local
                echo "if [ "$_IP" ]; then" >> /etc/rc.local
                echo "  printf 'My IP address is %s\n' '$_IP'" >> /etc/rc.local
                echo "fi" >> /etc/rc.local
                echo "" >> /etc/rc.local
                echo "sudo -u pi xinit /usr/bin/openbox&" >> /etc/rc.local
                echo "export DISPLAY=:0" >> /etc/rc.local
                echo "sudo -u pi $execution_command" >> /etc/rc.local
                echo "" >> /etc/rc.local
                echo "exit 0" >> /etc/rc.local
                echo "" >> /etc/rc.local

                chmod +x /etc/rc.local

                echo -e "\e[1;91m$window_manger now loads on boot\e[0m"
           

                if [[ -r /etc/X11/Xwrapper.config ]]; then
                        echo -e "\e[1;91mOld /etc/X11/Xwrapper.config files was deleted\e[0m"
                        rm /etc/X11/Xwrapper.config
                fi                
                touch /etc/X11/Xwrapper.config

                echo "# Xwrapper.config (Debian X Window System server wrapper configuration file)" >> /etc/X11/Xwrapper.config
                echo "#" >> /etc/X11/Xwrapper.config
                echo "# This file was generated by the post-installation script of the x11-common" >> /etc/X11/Xwrapper.config
                echo "# package using values from the debconf database." >> /etc/X11/Xwrapper.config
                echo "#" >> /etc/X11/Xwrapper.config
                echo "# See the Xwrapper.config(5) manual page for more information." >> /etc/X11/Xwrapper.config
                echo "#" >> /etc/X11/Xwrapper.config
                echo "# This file is automatically updated on upgrades of the x11-common package" >> /etc/X11/Xwrapper.config
                echo "# *only* if it has not been modified since the last upgrade of that package." >> /etc/X11/Xwrapper.config
                echo "#" >> /etc/X11/Xwrapper.config
                echo "# If you have edited this file but would like it to be automatically updated" >> /etc/X11/Xwrapper.config
                echo "# again, run the following command as root:" >> /etc/X11/Xwrapper.config
                echo "#   dpkg-reconfigure x11-common" >> /etc/X11/Xwrapper.config
                echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config
                
                echo -e "\e[1;91m X Window Config was Set to anybody\e[0m"
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
install_mono_Winform_test
install_auto_login
install_auto_load_openbox

reboot