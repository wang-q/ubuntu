# CentOS 7

For HPCC in NJU

## Install

```shell
# wget -N https://mirrors.nju.edu.cn/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-DVD-1908.iso

wget -N https://mirrors.nju.edu.cn/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso

```

Let Parallels use the express installation. Customize the VM before installation as 4 cores, 4GB
RAM, and 64G disk. Remove all unnecessary devices, e.g. printer, camera, or sound card.

Change the VM to Bridged Network (Default Adapter)

SSH in as `root`.

## Change the Home directory

`usermod` is the command to edit an existing user. `-d` (abbreviation for `--home`) will change the
user's home directory. Adding `-m` (abbreviation for `--move-home` will also move the content from
the user's current directory to the new directory.

```shell
pkill -KILL -u wangq

# Change the Home directory
mkdir -p /share/home
usermod -m -d /share/home/wangq wangq

# Development Tools
yum -y upgrade
yum -y install net-tools
yum -y groupinstall 'Development Tools'
#yum install glibc-devel.x86_64 libgcc.x86_64 libstdc++-devel.x86_64 ncurses-devel.x86_64
yum -y install file vim

# Linuxbrew need git 2.7.0 and cURL 7.41.0
rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm \
    && yum install -y git

git --version
# git version 2.31.1

# libnghttp2 is in epel
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# curl need libnghttp2
rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel7/x86_64/city-fan.org-release-2-2.rhel7.noarch.rpm

yum install -y yum-utils

yum --enablerepo=city-fan.org install -y libcurl
yum install -y libcurl

curl --version
# curl 7.82.0

yum-config-manager --disable city-fan.org
#yum-config-manager --disable epel

# https://github.com/Linuxbrew/legacy-linuxbrew/issues/46#issuecomment-308758171
yum remove -y yum-utils

# locate
yum install -y mlocate
updatedb

# libs
yum install -y libxml2-devel # R XML failed with brew's libxml2
yum install -y zlib-devel libdb-devel # for Perl

rpm -Uvh https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/patchelf-0.12-1.el7.x86_64.rpm

```

## Install Linuxbrew without sudo

* SSH in as `wangq`

```shell
cat <<EOF >> ~/.bashrc

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X'

# colors
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'

EOF

source ~/.bashrc

echo "==> Tuna mirrors of Homebrew/Linuxbrew"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"

git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
/bin/bash brew-install/install.sh

# can't sudo
# Ctrl+D to install linuxbrew to PATH=$HOME/.linuxbrew
# RETURN to start installation

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
    echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"' >> $HOME/.bashrc
    echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"' >> $HOME/.bashrc
    echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source $HOME/.bashrc

```

## Sudo

We *must* install Homebrew as a non-sudoer.

This is *not* a necessary step.

```shell
usermod -aG wheel wangq
visudo

# wangq  ALL=(ALL) NOPASSWD:ALL

```

## Packages

### gcc and commonly used libraries

* Use bottled gcc@5 and gcc (gcc@11)
    * gcc `make bootstrap` requires `crti.o`. This seems to be a bug

