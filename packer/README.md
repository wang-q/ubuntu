# Instructions for getting an Ubuntu base box

I'm tired of guessing parameters of other people's boxes. So just copy & paste codes from other
repos to get my own packer template.

When internet connection is OK, the building process costs about less than 30 minutes.

```bash
cd ~/Scripts/ubuntu/packer
# cd /mnt/c/Users/wangq/Scripts/ubuntu/packer

wget -N http://cdimage.ubuntu.com/ubuntu/releases/18.04/release/ubuntu-18.04.2-server-amd64.iso
wget -N https://download.virtualbox.org/virtualbox/6.0.10/VBoxGuestAdditions_6.0.10.iso

# Checksums for template.json
openssl md5 ubuntu-18.04.2-server-amd64.iso
openssl sha256 VBoxGuestAdditions_6.0.10.iso

# build
packer build template.json
mv mybionic.box ../vm

# Add base box
vagrant box add mybionic ../vm/mybionic.box --force

```

Rules:

* Keep it as simple as possible in `http/preseed.cfg`.
* `apt-get` from nearby mirrors.
* Upgrade kernel.
* Install Ubuntu desktop without recommends.
* VirtualBox only. For other platform, just use boxcutter's atlas boxes.
* Install VirtualBox guest additions in building phase.
* `vagrant:vagrant` as username:password.
* Leave DVD there. Remove it by vagrant later.
