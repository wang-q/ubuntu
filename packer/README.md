# Instructions for getting an Ubuntu base box

I'm tired of guessing parameters of other people's boxes. So just copy & paste codes from other
repos to get my own packer template.

If the internet connection is OK, the building process costs about 30 minutes.

```bash
cd ~/Scripts/ubuntu/packer
# cd /mnt/c/Users/wangq/Scripts/ubuntu/packer

wget -N http://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/ubuntu-20.04-legacy-server-amd64.iso
wget -N https://download.virtualbox.org/virtualbox/6.1.6/VBoxGuestAdditions_6.1.6.iso

# Checksums for template.json
openssl md5 ubuntu-20.04-legacy-server-amd64.iso
openssl sha256 VBoxGuestAdditions_6.1.6.iso

# build
cd ~/Scripts/ubuntu/packer

packer build template.json
mv myfocal.box ../vm
du -hs ../vm/*

# Add base box
vagrant box add myfocal ../vm/myfocal.box --force

```

Rules:

* Keep it as simple as possible in `http/preseed.cfg`.
* `apt-get` from nearby mirrors.
* Upgrade kernel.
* Install Ubuntu desktop without recommendations.
* VirtualBox only. For other platforms, use boxcutter's atlas boxes.
* Install VirtualBox guest additions in the building phase.
* `vagrant:vagrant` as username:password.
* Leave DVD there. Remove it by vagrant later.

