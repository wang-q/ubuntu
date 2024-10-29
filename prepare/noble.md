# Ubuntu 24.04

## Distro

https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro


```powershell
# Pull the Ubuntu 24.04 image from Docker Hub
docker pull ubuntu:24.04

# Run a temporary Ubuntu 24.04 container and execute 'ls /' to list the root directory contents
docker run -t --name wsl_export ubuntu:24.04 ls /

# Create a directory to store the exported container file
mkdir -p d:\VM

# Export the specified container and save it as a tar file
docker export wsl_export > d:\VM\noble.tar

docker rm wsl_export

# Import the exported container tar file into WSL, creating a WSL instance named noble
wsl --import noble d:\VM\noble d:\VM\noble.tar
# wsl --import noble $HOME\VM\noble $HOME\VM\noble.tar

# List all WSL instances and their version information
wsl -l -v

# Start the WSL instance named noble
wsl -d noble

# To refresh the wsl.conf configuration file (if needed)
# Terminate the noble instance to achieve this
# wsl --terminate noble

# wsl --unregister noble

```

## Base system

As `root`

```shell
apt-get -y update
apt-get -y upgrade

apt-get -y install sudo vim
# ip ping
apt-get -y install iproute2 iputils-ping

```

## Add user

As `root`

```shell
myUsername=wangq

useradd -s /bin/bash -m -G sudo $myUsername

echo -e "[user]\ndefault=$myUsername" >> /etc/wsl.conf
echo -e "[interop]\nappendWindowsPath=false" >> /etc/wsl.conf

passwd $myUsername

```

```shell
librsvg2-bin libudunits2-dev udunits-bin

```


## Desktop

```shell
# quicklook
sudo apt install gnome-sushi

# vitals
sudo apt install gnome-shell-extension-manager gir1.2-gtop-2.0 lm-sensors
# Open the Extension Manager (installed above), search for Vitals and click Install

# flatpak
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# railway
flatpak remote-add --if-not-exists --user launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo
flatpak install org.gnome.Platform//45
flatpak install launcher.moe moe.launcher.the-honkers-railway-launcher

flatpak install --user flathub io.mpv.Mpv

flatpak install --user flathub io.github.shiftey.Desktop
flatpak install --user flathub com.visualstudio.code

# Remove unused packages
flatpak uninstall --unused

```
