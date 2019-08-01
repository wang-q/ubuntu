# Instructions for building a Vagrant box

## Software versions

* Ubuntu: 18.04.2
* VirtualBox: 6.0.10
* Vagrant: 2.2.5
* Packer: v1.4.1

## Build Ubuntu base box `mybionic.box` with packer from .iso

See [`packer/`](../packer) and [`packer/README.md`](../packer/README.md).

## Vagrantfiles for setting up VM

* `./Vagrantfile`

## VirtualBox VM building steps

This build starts from `mybionic.box`.

When internet connection is OK and most source files were downloaded previously, the building
process costs about 100 minutes.

* STEPS on host machine

```bash
# destroy old builds
cd $HOME/Scripts/ubuntu/prepare
vagrant destroy -f
rm -fr .vagrant/

echo "You might need remove orphan disks first. VirtualBox->File->Virtual Media Manager."

# start
cd $HOME/Scripts/ubuntu/prepare
vagrant up --provider virtualbox
VBoxManage controlvm bionic setvideomodehint 1280 800 32 # Change resolution

vagrant ssh

```

* STEPS inside VM

Same as [Standalone Ubuntu](./README.md).

* Create `bionic.ova`

```bash
cd $HOME/Scripts/ubuntu/prepare
vagrant halt

VBoxManage export bionic -o bionic.ova

mv bionic.ova ../vm
du -hs ../vm/*

```



