# Setting-up scripts for Ubuntu 20.04

[TOC levels=1-3]: # ""

- [Setting-up scripts for Ubuntu 20.04](#setting-up-scripts-for-ubuntu-2004)
    - [Bypass GFW blocking](#bypass-gfw-blocking)
    - [Install packages needed by Linuxbrew and some others](#install-packages-needed-by-linuxbrew-and-some-others)
    - [Optional: adjusting Desktop](#optional-adjusting-desktop)
    - [Install Linuxbrew](#install-linuxbrew)
    - [Download](#download)
    - [Install packages managed by Linuxbrew](#install-packages-managed-by-linuxbrew)
    - [Packages of each language](#packages-of-each-language)
    - [Bioinformatics Apps](#bioinformatics-apps)
    - [MySQL](#mysql)
    - [Optional: dotfiles](#optional-dotfiles)
    - [Directory Organization](#directory-organization)

The whole developing environment is based on [Linuxbrew](http:s//linuxbrew.sh/). Many of the
following steps also work under macOS via [Homebrew](https://brew.sh/).

Linux specific scripts were placed in [`prepare/`](prepare).
[This repo](https://github.com/wang-q/dotfiles) contains macOS related codes.

## Bypass GFW blocking

* Query the IP address on [ipaddress](https://www.ipaddress.com/) for

    * `raw.githubusercontent.com`
    * `gist.githubusercontent.com`
    * `camo.githubusercontent.com`
    * `user-images.githubusercontent.com`

* Add them to `/etc/hosts` or `C:\Windows\System32\drivers\etc\hosts`

## Install packages needed by Linuxbrew and some others

```shell script
echo "==> When some packages went wrong, check http://mirrors.ustc.edu.cn/ubuntu/ for updating status."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/1-apt.sh)"

```

## Optional: adjusting Desktop

In GUI desktop, disable auto updates: `Software & updates -> Updates`,
set `Automatically check for updates` to `Never`, untick all checkboxes, click close and click close
again.

```shell script
# Removes nautilus bookmarks and disables lock screen
echo '==> `Ctrl+Alt+T` to start a GUI terminal'
curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/2-gnome.sh |
    bash

```

## Install Linuxbrew

使用清华的[镜像](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/).

```shell
# curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O
# bash install.sh
#
# (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/wangq/.bashrc

echo "==> Tuna mirrors of Homebrew/Linuxbrew"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
/bin/bash brew-install/install.sh

rm -rf brew-install

test -d ~/.linuxbrew && PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

if grep -q -i Homebrew $HOME/.bashrc; then
    echo "==> .bashrc already contains Homebrew"
else
    echo "==> Update .bashrc"

    echo >> $HOME/.bashrc
    echo '# Homebrew' >> $HOME/.bashrc
    echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >> $HOME/.bashrc
    echo "export MANPATH='$(brew --prefix)/share/man'":'"$MANPATH"' >> $HOME/.bashrc
    echo "export INFOPATH='$(brew --prefix)/share/info'":'"$INFOPATH"' >> $HOME/.bashrc
    echo "export HOMEBREW_NO_ANALYTICS=1" >> $HOME/.bashrc
    echo "export HOMEBREW_NO_AUTO_UPDATE=1" >> $HOME/.bashrc
    echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"' >> $HOME/.bashrc
    echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"' >> $HOME/.bashrc
    echo 'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"' >> $HOME/.bashrc
    echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source $HOME/.bashrc

```

## Download

Fill `$HOME/bin`, `$HOME/share` and `$HOME/Scripts`.

```shell script
curl -LO https://raw.githubusercontent.com/wang-q/dotfiles/master/download.sh
bash download.sh
source $HOME/.bashrc

```

## Install packages managed by Linuxbrew

Packages include:

* Programming languages: Perl, Python, R, Java, Lua and Node.js
* Some generalized tools

```shell script
bash $HOME/Scripts/dotfiles/brew.sh
source $HOME/.bashrc

```

Attentions:

* `r` and `gnuplot` have a lot of dependencies. Just be patient.

* Sometimes there are no binary packages; compiling from source codes may take extra time.

## Packages of each language

```shell script
bash $HOME/Scripts/dotfiles/perl/install.sh

bash $HOME/Scripts/dotfiles/python/install.sh

bash $HOME/Scripts/dotfiles/r/install.sh

# Optional
# bash $HOME/Scripts/dotfiles/rust/install.sh

```

## Bioinformatics Apps

```shell script
bash $HOME/Scripts/dotfiles/genomics.sh

bash $HOME/Scripts/dotfiles/perl/ensembl.sh

# Optional: huge apps
# bash $HOME/Scripts/dotfiles/others.sh

```

## Optional: dotfiles

```shell script
bash $HOME/Scripts/dotfiles/install.sh
source $HOME/.bashrc

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

```

Edit `.gitconfig` to your own manually.

## Directory Organization

* [`packer/`](packer): Scripts for building an Ubuntu base box

* [`prepare/`](prepare): Scripts for setting-up Ubuntu

* [`prepare/Vagrant.md`](prepare/Vagrant.md): Vagrant managed box

* [`prepare/CentOS.md`](prepare/CentOS.md): Steps for building CentOS 7 VMs