```shell

export HOMEBREW_NO_AUTO_UPDATE=1

# aria2c.exe https://github.com/v2fly/v2ray-core/releases/download/v5.0.3/v2ray-linux-64.zip
# scp v2ray-linux-64.zip wangq@10.0.1.26:.
# scp config.json wangq@10.0.1.26:.
# 
# mkdir ~/v2ray
# unzip v2ray-linux-64.zip -d ~/v2ray
# ~/v2ray/v2ray -config ~/config.json

# export ALL_PROXY=socks5h://localhost:1080

brew install --only-dependencies gcc
brew install --force-bottle gcc

# # find /usr/ -name crt*
# sudo ln -s /usr/lib64/crt1.o /usr/lib/crt1.o
# sudo ln -s /usr/lib64/crti.o /usr/lib/crti.o
# sudo ln -s /usr/lib64/crtn.o /usr/lib/crtn.o

brew install linux-headers@4.4
brew install --build-from-source glibc

# https://github.com/Homebrew/discussions/discussions/2011
# https://askubuntu.com/questions/1321354/inconsistency-detected-by-ld-so-elf-get-dynamic-info-assertion-infodt-runpat
patchelf --remove-rpath $(realpath ~/.linuxbrew/lib/ld.so)

brew postinstall glibc

strings ~/.linuxbrew/lib/libc.so.6 | grep "^GLIBC_"

strings /usr/lib64/libc.so.6 | grep "^GLIBC_"

# System glibc doesn't contain GLIBC_2.18 or later
# We should prevent custom build to reach the system one.

# perl
echo "==> Install Perl 5.34"
brew install perl

if grep -q -i PERL_534_PATH $HOME/.bashrc; then
    echo "==> .bashrc already contains PERL_534_PATH"
else
    echo "==> Updating .bashrc with PERL_534_PATH..."
    PERL_534_PATH="export PATH=\"$(brew --prefix perl)/bin:\$PATH\""
    echo '# PERL_534_PATH' >> $HOME/.bashrc
    echo $PERL_534_PATH    >> $HOME/.bashrc
    echo >> $HOME/.bashrc

    # Make the above environment variables available for the rest of this script
    eval $PERL_534_PATH
fi

hash cpanm 2>/dev/null || {
    curl -L https://cpanmin.us |
        perl - -v --mirror-only --mirror http://mirrors.ustc.edu.cn/CPAN/ App::cpanminus
}

# Some building tools
brew install autoconf automake autogen libtool
brew install cmake
brew install bison flex

# libs
brew install gsl
brew install libgit2
brew install libgcrypt
brew install libxslt
brew install jemalloc
brew install boost
brew install nghttp2

# background processes
brew install screen htop

```

### Others

The failed compilation package was installed with `--force-bottle`.

```shell

# python
brew install python@3.9

if grep -q -i PYTHON_39_PATH $HOME/.bashrc; then
    echo "==> .bashrc already contains PYTHON_39_PATH"
else
    echo "==> Updating .bashrc with PYTHON_39_PATH..."
    PYTHON_39_PATH="export PATH=\"$(brew --prefix)/opt/python@3.9/bin:$(brew --prefix)/opt/python@3.9/libexec/bin:\$PATH\""
    echo '# PYTHON_39_PATH' >> $HOME/.bashrc
    echo ${PYTHON_39_PATH} >> $HOME/.bashrc
    echo >> $HOME/.bashrc

    # make the above environment variables available for the rest of this script
    eval ${PYTHON_39_PATH}
fi

# fontconfig
brew install --force-bottle ruby
brew install $( brew deps fontconfig )
brew install --force-bottle fontconfig

# gd
brew install $( brew deps gd )
brew install --build-from-source gd

# ghostscript
brew install $( brew deps ghostscript )
brew install ghostscript --cc gcc-5

# java
brew install $( brew deps openjdk@11 )
#brew install openjdk@11
#brew link openjdk@11 --force
brew install --force-bottle openjdk

java -version

brew install ant maven

# r
brew install --build-from-source r

# some r packages need udunits and gdal
brew install udunits

brew install --force-bottle libdrm
brew install --force-bottle mesa
brew install --force-bottle systemd
brew install --force-bottle pulseaudio
brew install --force-bottle p11-kit
brew install qt
brew install qt@5

brew install --force-bottle libdap
brew install --force-bottle numpy
brew install --force-bottle gdal

# graphics
brew install $( brew deps gnuplot )
brew install --force-bottle gnuplot

brew install --force-bottle shared-mime-info
brew install $( brew deps graphviz )
brew install graphviz

brew install --force-bottle libheif
brew install $( brew deps imagemagick )
brew install imagemagick

# others
brew install bats-core  # replaces bats
brew install libaec     # replaces szip
brew install elfutils   # replaces libelf

brew install lua node
brew install pandoc
brew install aria2 wget
brew install screen stow htop parallel pigz
brew install cloc tree pv
brew install jq pup datamash miller wang-q/tap/tsv-utils
brew install hyperfine ripgrep

# brew install openmpi

# pins
brew pin r

## Test your installation
#brew install hello
#brew test hello

# bash-completion
brew unlink util-linux
brew install --build-from-source bash-completion

cat <<EOF >> ~/.bashrc

# bash-completion
[[ -r "$HOME/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "$HOME/.linuxbrew/etc/profile.d/bash_completion.sh"

EOF

source ~/.bashrc

```

