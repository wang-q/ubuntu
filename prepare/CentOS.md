# CentOS 7

- [CentOS 7](#centos-7)
    * [Install the system](#install-the-system)
    * [The VM for Linuxbrew](#the-vm-for-linuxbrew)
    * [Change the Home directory](#change-the-home-directory)
        + [Sudo](#sudo)
    * [Change the hostname](#change-the-hostname)
    * [Proxy](#proxy)
    * [Install Linuxbrew without sudo](#install-linuxbrew-without-sudo)
    * [gcc, perl and commonly used libraries](#gcc-perl-and-commonly-used-libraries)
    * [Build R from sources](#build-r-from-sources)
    * [Build Python from sources](#build-python-from-sources)
    * [Rust](#rust)
    * [R Packages](#r-packages)
    * [Other brew packages](#other-brew-packages)
    * [My Perl modules](#my-perl-modules)
    * [Manually install gnuplot and graphviz](#manually-install-gnuplot-and-graphviz)
    * [TinyTex and fonts](#tinytex-and-fonts)
    * [.ssh](#ssh)
    * [Mirror to remote server](#mirror-to-remote-server)



We will build several VMs here:

1. `centos.tar` - a VM exported from docker images

2. `centos.root.tar` - Mimic after the HPCC of NJU; wangq as the default user

3. `CentS` - system gcc and yum packages, linked to the system libc
    * `Perl`
    * `Python`
    * A minimal `R`
    * `rustup`
        * Homebrew bottled rust packages can't be used as they need GLIBC 2.18
    * `TinyTex` is installed by R

4. `CentH` - everything else in Homebrew is linked to the brewed glibc
    * `R` compiled by gcc@9

## Install the system

### In WSL

This one is prefered.

https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro

* Install Docker Desktop on Windows
    * Use WSL 2
    * Settings -> Resources -> WSL integration -> Tick Ubuntu

```shell
docker pull centos:centos7

# An arbitrary command to generate a container
docker run -t centos:centos7 bash ls /

dockerContainerID=$(docker container ls -a | grep -i centos | awk '{print $1}')

docker export $dockerContainerID > /mnt/c/Users/wangq/centos.tar

```

```powershell
mkdir -p $HOME\VM

mv centos.tar $HOME\VM

wsl --import CentOS $HOME\VM\CentOS $HOME\VM\centos.tar

# list all VMs
wsl -l -v

# Start CentOS
wsl -d CentOS

# wsl --terminate CentOS # To refresh wsl.conf

```

### In VMware/Parallels

```shell
wget -N https://mirrors.nju.edu.cn/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-2207-02.iso

```

In VMware/Parallels, Customize the VM hardware before installation as 4 or more cores, 4GB RAM, 80G
disk, 800x600 screen and Bridged Network (Default Adapter). Remove all unnecessary devices, e.g.
printer, camera, or sound card.

Settings at installation:

* Asia/Shanghai
* Minimal installation
* Don't use LVM and don't set the `/home` mount point

## As `root`

### Install libraries

SSH in as `root`.

Present in the HPCC, `yum list installed | grep XXX`

* blas, lapack
* bzip2-devel
* openssl-devel
* libcurl-devel
* pcre-devel
* libffi-devel
* sqlite-devel
* ncurses-devel
* readline-devel
* libuuid-devel
* gd

* ghostscript
* `/usr/bin/java -version` openjdk version "1.8.0_222-ea"

Absent:

* pcre2-devel
* cairo-devel
* udunits2
* gdal
* imagemagick
* gnuplot

```shell
# Development Tools
yum -y upgrade
yum -y install net-tools # ifconfig
yum -y groupinstall 'Development Tools'
yum -y install file vim

# Install newer versions of git and curl
# Linuxbrew need git 2.7.0 and cURL 7.41.0
rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm \
    && yum install -y git

git --version
# git version 2.39.1

# curl need libnghttp2
# libnghttp2 is in epel
yum install -y epel-release
sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
    -e 's|^#baseurl=https\?://download.example/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
    -i.bak \
    /etc/yum.repos.d/epel.repo
yum install -y libnghttp2

# city-fan
rpm -Uvh https://mirror.city-fan.org/ftp/contrib/yum-repo/city-fan.org-release-3-8.rhel7.noarch.rpm

yum install -y yum-utils

yum --enablerepo=city-fan.org install -y libcurl libcurl-devel

curl --version
# curl 8.1.2

yum-config-manager --disable city-fan.org

# https://github.com/Linuxbrew/legacy-linuxbrew/issues/46#issuecomment-308758171
yum remove -y yum-utils

# mimic libs
yum install -y zlib-devel bzip2-devel xz-devel
yum install -y readline readline-devel ncurses ncurses-devel
yum install -y libxml2 libxml2-devel expat expat-devel libxslt libxslt-devel
yum install -y libcurl-devel pcre-devel

# Python
yum install -y openssl openssl-devel
yum install -y libffi libffi-devel
yum install -y libuuid libuuid-devel
yum install -y sqlite sqlite-devel

# R
yum install -y blas-devel lapack-devel
yum install -y libpng-devel libjpeg-turbo-devel libtiff-devel freetype-devel fontconfig-devel
yum install -y ghostscript

#yum install -y libX11-devel libICE-devel libXt-devel libtirpc
yum install -y cairo-devel pango-devel # HPCC has no -devel

yum install -y gd gd-devel

# tlmgr need these
yum install -y perl-IPC-Cmd perl-Digest-MD5

# fonts
yum install -y cabextract

# epel
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y udunits2-devel
yum install -y cmake3
yum install -y proxychains-ng
yum install -y parallel

# background
yum install -y screen htop

# locate
yum install -y mlocate
updatedb

```

### Change the Home directory

`usermod` is the command to edit an existing user. `-d` (abbreviation for `--home`) will change the
user's home directory. Adding `-m` (abbreviation for `--move-home` will also move the content from
the user's current directory to the new directory.

```shell
yum install passwd sudo -y

myUsername=wangq
adduser -G wheel $myUsername
echo -e "[user]\ndefault=$myUsername" >> /etc/wsl.conf
echo -e "[interop]\nappendWindowsPath=false" >> /etc/wsl.conf
passwd $myUsername

```

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

### Change the hostname

Can't change hostname inside WSL

```shell
hostnamectl set-hostname centos

systemctl reboot

```

### Backup WSL

```powershell
wsl --terminate CentOS

wsl --export CentOS $HOME\VM\centos.root.tar

# Totally remove CentOS
# wsl --unregister CentOS

```

## CentS

We will build the VM (almost all in share/) with system gcc and yum packages, linked to the system libc

```powershell
wsl --import CentS $HOME\VM\CentS $HOME\VM\centos.root.tar

wsl -d CentS

```

### Perl, Python, R, and Rust with system `libc`

All following binaries are built with system `gcc` and linked to the system `libc`.

Avoid using graphic, gtk and x11 packages in brew.

```shell
# mkdir -p $HOME/Scripts
# cd $HOME/Scripts
# git clone https://github.com/wang-q/dotfiles.git
cd

# Avoid rust target/
ln -s /mnt/c/Users/wangq/Scripts/ Scripts

# Builds
bash ~/Scripts/dotfiles/perl/build.sh

bash ~/Scripts/dotfiles/python/build.sh

# A minimal R built by gcc-4.8
bash ~/Scripts/dotfiles/r/build.sh

# Rust
bash ~/Scripts/dotfiles/rust/install.sh

source $HOME/.bashrc

cargo install bat exa bottom tealdeer
cargo install hyperfine ripgrep tokei

# Python libraries
bash ~/Scripts/dotfiles/python/install.sh

```

### Gnuplot and graphviz

```shell
# gnuplot
mkdir -p $HOME/bin
mkdir -p $HOME/share/gnuplot

curl -L https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.4.3/gnuplot-5.4.3.tar.gz |
    tar xvz

cd gnuplot-*

CC=gcc CXX=g++ PKG_CONFIG=/usr/bin/pkg-config PKG_CONFIG_PATH=/usr/lib64/pkgconfig/ \
./configure \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --with-readline=builtin \
    --without-aquaterm \
    --disable-wxwidgets \
    --without-qt \
    --without-x \
    --without-latex \
    --without-gd \
    --without-tektronix \
    --prefix=$HOME/share/gnuplot

make
make install

ln -sf ~/share/gnuplot/bin/gnuplot ~/bin/gnuplot

gnuplot <<- EOF
    set term png
    set output "output.png"
    plot sin(x) with linespoints pointtype 3
EOF

cd
rm -fr gnuplot-*

# graphviz
mkdir -p $HOME/share/graphviz

curl -L https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/5.0.0/graphviz-5.0.0.tar.gz |
    tar xvz

cd graphviz-*

CC=gcc CXX=g++ PKG_CONFIG=/usr/bin/pkg-config PKG_CONFIG_PATH=/usr/lib64/pkgconfig/ \
./configure \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --disable-php \
    --disable-swig \
    --disable-tcl \
    --without-quartz \
    --without-freetype2 \
    --without-gdk \
    --without-gdk-pixbuf \
    --without-glut \
    --without-gtk \
    --without-poppler \
    --without-qt \
    --without-x \
    --without-gts \
    --prefix=$HOME/share/graphviz

# https://stackoverflow.com/questions/10279829/installing-glib-in-non-standard-prefix-fails
make clean
make
make install

find $HOME/share/graphviz/bin/ -type f |
    parallel -j 1 -k --line-buffer '
        >&2 echo {}
        ln -s {} ~/bin/{/}
        '

dot -Tpdf -o sample.pdf <(echo "digraph G { a -> b }")

cd
rm -fr graphviz-*

```

### Perl modules

```shell

# Perl
# cpanm --look XML::Parser
# perl Makefile.PL EXPATLIBPATH="$(brew --prefix expat)/lib" EXPATINCPATH="$(brew --prefix expat)/include"
# make test
# make install

# cpanm --look Net::SSLeay
# OPENSSL_PREFIX="$(brew --prefix openssl@1.1)" CC=gcc-13 perl Makefile.PL
# make
# make test
# make install

bash ~/Scripts/dotfiles/perl/install.sh

cpanm --verbose Statistics::R

# latexindent
cpanm --verbose --mirror-only --mirror https://mirrors.ustc.edu.cn/CPAN/ \
    YAML::Tiny File::HomeDir Unicode::GCString Log::Log4perl Log::Dispatch::File

# My modules
cpanm -nq App::Dazz # need dazz in $PATH
cpanm --verbose --force App::Dazz

# App::Egaz
curl -fsSL https://raw.githubusercontent.com/wang-q/App-Egaz/master/share/check_dep.sh |
    bash

# App::Plotr
curl -fsSL https://raw.githubusercontent.com/wang-q/App-Plotr/master/share/check_dep.sh |
    bash

```

### TinyTex and fonts

Same as [this](https://github.com/wang-q/dotfiles/blob/master/tex/texlive.md).

```shell
Rscript -e '
    install.packages("tinytex", repos="https://mirrors.ustc.edu.cn/CRAN")
    tinytex::install_tinytex(force = TRUE)
    '

Rscript -e '
    tinytex:::install_yihui_pkgs()
    '

```

### SRA Toolkit

```shell
cd

# SRA Toolkit
curl -LO https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.5/sratoolkit.3.0.5-centos_linux64.tar.gz

tar -xvzf sratoolkit*.tar.gz --wildcards "*/bin/*"
rm -fr sratoolkit*/bin/ncbi
cp sratoolkit*/bin/* ~/bin/

rm -fr sratoolkit*

```

### .nwr



```shell
cd

mkdir ~/.nwr
# Put the files of appropriate time into this directory

cd ~/Scripts/nwr
cargo install --path . --force --offline

# Populate databases
nwr download

nwr txdb

nwr ardb
nwr ardb --genbank

```

### .ssh

```shell
cp -R /mnt/c/Users/wangq/.ssh/ ~/

chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/known_hosts

```

### Backup WSL

```powershell
wsl --terminate CentS

wsl --export CentS $HOME\VM\CentS.tar

```

## CentH

Homebrew

```powershell
wsl --import CentH $HOME\VM\CentH $HOME\VM\centos.root.tar

wsl -d CentH

```

```shell
echo "==> USTC mirrors of Homebrew"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"

cd
mkdir homebrew &&
    curl -L https://github.com/Homebrew/brew/tarball/master |
        tar xz --strip 1 -C homebrew

eval "$($HOME/homebrew/bin/brew shellenv)"
brew update --force --quiet

if grep -q -i Homebrew $HOME/.bashrc; then
    echo "==> .bashrc already contains Homebrew"
else
    echo "==> Update .bashrc"

    echo >> $HOME/.bashrc
    echo '# Homebrew' >> $HOME/.bashrc
    echo "export HOMEBREW_NO_ANALYTICS=1" >> $HOME/.bashrc
    echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"' >> $HOME/.bashrc
    echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"' >> $HOME/.bashrc
    echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"' >> $HOME/.bashrc
    echo 'export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"' >> $HOME/.bashrc
    echo 'eval "$($HOME/homebrew/bin/brew shellenv)"' >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source $HOME/.bashrc

```

### gcc and commonly used libraries

* Homebrew 4.0 brings glibc-bootstrap, which makes installing glibc and gcc much easier.


```shell
export HOMEBREW_NO_AUTO_UPDATE=1

brew install glibc
brew install --force-bottle xz
brew install gcc
brew install gcc@9

brew install perl

# Downloads
brew install stow
curl -L https://raw.githubusercontent.com/wang-q/dotfiles/master/download.sh | bash

bash ~/Scripts/dotfiles/install.sh

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

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
brew install htop screen

```

### Other brew packages

The failed compilation package was installed with `--force-bottle`.

```shell

# python
brew install python # is now python@3.11

# fontconfig
## Build fontconfig need GLIBC_2.18
brew install $( brew deps fontconfig )
brew install fontconfig

# gd
brew install $( brew deps gd )
brew install gd

# gtk stuffs
brew install glib
brew install libX11 --force-bottle
brew install cairo

# linked to brewed glibc
brew reinstall -s libffi

brew install gobject-introspection
brew install harfbuzz
brew install pango

brew install shared-mime-info
brew install gdk-pixbuf
brew install librsvg

## Qt
#brew install --force-bottle systemd
#brew install --force-bottle libdrm
#brew install --force-bottle wayland
#brew install --force-bottle $( brew deps mesa ) # tons of X11 related deps
#brew unlink llvm
#brew unlink gcc@11
#brew install --force-bottle mesa
#brew install --force-bottle p11-kit # Test failed
#brew install --force-bottle pulseaudio
#
#brew install $( brew deps qt@5 )
#brew install qt@5
##brew install qt

# Java
brew install $( brew deps openjdk )
brew install openjdk --force-bottle
brew install ant maven

# graphics
brew install $( brew deps ghostscript )
brew install ghostscript

brew install $( brew deps imagemagick )
brew install imagemagick

# others
brew install bats-core

brew install lua
brew install pandoc gifsicle
brew install aria2 wget
brew install parallel pigz pv
brew install jq pup datamash miller

brew install node --force-bottle
bash ~/Scripts/dotfiles/nodejs/install.sh

# Packages written in Rust are installed by cargo

# dazz
brew install brewsci/science/poa
brew install wang-q/tap/faops
brew install --HEAD wang-q/tap/dazz_db
brew install --HEAD wang-q/tap/daligner
brew install wang-q/tap/intspan

brew install wang-q/tap/tsv-utils

```

### R Packages

```shell
# nloptr need `cmake`
#ln -s /usr/bin/cmake3 ~/bin/cmake

# brew unlink libxml2

# Can't use brewed libxml2
Rscript -e ' install.packages(
    "XML",
    repos="http://mirrors.ustc.edu.cn/CRAN",
    configure.args = "--with-xml-config=/usr/bin/xml2-config",
    configure.vars = "CC=gcc"
    ) '

## manually
#curl -L https://mirrors.ustc.edu.cn/CRAN/src/contrib/XML_3.99-0.9.tar.gz |
#    tar xvz
#cd XML
#./configure --with-xml-config=/usr/bin/xml2-config
#CC=gcc R CMD INSTALL . --configure-args='--with-xml-config=/usr/bin/xml2-config'

# export PKG_CONFIG_PATH="/usr/lib64/pkgconfig/"
# pkg-config --cflags libxml-2.0
# pkg-config --libs libxml-2.0
Rscript -e ' install.packages(
    "xml2",
    repos="http://mirrors.ustc.edu.cn/CRAN",
    configure.vars = "CC=gcc INCLUDE_DIR=/usr/include/libxml2 LIB_DIR=/usr/lib64"
    ) '

bash ~/Scripts/dotfiles/r/install.sh

# fonts
Rscript -e 'library(remotes); options(repos = c(CRAN = "http://mirrors.ustc.edu.cn/CRAN")); remotes::install_version("Rttf2pt1", version = "1.3.8")'
Rscript -e '
    library(extrafont);
    options(repos = c(CRAN = "http://mirrors.ustc.edu.cn/CRAN"));
    font_import(prompt = FALSE);
    fonts();
    '

# anchr
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = FALSE)) { install.packages("{}", repos="http://mirrors.ustc.edu.cn/CRAN") } '\''
    ' ::: \
        argparse minpack.lm \
        ggplot2 scales viridis

# bmr
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { install.packages("{}", repos="http://mirrors.ustc.edu.cn/CRAN") } '\''
    ' ::: \
        getopt foreach doParallel \
        extrafont ggplot2 gridExtra \
        survival survminer \
        timeROC pROC verification \
        tidyverse devtools BiocManager

# BioC packages
Rscript -e 'BiocManager::install(version = "3.17", ask = FALSE)'
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { BiocManager::install("{}", version = "3.17") } '\''
    ' ::: \
        Biobase GEOquery GenomicDataCommons

# raster, classInt and spData need gdal
# units needs udunit2
# ranger, survminer might need a high version of gcc

```

### Old Homebrew gcc

* This gist <https://gist.github.com/warking/c9a9e6fb5938fbe8ff20>
* Use system gcc to build glibc@2.13 and glibc
* Use bottled gcc@5
    * gcc `make bootstrap` requires `crti.o`. This seems to be a bug
    * `util-linux` don't work with brewed glibc

```shell
export HOMEBREW_NO_AUTO_UPDATE=1

# System gcc-4.8
ln -s $(which gcc) $(brew --prefix)/bin/gcc-$(gcc -dumpversion | cut -d. -f1,2)
ln -s $(which g++) $(brew --prefix)/bin/g++-$(g++ -dumpversion | cut -d. -f1,2)
ln -s $(which gfortran) $(brew --prefix)/bin/gfortran-$(gfortran -dumpversion | cut -d. -f1,2)

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

# Avoid installing ruby
brew install --force-bottle util-linux

# Homebrew gcc-5
brew install --force-bottle gcc@5

#which gcc-5 | xargs realpath | xargs ldd
#        linux-vdso.so.1 (0x00007ffdddb6e000)
#        libm.so.6 => /share/home/wangq/.linuxbrew/lib/libm.so.6 (0x00007f8d5c55c000)
#        libc.so.6 => /share/home/wangq/.linuxbrew/lib/libc.so.6 (0x00007f8d5c3c0000)
#        /share/home/wangq/.linuxbrew/lib/ld.so (0x00007f8d5c659000)

#which gcc-4.8 | xargs realpath | xargs ldd
#        linux-vdso.so.1 =>  (0x00007ffcbc5e4000)
#        libm.so.6 => /lib64/libm.so.6 (0x00007fa167155000)
#        libc.so.6 => /lib64/libc.so.6 (0x00007fa166d87000)
#        /lib64/ld-linux-x86-64.so.2 (0x00007fa167457000)

```

## My modules

```shell

# for benchamrk
brew install jrunlist
brew install jrange

# Manually
dotfiles/genomics.sh

brew install wang-q/tap/mash@2.3

#brew install numpy --force-bottle
#brew install scipy --force-bottle
#brew install matplotlib --force-bottle
##brew install brewsci/bio/kat --force-bottle # boost 1.75 no longer exists

# egaz
curl -fsSL https://raw.githubusercontent.com/wang-q/App-Egaz/master/share/check_dep.sh |
    bash

# anchr
curl -fsSL https://raw.githubusercontent.com/wang-q/anchr/main/templates/install_dep.sh | bash

brew install --HEAD wang-q/tap/fastk
brew install --HEAD wang-q/tap/merquryfk
brew install wang-q/tap/bifrost@1.0.6

curl -fsSL https://raw.githubusercontent.com/wang-q/anchr/main/templates/check_dep.sh | bash

# leading assemblers
brew install spades
spades.py --test
brew install brewsci/bio/megahit
brew install wang-q/tap/platanus

# quast, assembly quality assessment
# https://github.com/ablab/quast/issues/140
brew install brewsci/bio/quast --HEAD
quast --test

rm -fr test_data quast_test_output

#pip3 install quast
#curl -L quast.sf.net/test_data.tar.gz |
#    tar xvz
#quast.py --test
#

# KAT igvtools

# Reinstall R modules missing from the previous steps

# can be built by gcc-4
Rscript -e 'library(remotes); options(repos = c(CRAN = "http://mirrors.ustc.edu.cn/CRAN")); remotes::install_version("ranger", version = "0.14.1")'
Rscript -e 'library(remotes); options(repos = c(CRAN = "http://mirrors.ustc.edu.cn/CRAN")); remotes::install_version("RcppTOML", version = "0.1.7")'

```

## .ssh

```shell
cp -R /mnt/c/Users/wangq/.ssh/ ~/

chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/known_hosts

```

## Mirror to remote server

```shell
export HPCC=58.213.64.36
export PORT=8804
#export HPCC=202.119.37.253
#export PORT=22

# ssh-copy-id

# CentS
rsync -avP -e "ssh -p ${PORT}" ~/bin/ wangq@${HPCC}:bin

rsync -avP -e "ssh -p ${PORT}" ~/share/gnuplot/ wangq@${HPCC}:share/gnuplot
rsync -avP -e "ssh -p ${PORT}" ~/share/graphviz/ wangq@${HPCC}:share/graphviz

rsync -avP -e "ssh -p ${PORT}" ~/share/Perl/ wangq@${HPCC}:share/Perl
rsync -avP -e "ssh -p ${PORT}" ~/share/Python/ wangq@${HPCC}:share/Python

rsync -avP -e "ssh -p ${PORT}" ~/.cargo/ wangq@${HPCC}:.cargo
rsync -avP -e "ssh -p ${PORT}" ~/.nwr/ wangq@${HPCC}:.nwr

rsync -avP -e "ssh -p ${PORT}" ~/.TinyTeX/ wangq@${HPCC}:.TinyTeX
rsync -avP -e "ssh -p ${PORT}" ~/.fonts/ wangq@${HPCC}:.fonts

# CentH
rsync -avP -e "ssh -p ${PORT}" ~/homebrew/ wangq@${HPCC}:homebrew

rsync -avP -e "ssh -p ${PORT}" ~/share/R/ wangq@${HPCC}:share/R

rsync -avP -e "ssh -p ${PORT}" ~/.bashrc wangq@${HPCC}:.bashrc
rsync -avP -e "ssh -p ${PORT}" ~/.bash_profile wangq@${HPCC}:.bash_profile

# Sync back
rsync -avP -e "ssh -p ${PORT}" wangq@${HPCC}:share/ ~/share
rsync -avP -e "ssh -p ${PORT}" wangq@${HPCC}:bin/ ~/bin

```
