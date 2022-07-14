# JuNest

https://github.com/fsquillace/junest

```shell
## CentOS had no user namespaces. We can't use `ns`, proot is fine.
#https://github.com/proot-me/proot/releases/download/v5.3.0/proot-v5.3.0-x86_64-static
#
#mv proot-v* ~/bin/proot
#chmod +x ~/bin/proot

git clone https://github.com/fsquillace/junest.git ~/.local/share/junest
export PATH=~/.local/share/junest/bin:$PATH
export PATH="$PATH:~/.junest/usr/bin_wrappers"

junest setup

# Installing JuNest...
# JuNest installed successfully!

# Default mirror URL set to: https://mirror.rackspace.com/archlinux/$repo/os/$arch
# You can change the pacman mirror URL in /etc/pacman.d/mirrorlist according to your location:
#     $EDITOR /share/home/wangq/.junest/etc/pacman.d/mirrorlist

# Remember to refresh the package databases from the server:
#     pacman -Syy

junest -f pacman -Syy

# CentOS 7
#FATAL: kernel too old

```
