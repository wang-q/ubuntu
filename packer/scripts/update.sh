#!/usr/bin/env bash

echo "==> Switch to the USTC mirror"

# https://lug.ustc.edu.cn/wiki/mirrors/help/ubuntu
cat <<EOF > list.tmp
deb https://mirrors.nju.edu.cn/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.nju.edu.cn/ubuntu/ focal main restricted universe multiverse

deb https://mirrors.nju.edu.cn/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.nju.edu.cn/ubuntu/ focal-security main restricted universe multiverse

deb https://mirrors.nju.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.nju.edu.cn/ubuntu/ focal-updates main restricted universe multiverse

deb https://mirrors.nju.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.nju.edu.cn/ubuntu/ focal-backports main restricted universe multiverse

## Not recommended
# deb https://mirrors.nju.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.nju.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse

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
