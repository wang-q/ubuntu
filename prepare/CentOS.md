# CentOS 7

- [CentOS 7](#centos-7)
    * [Install the system](#install-the-system)
    * [The VM for R](#the-vm-for-r)
    * [Change the Home directory](#change-the-home-directory)
        + [Sudo](#sudo)
    * [Build R from sources](#build-r-from-sources)
        + [R Packages](#r-packages)
    * [Rust](#rust)
    * [TinyTex and fonts](#tinytex-and-fonts)
    * [The VM for Linuxbrew](#the-vm-for-linuxbrew)
    * [Install Linuxbrew without sudo](#install-linuxbrew-without-sudo)
    * [Brewed Packages](#brewed-packages)
        + [gcc, perl and commonly used libraries](#gcc-perl-and-commonly-used-libraries)
        + [Others](#others)
        + [Manually](#manually)
    * [Mirror to remote server](#mirror-to-remote-server)

Mimic after the HPCC of NJU

We will build two VMs here:

1. System gcc and yum packages, linked to the system libc
    * `R`
    * `Python` and `pip`
    * `rustup` in this VM
        * Bottled rust packages need GLIBC 2.18
        * Multiple versions of glibc confuse brewed cargo
    * `TinyTex` is installed by R

2. Linuxbrew with everything linked to the brewed glibc

## Install the system

```shell
# wget -N https://mirrors.nju.edu.cn/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-DVD-1908.iso

wget -N https://mirrors.nju.edu.cn/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso

```

In VMware/Parallels, Customize the VM hardware before installation as 4 or more cores, 4GB RAM, 80G
disk, 800x600 screen and Bridged Network (Default Adapter). Remove all unnecessary devices, e.g.
printer, camera, or sound card.

* Asia/Shanghai
* Minimal installation
* Don't use LVM and don't set the `/home` mount point

## The VM for R, Python and Rust

SSH in as `root`.

Present in the HPCC, `yum list installed | grep XXX`

* blas, lapack
* bzip2-devel
* openssl-devel
* libcurl-devel
* pcre-devel
* libffi-devel

Absent:

* udunits2
* imagemagick
* pcre2-devel
* cairo-devel

```shell
# Development Tools
yum -y upgrade
yum -y install net-tools # ifconfig
yum -y groupinstall 'Development Tools'
yum -y install file vim

yum -y install git

# locate
yum install -y mlocate
updatedb

# mimic libs
yum install -y zlib-devel bzip2-devel
yum install -y readline-devel ncurses-devel libxml2-devel
yum install -y openssl-devel libcurl-devel pcre-devel
yum install -y blas-devel lapack-devel
yum install -y libffi-devel
yum install -y libpng-devel libjpeg-turbo-devel freetype-devel fontconfig-devel
yum install -y ghostscript

yum install -y screen htop

# tlmgr need it
yum install -y perl-Digest-MD5

# fonts
yum install -y cabextract

#yum install -y libX11-devel libICE-devel libXt-devel libtirpc
yum install -y cairo-devel pango-devel # HPCC has no -devel

# epel
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y udunits2-devel
yum install -y cmake3
yum install -y proxychains-ng
yum install -y parallel

```

## Change the Home directory

`usermod` is the command to edit an existing user. `-d` (abbreviation for `--home`) will change the
user's home directory. Adding `-m` (abbreviation for `--move-home` will also move the content from
the user's current directory to the new directory.

```shell
pkill -KILL -u wangq

# Change the Home directory
mkdir -p /share/home
usermod -m -d /share/home/wangq wangq

```

### Sudo

We *must* install Homebrew as a non-sudoer.

This is *not* a necessary step.

```shell
usermod -aG wheel wangq
visudo

# wangq  ALL=(ALL) NOPASSWD:ALL

```

## Build R from sources

SSH in as `wangq`

All R-related binaries are built with system `gcc` and linked to the system `libc`.

Avoid using graphic, gtk and x11 packages in brew.

```shell
cd
mkdir -p $HOME/share/R

cd
curl -L https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/base/R-4/R-4.2.1.tar.gz |
    tar xvz
cd R-4.2.1

./configure \
    --prefix="$HOME/share/R" \
    --disable-java \
    --with-pcre1 \
    --with-blas \
    --with-lapack \
    --without-x \
    --without-tcltk \
    --without-ICU \
    --with-cairo \
    --with-libpng \
    --with-jpeglib \
    --with-libtiff

make -j 8
make check
make install

bin/Rscript -e '
    capabilities();
    png("test.png");
    plot(rnorm(4000),rnorm(4000),col="#ff000018",pch=19,cex=2);
    dev.off();
    '

cd
rm -fr ~/R-4.2.1

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

if grep -q -i R_42_PATH $HOME/.bashrc; then
    echo "==> .bashrc already contains R_42_PATH"
else
    echo "==> Updating .bashrc with R_42_PATH..."
    R_42_PATH="export PATH=\"$HOME/share/R/bin:\$PATH\""
    echo '# R_42_PATH' >> $HOME/.bashrc
    echo $R_42_PATH    >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source ~/.bashrc

Rscript -e '
    capabilities();
    png("test.png");
    plot(rnorm(4000),rnorm(4000),col="#ff000018",pch=19,cex=2);
    dev.off();
    '

```

### Proxy

SSH in as `wangq`

```shell

# aria2c.exe https://github.com/v2fly/v2ray-core/releases/download/v5.0.7/v2ray-linux-64.zip
# scp v2ray-linux-64.zip wangq@192.168.31.38:.
# scp config.json wangq@192.168.31.38:.

cd
mkdir ~/v2ray
unzip v2ray-linux-64.zip -d ~/v2ray

screen -wipe # Remove dead screens
screen -dmS op htop # Start a screen named `op` and run `htop`
screen -S op -x -X screen ~/v2ray/v2ray run -config ~/config.json

export ALL_PROXY=socks5h://localhost:1080

```

### R Packages

```shell
cd
curl -L https://raw.githubusercontent.com/wang-q/dotfiles/master/download.sh | bash

# nloptr need `cmake`
ln -s /usr/bin/cmake3 ~/bin/cmake

bash ~/Scripts/dotfiles/r/install.sh

# fonts
Rscript -e 'library(remotes); options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN")); remotes::install_version("Rttf2pt1", version = "1.3.8")'
Rscript -e 'library(extrafont); font_import(prompt = FALSE); fonts();'

# anchr
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = FALSE)) { install.packages("{}", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") } '\''
    ' ::: \
        argparse minpack.lm \
        ggplot2 scales viridis

# bmr
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { install.packages("{}", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") } '\''
    ' ::: \
        getopt foreach doParallel \
        extrafont ggplot2 gridExtra \
        survival survminer \
        timeROC pROC verification \
        tidyverse devtools BiocManager

# BioC packages
Rscript -e 'BiocManager::install(version = "3.15", ask = FALSE)'
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { BiocManager::install("{}", version = "3.15") } '\''
    ' ::: \
        Biobase GEOquery GenomicDataCommons

# raster, classInt and spData need gdal
# units needs udunit2
# survminer might need a high version of gcc

## R
## Can't use brewed libxml2
#Rscript -e ' install.packages(
#    "XML",
#    repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN",
#    configure.args = "--with-xml-config=/usr/bin/xml2-config",
#    configure.vars= "CC=gcc-5"
#    ) '
#
## manually
#curl -L https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/contrib/XML_3.99-0.9.tar.gz |
#    tar xvz
#cd XML
#./configure --with-xml-config=/usr/bin/xml2-config
#CC=gcc-5 R CMD INSTALL . --configure-args='--with-xml-config=/usr/bin/xml2-config'

```

## Python

Python updates in Homebrew are too frequent

```shell
cd
mkdir -p $HOME/share/Python

cd
curl -L https://www.python.org/ftp/python/3.9.13/Python-3.9.13.tgz |
    tar xvz
cd Python-3.9.13

./configure --enable-optimizations --prefix=$HOME/share/Python

make install
#make altinstall # binaries: python3.9 and pip3.9

cd
rm -fr ~/Python-3.9.13

if grep -q -i PYTHON_39_PATH $HOME/.bashrc; then
    echo "==> .bashrc already contains PYTHON_39_PATH"
else
    echo "==> Updating .bashrc with PYTHON_39_PATH..."
    PYTHON_39_PATH="export PATH=\"$HOME/share/Python/bin:\$PATH\""
    echo '# PYTHON_39_PATH' >> $HOME/.bashrc
    echo $PYTHON_39_PATH    >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source ~/.bashrc

~/share/Python/bin/python3 -m pip install --upgrade pip setuptools wheel

```

### Python Packages

```shell
cd

bash ~/Scripts/dotfiles/python/install.sh

# quast
pip3 install quast
curl -L quast.sf.net/test_data.tar.gz |
    tar xvz
quast.py --test

rm -fr test_data quast_test_output

```

## Rust

```shell
mkdir -p ~/.proxychains/

cat << EOF > ~/.proxychains/proxychains.conf
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
localnet 127.0.0.0/255.0.0.0
quiet_mode

[ProxyList]
socks5  127.0.0.1 1080

EOF

bash ~/Scripts/dotfiles/rust/install.sh

source ~/.bashrc

proxychains4 cargo install bat exa bottom tealdeer
proxychains4 cargo install hyperfine ripgrep tokei

```

## TinyTex and fonts

Same as [this](https://github.com/wang-q/dotfiles/blob/master/tex/texlive.md).

```shell
proxychains4 Rscript -e '
    install.packages("tinytex", repos="https://mirrors4.tuna.tsinghua.edu.cn/CRAN")
    tinytex::install_tinytex()
    '

proxychains4 Rscript -e '
    tinytex:::install_yihui_pkgs()
    '

```

## The VM for Linuxbrew

SSH in as `root`.

Present in the HPCC, `yum list installed | grep XXX`

* ghostscript
* `/usr/bin/java -version` openjdk version "1.8.0_222-ea"

Absent:

* imagemagick
* gnuplot

```shell
# Development Tools
yum -y upgrade
yum -y install net-tools
yum -y groupinstall 'Development Tools'
yum -y install file vim

# locate
yum install -y mlocate
updatedb

yum install -y screen

yum install -y fontconfig perl-IPC-Cmd

# Some Perl modules need system libs
#yum install -y zlib-devel expat-devel libxml2-devel

rpm -Uvh https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/patchelf-0.12-1.el7.x86_64.rpm
# can't use brewed patchelf

# Install newer versions of git and curl
# Linuxbrew need git 2.7.0 and cURL 7.41.0
rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm \
    && yum install -y git

git --version
# git version 2.31.1

# libnghttp2 is in epel
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y libnghttp2

# curl need libnghttp2
rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel7/x86_64/city-fan.org-release-2-2.rhel7.noarch.rpm

yum install -y yum-utils

yum --enablerepo=city-fan.org install -y libcurl libcurl-devel

curl --version
# curl 7.82.0

yum-config-manager --disable city-fan.org

# https://github.com/Linuxbrew/legacy-linuxbrew/issues/46#issuecomment-308758171
yum remove -y yum-utils

```

Change Home as [above](#change-the-home-directory)

## Install Linuxbrew without sudo

SSH in as `wangq`

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

## Brewed Packages

### gcc, perl and commonly used libraries

* This gist <https://gist.github.com/warking/c9a9e6fb5938fbe8ff20>
* Use bottled gcc@5 and gcc (gcc@11)
    * gcc `make bootstrap` requires `crti.o`. This seems to be a bug
* Invoke `brew install glibc` later
    * Make as many programs as possible link to the system `libc'
    * Some bottles doesn't work with brewed glibc

```shell

export HOMEBREW_NO_AUTO_UPDATE=1

# System gcc-4.8
ln -s $(which gcc) `brew --prefix`/bin/gcc-$(gcc -dumpversion |cut -d. -f1,2)
ln -s $(which g++) `brew --prefix`/bin/g++-$(g++ -dumpversion |cut -d. -f1,2)
ln -s $(which gfortran) `brew --prefix`/bin/gfortran-$(gfortran -dumpversion |cut -d. -f1,2)

brew doctor

# install glibc@2.13
brew install linux-headers@4.4
brew install -s glibc@2.13

brew install -s zlib
brew install -s binutils

brew install -s glibc

# Not so good when building glibc with gcc-5
#brew install linux-headers@4.4
#brew install --build-from-source glibc --verbose
#
## https://github.com/Homebrew/discussions/discussions/2011
## https://askubuntu.com/questions/1321354/inconsistency-detected-by-ld-so-elf-get-dynamic-info-assertion-infodt-runpat
## need su
#patchelf --remove-rpath $(realpath /share/home/wangq/.linuxbrew/lib/ld.so)
#
#brew postinstall glibc

#strings ~/.linuxbrew/lib/libc.so.6 | grep "^GLIBC_"
#strings /usr/lib64/libc.so.6 | grep "^GLIBC_"
# System glibc doesn't contain GLIBC_2.18 or later

brew install --force-bottle util-linux

# Homebrew gcc-5
brew install --force-bottle gcc@5

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

# Download
brew install stow
curl -L https://raw.githubusercontent.com/wang-q/dotfiles/master/download.sh | bash

bash ~/Scripts/dotfiles/install.sh

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

brew install proxychains-ng

# Some building tools
brew install autoconf libtool automake # autogen
brew install cmake
brew install bison flex

# libs
brew install gsl
brew install libssh2
brew install jemalloc
brew install boost

# background processes
brew install htop

# python
# These two are required by other brewed packages
brew install --force-bottle python # is now python@3.9
brew install --force-bottle python@3.9
brew install --force-bottle python@3.10

```

### Others

The failed compilation package was installed with `--force-bottle`.

```shell

# fontconfig
## Build fontconfig need GLIBC_2.18
brew install $( brew deps fontconfig )
brew install fontconfig

# gd
brew install $( brew deps gd )
brew install gd

# gtk stuffs
brew install glib
brew install cairo

# linked to brewed glibc
brew reinstall -s libffi

brew install gobject-introspection
brew install harfbuzz
brew install pango

brew install shared-mime-info
brew install gdk-pixbuf
brew install librsvg

# Qt
brew install --force-bottle systemd
brew install --force-bottle libdrm
brew install --force-bottle $( brew deps mesa ) # tons of X11 related deps
brew unlink llvm
brew install --force-bottle mesa
brew install --force-bottle p11-kit # Test failed
brew install --force-bottle pulseaudio

brew install $( brew deps qt@5 )
brew install qt@5
#brew install qt

# Java
brew install --force-bottle openjdk

# ghostscript
brew install $( brew deps ghostscript )
brew install ghostscript

# graphics
brew install gnuplot

brew install --force-bottle graphviz

brew install $( brew deps imagemagick )
brew install imagemagick

# others
brew install bats
#brew install bats-core  # require coreutils, which is huge
brew install libaec     # replaces szip
brew install elfutils   # replaces libelf

brew install lua node
brew install pandoc gifsicle
brew install aria2 wget
brew install parallel pigz
brew install pv
brew install jq pup datamash miller prettier

# Packages written in Rust are installed by cargo

# dazz
brew install brewsci/science/poa
brew install wang-q/tap/faops
brew install --HEAD wang-q/tap/dazz_db
brew install --HEAD wang-q/tap/daligner
brew install wang-q/tap/intspan

brew install wang-q/tap/tsv-utils

## bash-completion
#brew unlink util-linux
#brew install --build-from-source bash-completion
#
#cat <<EOF >> ~/.bashrc
#
## bash-completion
#[[ -r "$HOME/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "$HOME/.linuxbrew/etc/profile.d/bash_completion.sh"
#
#EOF
#
#source ~/.bashrc

```

### Manually

```shell

# Perl
cpanm --look XML::Parser
perl Makefile.PL EXPATLIBPATH="$(brew --prefix expat)/lib" EXPATINCPATH="$(brew --prefix expat)/include"
make test
make install

cpanm --look Net::SSLeay
OPENSSL_PREFIX="$(brew --prefix openssl@1.1)" perl Makefile.PL
make
make test
make install

# We don't use this R
brew install --force-bottle $( brew deps -n r )
brew install --force-bottle r

cpanm --verbose Statistics::R

# Perl modules
bash ~/Scripts/dotfiles/perl/install.sh

# latexindent
cpanm --verbose --mirror-only --mirror https://mirrors.ustc.edu.cn/CPAN/ \
    YAML::Tiny File::HomeDir Unicode::GCString Log::Log4perl Log::Dispatch::File

# Manually
dotfiles/genomics.sh

#brew install numpy --force-bottle
#brew install scipy --force-bottle
#brew install matplotlib --force-bottle
##brew install brewsci/bio/kat --force-bottle # boost 1.75 no longer exists

# SRA Toolkit
aria2c -c https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.0/sratoolkit.3.0.0-centos_linux64.tar.gz

tar -xvzf sratoolkit*.tar.gz --wildcards "*/bin/*"
rm -fr sratoolkit*/bin/ncbi
cp sratoolkit*/bin/* ~/bin/

rm -fr sratoolkit*

# anchr
curl -fsSL https://raw.githubusercontent.com/wang-q/anchr/main/templates/install_dep.sh | bash

cpanm --verbose install App::Dazz

curl -fsSL https://raw.githubusercontent.com/wang-q/anchr/main/templates/check_dep.sh | bash

brew install --HEAD wang-q/tap/fastk
brew install --HEAD wang-q/tap/merquryfk

# assembly quality assessment. https://github.com/ablab/quast/issues/140
brew install brewsci/bio/quast --HEAD
quast --test

# Optional: leading assemblers
brew install spades
spades.py --test
brew install brewsci/bio/megahit
brew install wang-q/tap/platanus

# App::Egaz
curl -fsSL https://raw.githubusercontent.com/wang-q/App-Egaz/master/share/check_dep.sh | bash

# App::Plotr
curl -fsSL https://raw.githubusercontent.com/wang-q/App-Plotr/master/share/check_dep.sh | bash

# kat igvtools

```

## Mirror to remote server

```shell
# CentOS L
rsync -avP ~/.linuxbrew/ wangq@202.119.37.251:.linuxbrew
rsync -avP ~/bin/ wangq@202.119.37.251:bin

# CentOS R
rsync -avP ~/share/ wangq@202.119.37.251:share
rsync -avP ~/.TinyTeX/ wangq@202.119.37.251:.TinyTeX
rsync -avP ~/.cargo/ wangq@202.119.37.251:.cargo
rsync -avP ~/.fonts/ wangq@202.119.37.251:.fonts

rsync -avP ~/.bashrc wangq@202.119.37.251:.bashrc
rsync -avP ~/.bash_profile wangq@202.119.37.251:.bash_profile

# Sync back
rsync -avP wangq@202.119.37.251:.linuxbrew/ ~/.linuxbrew
rsync -avP wangq@202.119.37.251:share/ ~/share
rsync -avP wangq@202.119.37.251:bin/ ~/bin
rsync -avP wangq@202.119.37.251:.bashrc ~/.bashrc
rsync -avP wangq@202.119.37.251:.bash_profile ~/.bash_profile

```

Off campus

```shell
rsync -avP ~/share/ wangq@58.213.64.36:share

58.213.64.36

```
