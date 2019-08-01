#!/usr/bin/env bash

echo "==> Switch to the USTC mirror"

# https://lug.ustc.edu.cn/wiki/mirrors/help/ubuntu
# https://mirrors.ustc.edu.cn/repogen/
cat <<EOF > list.tmp
# USTC MIRRORS
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse

## Not recommended
# deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse

EOF

if [ ! -e /etc/apt/sources.list.bak ]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
fi
mv list.tmp /etc/apt/sources.list

echo "==> Installing build-essential"
apt-get update -y
apt-get upgrade -y

# needed by linuxbrew
apt-get install -y build-essential module-assistant curl git m4 ruby texinfo
apt-get install -y aptitude

# needed by virtualbox guest additions
apt-get install -y linux-headers-$(uname -r)

#----------------------------#
# desktop
#----------------------------#

echo "==> Installing Ubunutu desktop"

apt-get install -y ubuntu-desktop
#apt-get install -y --no-install-recommends ubuntu-desktop
#apt-get install -y gnome-terminal gnome-system-monitor gedit firefox xrdp
#apt-get install -y unity-lens-applications unity-lens-files
#apt-get install -y --no-install-recommends indicator-applet-complete indicator-session

# GUI default login
mkdir -p /etc/lightdm
mkdir -p /etc/gdm

tee -a /etc/gdm/custom.conf <<EOF
[daemon]
# Enabling automatic login
AutomaticLoginEnable=True
AutomaticLoginEnable=vagrant

EOF

tee -a /etc/lightdm/lightdm.conf <<EOF
[SeatDefaults]
# Enabling automatic login
autologin-user=vagrant
autologin-user-timeout=0

EOF

echo "==> Disabling screen blanking"
mkdir -p /etc/xdg/autostart
tee -a /etc/xdg/autostart/nodpms.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=xset -dpms s off s noblank s 0 0 s noexpose
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=nodpms
Name=nodpms
Comment[en_US]=
Comment=

EOF

# Fix gnome-terminal
# https://askubuntu.com/questions/608330/problem-with-gnome-terminal-on-gnome-3-12-2
tee /etc/default/locale <<EOF
LANG=en_US.UTF-8
LANGUAGE="en_US:"

EOF

echo "==> Restore original sources.list"
if [ -e /etc/apt/sources.list.bak ];
then
    rm /etc/apt/sources.list
    mv /etc/apt/sources.list.bak /etc/apt/sources.list
fi

reboot
sleep 60
