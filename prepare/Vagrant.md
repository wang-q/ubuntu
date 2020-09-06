# Instructions for building a Vagrant box

## Software versions

* Ubuntu: 20.04
* VirtualBox: 6.1.6
* Vagrant: 2.2.7
* Packer: v1.5.5

## Build Ubuntu base box `myfocal.box` with packer from .iso

See [`packer/`](../packer) and [`packer/README.md`](../packer/README.md).

## Vagrantfiles for setting up VM

* `./Vagrantfile`

## VirtualBox VM building steps

This build starts from `myfocal.box`.

When internet connection is OK and most source files were downloaded previously, the building
process costs about 100 minutes.

* STEPS on host machine

```shell script
# destroy old builds
cd $HOME/Scripts/ubuntu/prepare
vagrant destroy -f
rm -fr .vagrant/

echo "You might need remove orphan disks first. VirtualBox->File->Virtual Media Manager."

# start
cd $HOME/Scripts/ubuntu/prepare
vagrant up --provider virtualbox

# Optional
# VBoxManage controlvm focal setvideomodehint 1280 960 32

vagrant ssh

```

* STEPS inside VM

Now you have a GUI desktop.

Username and password are `vagrant` and `vagrant`, respectively.

The other steps are the same as [Standalone Ubuntu](../README.md).

* Whiteout disks

```shell script
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/90-cleanup-user.sh)"
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/91-cleanup.sh)"

```

* Create `focal.ova`

```shell script
cd $HOME/Scripts/ubuntu/prepare
vagrant halt

VBoxManage export focal -o focal.ova

mv focal.ova ../vm
du -hs ../vm/*

```

| name        |   size |
|:------------|-------:|
| focal.ova   | 4.0 GB |
| myfocal.box | 1.5 GB |

