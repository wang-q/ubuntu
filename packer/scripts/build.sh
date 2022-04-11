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
#wget --no-check-certificate \
#    'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' \
#    -O /home/vagrant/.ssh/authorized_keys

cat <<EOF >> /home/vagrant/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key

EOF

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
mount -o loop /home/vagrant/VBoxGuestAdditions.iso /mnt
echo "yes" | sh /mnt/VBoxLinuxAdditions.run --nox11 # type yes

/etc/init.d/vboxadd setup
update-rc.d vboxadd defaults

rm /home/vagrant/VBoxGuestAdditions.iso

echo "==> Check that Guest Editions are installed"
lsmod | grep vboxguest
