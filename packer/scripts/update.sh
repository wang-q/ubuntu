#!/usr/bin/env bash

echo "==> Switch to the USTC mirror"

# https://lug.ustc.edu.cn/wiki/mirrors/help/ubuntu
cat <<EOF > list.tmp
# USTC MIRRORS
deb https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb-src https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse

deb https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb-src https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse

deb https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb-src https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse

deb https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb-src https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse

## Not recommended
# deb https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src https://ipv4.mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse

EOF

if [ ! -e /etc/apt/sources.list.bak ]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
fi
mv list.tmp /etc/apt/sources.list

echo "==> Disabling the release upgrader"
sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades

echo "==> Disabling periodic apt upgrades"
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

echo "==> Updating list of repositories"
apt-get -y update

echo "==> Performing dist-upgrade (all packages and kernel)"
apt-get -y dist-upgrade --force-yes

echo "==> Restore original sources.list"
if [ -e /etc/apt/sources.list.bak ]; then
    rm /etc/apt/sources.list
    mv /etc/apt/sources.list.bak /etc/apt/sources.list
fi

reboot
sleep 60
