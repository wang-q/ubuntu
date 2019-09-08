# Setting-up scripts for Ubuntu 18.04

[TOC levels=1-3]: # " "
- [Setting-up scripts for Ubuntu 18.04](#setting-up-scripts-for-ubuntu-1804)
    - [Install packages needed by Linuxbrew and some others](#install-packages-needed-by-linuxbrew-and-some-others)
    - [Optional: adjusting Desktop](#optional-adjusting-desktop)
    - [Install Linuxbrew](#install-linuxbrew)
    - [Download](#download)
    - [Install packages managed by Linuxbrew](#install-packages-managed-by-linuxbrew)
    - [Packages of each languages](#packages-of-each-languages)
    - [Bioinformatics Apps](#bioinformatics-apps)
    - [MySQL](#mysql)
    - [Optional: dotfiles](#optional-dotfiles)
    - [Directory Organization](#directory-organization)


The whole developing environment is based on [Linuxbrew](http:s//linuxbrew.sh/). Many of the
following steps also works under macOS via [Homebrew](https://brew.sh/).

Linux specific scripts were placed in [`prepare/`](prepare). This
[repo](https://github.com/wang-q/dotfiles) contains macOS related codes.

## Install packages needed by Linuxbrew and some others

```bash
echo "==> When some packages went wrong, check http://mirrors.ustc.edu.cn/ubuntu/ for updating status."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/1-apt.sh)"

```

## Optional: adjusting Desktop

In GUI desktop, disable auto updates: `Software & updates -> Updates`, set `Automatically check for
updates:` to `Never`, untick all checkboxes, click close and click close again.

```bash
# Removes nautilus bookmarks and disables lock screen
echo '==> `Ctrl+Alt+T` to start a GUI terminal'
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/2-gnome.sh)"

```

## Install Linuxbrew

```bash
echo "==> Install linuxbrew, copy the next *ONE* line to terminal"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

test -d ~/.linuxbrew && PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

if grep -q -i linuxbrew $HOME/.bashrc; then
    echo "==> .bashrc already contains linuxbrew"
else
    echo "==> Update .bashrc"

    echo >> $HOME/.bashrc
    echo '# Linuxbrew' >> $HOME/.bashrc
    echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >> $HOME/.bashrc
    echo "export MANPATH='$(brew --prefix)/share/man'":'"$MANPATH"' >> $HOME/.bashrc
    echo "export INFOPATH='$(brew --prefix)/share/info'":'"$INFOPATH"' >> $HOME/.bashrc
    echo "export HOMEBREW_NO_ANALYTICS=1" >> $HOME/.bashrc
    echo "export HOMEBREW_NO_AUTO_UPDATE=1" >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source $HOME/.bashrc

```

## Download

Fill `$HOME/bin`, `$HOME/share` and `$HOME/Scripts`.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/dotfiles/master/download.sh)"
source $HOME/.bashrc

```

## Install packages managed by Linuxbrew

Packages includes:

* Programming languages: Perl, Python, R, Java, Lua and Node.js
* Some generalized tools

```bash
bash $HOME/Scripts/dotfiles/brew.sh
source $HOME/.bashrc

```

Attentions:

* There is a post-install step when installing perl, `cpan -i XML::Parser`. If the process stalled
    there, just kill the `cpan` process.

    * `Test::RequiresInternet` wants to connect to google.com while it was blocked.

* `r` and `gnuplot` have a lot of dependencies, many of which is from `linuxbrew/xorg`. Just be
    patient.

* Sometimes there are no binary packages in <https://linuxbrew.bintray.com/bottles/>, compiling from
    source codes may takes extra time.

## Packages of each languages

```bash
bash $HOME/Scripts/dotfiles/perl/install.sh

bash $HOME/Scripts/dotfiles/python/install.sh

bash $HOME/Scripts/dotfiles/r/install.sh

bash $HOME/Scripts/dotfiles/rust/install.sh

```

## Bioinformatics Apps

```bash
bash $HOME/Scripts/dotfiles/genomics.sh

bash $HOME/Scripts/dotfiles/ensembl.sh

# Optional: huge apps
# bash $HOME/Scripts/dotfiles/others.sh

```

## MySQL

```bash
bash $HOME/Scripts/dotfiles/mysql.sh

# Following the prompts, create mysql users and install DBD::mysql

```

## Optional: dotfiles

```bash
bash $HOME/Scripts/dotfiles/install.sh
source $HOME/.bashrc

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

```

Edit `.gitconfig` to your own manually.

## Directory Organization

* [`packer/`](packer): Scirpts for building an Ubuntu base box

* [`prepare/`](prepare): Scirpts for setting-up Ubuntu

* [`prepare/Vagrant.md`](prepare/Vagrant.md): Vagrant managed box