### Manually

```shell
# SRA Toolkit
curl -LO https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.0/sratoolkit.3.0.0-centos_linux64.tar.gz

tar -xvzf sratoolkit*.tar.gz --wildcards "*/bin/*"

rm -fr sratoolkit*/bin/ncbi

cp sratoolkit*/bin/* ~/bin/

# dotfiles/genomics.sh

# Perl
cpanm --look XML::Parser
perl Makefile.PL EXPATLIBPATH="$(brew --prefix expat)/lib" EXPATINCPATH="$(brew --prefix expat)/include"
make test
make install 

cpanm --look Net::SSLeay
OPENSSL_PREFIX="$(brew --prefix openssl@1.1)" perl Makefile.PL
CC=gcc-5 LD=gcc-5 make
make test
make install

bash ~/Scripts/dotfiles/perl/install.sh

# R
# Can't use brewed libxml2
Rscript -e ' install.packages(
    "XML",
    repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN",
    configure.args = "--with-xml-config=/usr/bin/xml2-config",
    configure.vars= "CC=gcc-5"
    ) '

# manually
curl -L https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/contrib/XML_3.99-0.9.tar.gz |
    tar xvz
cd XML
./configure --with-xml-config=/usr/bin/xml2-config
CC=gcc-5 R CMD INSTALL . --configure-args='--with-xml-config=/usr/bin/xml2-config'

bash ~/Scripts/dotfiles/r/install.sh

# rust

# dazz
brew install brewsci/science/poa
brew install wang-q/tap/faops
brew install --HEAD wang-q/tap/dazz_db
brew install --HEAD wang-q/tap/daligner
brew install wang-q/tap/intspan

# anchr 
curl -fsSL https://raw.githubusercontent.com/wang-q/anchr/main/templates/check_dep.sh | bash

# App::Egaz
curl -fsSL https://raw.githubusercontent.com/wang-q/App-Egaz/master/share/check_dep.sh | bash

# App::Plotr
curl -fsSL https://raw.githubusercontent.com/wang-q/App-Plotr/master/share/check_dep.sh | bash

# bmr
# R packages
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { install.packages("{}", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") } '\''
    ' ::: \
        getopt foreach doParallel \
        extrafont ggplot2 gridExtra \
        survival survminer \
        timeROC pROC verification \
        tidyverse devtools BiocManager

# BioC packages
Rscript -e 'BiocManager::install(version = "3.14", ask = FALSE)'
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { BiocManager::install("{}", version = "3.14") } '\''
    ' ::: \
        Biobase GEOquery GenomicDataCommons

# kat igvtools

```

## Mirror to remote server

```shell
rsync -avP ~/.linuxbrew/ wangq@202.119.37.251:.linuxbrew
rsync -avP ~/share/ wangq@202.119.37.251:share
rsync -avP ~/bin/ wangq@202.119.37.251:bin
rsync -avP ~/.bashrc wangq@202.119.37.251:.bashrc
rsync -avP ~/.bash_profile wangq@202.119.37.251:.bash_profile

# Sync back
rsync -avP wangq@202.119.37.251:.linuxbrew/ ~/.linuxbrew
rsync -avP wangq@202.119.37.251:share/ ~/share
rsync -avP wangq@202.119.37.251:bin/ ~/bin
rsync -avP wangq@202.119.37.251:.bashrc ~/.bashrc
rsync -avP wangq@202.119.37.251:.bash_profile ~/.bash_profile

```

