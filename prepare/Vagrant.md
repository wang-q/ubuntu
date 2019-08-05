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

vagrant ssh

# Change resolution after logged in
# VBoxManage controlvm bionic setvideomodehint 1280 960 32

```

* STEPS inside VM

Now you have a GUI desktop.

Username and password are `vagrant` and `vagrant`, respectively.

The other steps are the same as [Standalone Ubuntu](../README.md).

* Whiteout disks

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/90-cleanup-user.sh)"
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/91-cleanup.sh)"

```

* Create `bionic.ova`

```bash
cd $HOME/Scripts/ubuntu/prepare
vagrant halt

VBoxManage export bionic -o bionic.ova

mv bionic.ova ../vm
du -hs ../vm/*

```

| name         |   size |
|:-------------|-------:|
| bionic.ova   | 4.0 GB |
| mybionic.box | 1.5 GB |
