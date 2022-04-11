# Instructions for getting an Ubuntu base box

I got tired of guessing the parameters of other people's boxes. So just copy and paste code from
other repositories to get my own packer template.

If the internet connection is OK, the building process costs about 30 minutes.

```shell
cd ~/Scripts/ubuntu/packer

aria2c -c https://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/ubuntu-20.04.1-legacy-server-amd64.iso
aria2c -c https://download.virtualbox.org/virtualbox/6.1.32/VBoxGuestAdditions_6.1.32.iso

# Checksums for template.json
openssl md5 ubuntu-20.04.1-legacy-server-amd64.iso
openssl sha256 VBoxGuestAdditions_6.1.32.iso

# build
cd ~/Scripts/ubuntu/packer

packer build template.json
mv myfocal.box ../vm
du -hs ../vm/*

# Add base box
vagrant box add myfocal ../vm/myfocal.box --force

```

Rules:

* Keep it as simple as possible in `http/preseed.cfg`
* `apt-get` from a nearby mirror
* Upgrade the kernel
* Install Ubuntu desktop
* VirtualBox only. for other platforms, use boxcutter's atlas boxes
* Install the VirtualBox guest additions during the build phase
* `vagrant:vagrant` as username:password
* Leave the DVD there. Remove it later via vagrant
