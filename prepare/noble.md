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

## Disks

* `/home/wangq/data`: 2 TB SSD
* `/home/wangq/data2`: 4 TB HDD

```shell
ln -s /home/wangq/data2/Bacteria /home/wangq/data/Bacteria
ln -s /home/wangq/data2/Plants /home/wangq/data/Plants

```

## ssh

```shell
sudo apt update
sudo apt upgrade

sudo apt install ssh

sudo systemctl start ssh
sudo systemctl enable ssh
sudo systemctl status ssh

sudo ufw allow ssh
sudo ufw enable

```

## gnome remote desktop

```shell
sudo ufw allow from any to any port 3389 proto tcp
sudo ufw allow from any to any port 3390 proto tcp
sudo ufw reload

```

## R studio

```shell
sudo apt-get install gdebi-core

wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.09.1-394-amd64.deb
sudo gdebi rstudio-server-2024.09.1-394-amd64.deb

sudo rstudio-server verify-installation
# sudo apt-get remove --purge rstudio-server

wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.09.1-394-amd64.deb
sudo gdebi rstudio-2024.09.1-394-amd64.deb

```

## Clash

```shell
sudo apt  install curl

curl -LO https://github.com/libnyanpasu/clash-nyanpasu/releases/download/v1.6.1/clash-nyanpasu_1.6.1_amd64.AppImage
chmod +x clash-nyanpasu_1.6.1_amd64.AppImage
mv clash-nyanpasu_1.6.1_amd64.AppImage ~/bin


```

## Desktop

```shell
# quicklook
sudo apt install gnome-sushi

# extensions
sudo apt install gnome-shell-extension-manager gir1.2-gtop-2.0 lm-sensors

# Open the Extension Manager (installed above), search for
# * Vitals
# * Allow Locked Remote Desktop

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

flatpak install --user flathub com.tencent.WeChat

# Remove unused packages
flatpak uninstall --unused

```

## pggb

```shell
sudo apt install singularity-container

singularity version
#4.1.1

singularity pull docker://ghcr.io/pangenome/pggb:latest
mv pggb_latest.sif ~/share/

cd ~/data
git clone --recursive https://github.com/pangenome/pggb.git
cd pggb

singularity run -B ${PWD}/data:/data ~/share/pggb_latest.sif pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -n 10 -t 8 -o /data/out

```

## Waydroid

```shell
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
