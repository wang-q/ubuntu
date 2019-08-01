#!/bin/bash -eux

#----------------------------#
# sshd
#----------------------------#

echo "UseDNS no" >> /etc/ssh/sshd_config

#----------------------------#
# vagrant
#----------------------------#

# base
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%sudo  ALL=(ALL:ALL) ALL/%sudo  ALL=NOPASSWD:ALL/g' /etc/sudoers

# vagrant user
date > /etc/vagrant_box_build_time

mkdir /home/vagrant/.ssh
wget --no-check-certificate \
    'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# Fix stdin not being a tty
if grep -q -E "^mesg n$" /root/.profile && sed -i "s/^mesg n$/tty -s \\&\\& mesg n/g" /root/.profile; then
    echo "==> Fixed stdin not being a tty."
fi

#----------------------------#
# virtualbox
#----------------------------#
echo "==> Install VirtualBox guest additions"
#apt-get install -y virtualbox-guest-utils virtualbox-guest-additions-iso

m-a prepare

# Packer will automatically download the proper guest additions.
cd $HOME
mount -o loop VBoxGuestAdditions.iso /mnt
echo "yes" | sh /mnt/VBoxLinuxAdditions.run --nox11 # type yes

/etc/init.d/vboxadd setup
update-rc.d vboxadd defaults

rm $HOME/VBoxGuestAdditions.iso

echo "==> Check that Guest Editions are installed"
lsmod | grep vboxguest
