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
# --user can't download wine and dxvk
sudo flatpak install --system org.gnome.Platform//45
sudo flatpak install --system launcher.moe moe.launcher.the-honkers-railway-launcher

flatpak install --user flathub io.mpv.Mpv

flatpak install --user flathub io.github.shiftey.Desktop
flatpak install --user flathub com.visualstudio.code

# Remove unused packages
flatpak uninstall --unused

# waydroid
sudo apt install curl ca-certificates -y
curl -s https://repo.waydro.id | sudo bash
sudo apt install waydroid -y

waydroid prop set persist.waydroid.width "1280"
waydroid prop set persist.waydroid.height "720"
waydroid prop set persist.waydroid.fake_wifi '*'

sudo waydroid container restart

# remove waydroid default app
sudo waydroid shell
pm uninstall --user 0 com.android.calculator2
pm uninstall --user 0 org.lineageos.etar
pm uninstall --user 0 com.android.gallery3d
pm uninstall --user 0 org.lineageos.eleven
pm uninstall --user 0 org.lineageos.recorder
pm uninstall --user 0 com.android.contacts

# firewall
sudo waydroid session stop
sudo waydroid container stop

sudo ufw allow 67
sudo ufw allow 53
sudo ufw default allow FORWARD

# arm translate
sudo apt install lzip

git clone https://github.com/casualsnek/waydroid_script
cd waydroid_script
python3 -m venv venv
venv/bin/pip install -r requirements.txt
sudo venv/bin/python3 main.py install libndk
sudo venv/bin/python3 main.py install libhoudini

# go to www.apkmirror.com

waydroid app install ~/Download/com.

```
