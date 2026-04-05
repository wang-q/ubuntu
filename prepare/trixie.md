# Debiand 13

## Distro

https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro


```powershell
# Pull the Debian 13 image from Docker Hub
docker pull debian:13

# Run a temporary Debian 13 container and execute 'ls /' to list the root directory contents
docker run -t --name wsl_export debian:13 ls /

# Create a directory to store the exported container file
mkdir -p $HOME\VM

# Export the specified container and save it as a tar file
docker export wsl_export > $HOME\VM\trixie.tar

docker rm wsl_export

```

Import the trixie.tar file to WSL

```powershell
# Import the exported container tar file into WSL, creating a WSL instance named trixie
wsl --import trixie $HOME\VM\trixie $HOME\VM\trixie.tar

# List all WSL instances and their version information
wsl -l -v

# Start the WSL instance named trixie
wsl -d trixie

# To refresh the wsl.conf configuration file (if needed)
# Terminate the trixie instance to achieve this
# wsl --terminate trixie

# wsl --unregister trixie

```

## Base system

As `root`

```bash
apt-get -y update
apt-get -y upgrade

apt-get -y install sudo vim
# ip ping ifconfig ps
apt-get -y install iproute2 iputils-ping net-tools procps

# locales
apt-get -y install locales
locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# systemd
apt-get -y install systemd systemd-sysv
```

## Add user

As `root`

```bash
myUsername=wangq

useradd -s /bin/bash -m -G sudo $myUsername

echo -e "[user]\ndefault=$myUsername" >> /etc/wsl.conf
echo -e "[interop]\nappendWindowsPath=false" >> /etc/wsl.conf

passwd $myUsername

# systemd
echo -e "[boot]\nsystemd=true" >> /etc/wsl.conf

```

Restart the trixie instance

```bash
# Check if systemd is running, pid 1
ps -p 1 -o comm=

```

## ssh

```bash
sudo apt -y update
sudo apt -y upgrade

sudo apt -y install ssh ufw

sudo systemctl start ssh
sudo systemctl enable ssh
sudo systemctl status ssh

sudo ufw allow ssh
sudo ufw enable

```

## Flatpak

```bash
# flatpak
sudo apt -y install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
```

## Python

```bash
cbp install python3.11
cbp install uv

uv pip install --system -U "docling"
uv pip install --system -U "mineru[all]"
uv pip install --system -U 'markitdown[all]'

uv pip install --system -U "opendataloader-pdf[hybrid]"
```
