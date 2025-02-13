# CentOS 7

<!-- TOC -->
* [CentOS 7](#centos-7)
  * [Install the system](#install-the-system)
    * [In WSL](#in-wsl)
    * [In VMware/Parallels](#in-vmwareparallels)
  * [As `root`](#as-root)
    * [Install libraries](#install-libraries)
    * [Change the Home directory](#change-the-home-directory)
    * [Sudo](#sudo)
    * [Change the hostname](#change-the-hostname)
    * [Backup WSL](#backup-wsl)
  * [CentS](#cents)
    * [Perl, Python, R, and Rust with system `libc`](#perl-python-r-and-rust-with-system-libc)
    * [Gnuplot and graphviz](#gnuplot-and-graphviz)
    * [Perl modules](#perl-modules)
    * [SRA Toolkit](#sra-toolkit)
    * [hmmer, diamond and blast](#hmmer-diamond-and-blast)
    * [spades](#spades)
    * [Rust and .nwr](#rust-and-nwr)
    * [Backup WSL](#backup-wsl-1)
  * [CentH](#centh)
    * [gcc and commonly used libraries](#gcc-and-commonly-used-libraries)
    * [Other brew packages](#other-brew-packages)
    * [R Packages](#r-packages)
    * [Backup WSL](#backup-wsl-2)
  * [My modules](#my-modules)
  * [.ssh](#ssh)
  * [Mirror to remote server](#mirror-to-remote-server)
<!-- TOC -->

We will build several VMs here:

1. `centos.tar` - a VM exported from docker images

2. `centos.root.tar` - Mimic after the HPCC of NJU; wangq as the default user

3. `CentS` - system gcc and yum packages, linked to the system libc
    * `Perl`
    * `Python`
    * A minimal `R`
    * `rustup`
        * Homebrew bottled rust packages can't be used as they need GLIBC 2.18

4. `CentH` - everything else in Homebrew is linked to the brewed glibc
    * `R` compiled by gcc@9

## Install the system

### In WSL

This one is prefered.

https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro

* Install Docker Desktop on Windows
    * Use WSL 2
    * Settings -> Resources -> WSL integration -> Tick Ubuntu

```bash
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

```bash
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

```bash
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

```bash
yum install passwd sudo -y

myUsername=wangq
adduser -G wheel $myUsername
echo -e "[user]\ndefault=$myUsername" >> /etc/wsl.conf
echo -e "[interop]\nappendWindowsPath=false" >> /etc/wsl.conf
passwd $myUsername

```

```bash
pkill -KILL -u wangq

# Change the Home directory
mkdir -p /share/home
usermod -m -d /share/home/wangq wangq

```

### Sudo

We *must* install Homebrew as a non-sudoer.

This is *not* a necessary step.

```bash
usermod -aG wheel wangq
visudo

# wangq  ALL=(ALL) NOPASSWD:ALL

```

### Change the hostname

Can't change hostname inside WSL

```bash
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

We will build the VM (almost all in share/) with system gcc and yum packages, linked to the system
libc

```powershell
wsl --import CentS $HOME\VM\CentS $HOME\VM\centos.root.tar

wsl -d CentS

```

CentOS Vault

```bash
minorver=7.9.2009
sudo sed -e "s|^mirrorlist=|#mirrorlist=|g" \
         -e "s|^#baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=https://mirrors.cernet.edu.cn/centos-vault/$minorver|g" \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

sudo sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel-archive/|g' \
    -e 's|^#baseurl=https\?://download.example/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel-archive/|g' \
    -i.bak \
    /etc/yum.repos.d/epel.repo

sudo yum makecache

```


### Perl, Python, R, and Rust with system `libc`

All following binaries are built with system `gcc` and linked to the system `libc`.

Avoid using graphic, gtk and x11 packages in brew.

```bash
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

```bash
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

```bash

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

### SRA Toolkit

```bash
cd

# SRA Toolkit
curl -LO https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.5/sratoolkit.3.0.5-centos_linux64.tar.gz

tar -xvzf sratoolkit*.tar.gz --wildcards "*/bin/*"
rm -fr sratoolkit*/bin/ncbi
cp sratoolkit*/bin/* ~/bin/

rm -fr sratoolkit*

```

### hmmer, diamond and blast

```bash
cd

curl -LO http://eddylab.org/software/hmmer/hmmer-3.4.tar.gz

tar -xvzf hmmer-3.4.tar.gz
cd hmmer-3.4
./configure \
    --enable-threads \
    --enable-sse \
    --enable-lfs \
    --disable-altivec \
    --prefix=$HOME

make
make install

curl -LO https://github.com/bbuchfink/diamond/releases/download/v2.1.9/diamond-linux64.tar.gz

tar xvfz diamond-linux64.tar.gz
mv diamond ~/bin

curl -LO https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.15.0/ncbi-blast-2.15.0+-x64-linux.tar.gz

tar xvfz ncbi-blast-*.tar.gz
mv ncbi-blast-2.15.0+/bin/* ~/bin/

```

### spades

CMake 3.16 or higher

SPAdes requires gcc version 9.1 or later

```bash
cd

curl -LO https://github.com/Kitware/CMake/releases/download/v3.31.5/cmake-3.31.5-linux-x86_64.tar.gz
tar xvfz cmake-3*.tar.gz
mv cmake-3.31.5-linux-x86_64 ~/share/cmake
ln -sf ~/share/cmake/bin/cmake ~/bin/cmake

```

```bash
#cd
#
##curl -LO https://github.com/ablab/spades/releases/download/v4.0.0/SPAdes-4.0.0-Linux.tar.gz
#
#curl -LO https://github.com/ablab/spades/releases/download/v4.0.0/SPAdes-4.0.0.tar.gz
#
#tar xvfz SPAdes-4*.tar.gz
#cd SPAdes-4*
#
#./spades_compile.sh
#
#mv SPAdes-4.0.0-Linux ~/share/SPAdes
#
#ln -sf ~/share/SPAdes/bin/spades.py ~/bin/spades.py
#
#spades.py --test

```

### Rust and .nwr

```bash
cd

mkdir ~/.nwr

# Put the files of appropriate time into this directory
cp /mnt/c/Users/wangq/.nwr/* ~/.nwr/

cd ~/Scripts/nwr
cargo install --path . --force

```

### Backup WSL

```powershell
wsl --terminate CentS

wsl --export CentS $HOME\VM\CentS.tar

```

## CentH

Homebrew

```powershell
# wsl --unregister CentH

wsl --import CentH $HOME\VM\CentH $HOME\VM\centos.root.tar
# wsl --import CentH D:\VM\CentH D:\VM\centos.root.tar

wsl -d CentH

```

```bash
WINDOWS_HOST=192.168.32.1
export ALL_PROXY="socks5h://${WINDOWS_HOST}:7890" HTTP_PROXY="http://${WINDOWS_HOST}:7890" HTTPS_PROXY="http://${WINDOWS_HOST}:7890" RSYNC_PROXY="${WINDOWS_HOST}:7890"

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
    echo 'eval "$($HOME/homebrew/bin/brew shellenv)"' >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source $HOME/.bashrc

```

### gcc and commonly used libraries

* Homebrew 4.0 brings glibc-bootstrap, which makes installing glibc and gcc much easier.

```bash
export HOMEBREW_NO_AUTO_UPDATE=1

brew install glibc
brew link glibc --force

if grep -q -i BREW_GLIBC $HOME/.bashrc; then
    echo "==> .bashrc already contains BREW_GLIBC"
else
    echo "==> Update .bashrc"

    echo >> $HOME/.bashrc
    echo '# BREW_GLIBC' >> $HOME/.bashrc
    echo 'export PATH="$HOME/homebrew/opt/glibc/bin:$PATH"' >> $HOME/.bashrc
    echo 'export PATH="$HOME/homebrew/opt/glibc/sbin:$PATH"' >> $HOME/.bashrc
    echo 'export LDFLAGS="-L$HOME/homebrew/opt/glibc/lib $LDFLAGS"' >> $HOME/.bashrc
    echo 'export CFLAGS="-I$HOME/homebrew/opt/glibc/include $CFLAGS"' >> $HOME/.bashrc
    echo 'export CPPFLAGS="-I$HOME/homebrew/opt/glibc/include $CPPFLAGS"' >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

brew install xz -s
brew install zstd
brew install gcc # now as gcc@14

brew install binutils
brew link binutils --force

brew install perl

# Downloads
brew install jq
brew install stow -s
brew install parallel
echo "will cite" | parallel --citation

curl -L https://raw.githubusercontent.com/wang-q/dotfiles/master/download.sh | bash

bash ~/Scripts/dotfiles/install.sh

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Some building tools
brew install autoconf libtool automake # autogen
brew install bison flex

# https://docs.brew.sh/FAQ#can-i-edit-formulae-myself
# https://stackoverflow.com/a/75520170/23645669
# https://stackoverflow.com/a/68816241/23645669
export HOMEBREW_NO_INSTALL_FROM_API=1
export HOMEBREW_NO_AUTO_UPDATE=1
mkdir -p $HOME/homebrew/Library/Taps/homebrew/
cd $HOME/homebrew/Library/Taps/homebrew/
rm -rf homebrew-core
git clone --depth=1 https://github.com/Homebrew/homebrew-core.git

# brew tap --force --shallow homebrew/core
brew edit openssl@3
# comment the line of `make test`
brew reinstall openssl@3 -s

brew install cmake

# libs
brew install gsl
brew install libssh2
brew install jemalloc
brew install boost

# python
brew install python # is now python@3.13

```

### Other brew packages

The failed compilation package was installed with `--force-bottle`.

```bash
# fontconfig
brew install util-linux
brew install libpng -s
brew install $( brew deps fontconfig )
brew install fontconfig

# gd
brew install $( brew deps gd )
brew install gd

# gtk stuffs
brew install glib
brew install libX11
brew install cairo

brew reinstall libffi -s

brew install gobject-introspection --force-bottle
brew install harfbuzz
brew install pango

# Java
brew install $( brew deps openjdk )
brew install openjdk --force-bottle
brew install ant maven

# graphics
brew install $( brew deps ghostscript )
brew install ghostscript

brew install $( brew deps imagemagick )
brew install imagemagick

# bwa and gatk
brew install openjdk@17 --force-bottle
brew install python@3.12 --force-bottle
brew install bwa samtools picard-tools
brew install brewsci/bio/gatk

# others
brew install bats-core

brew install lua
brew install pandoc gifsicle
brew install aria2 wget
brew install pigz pv
brew install jq pup datamash

# Packages written in Rust are installed by cargo

# dazz
#brew install brewsci/science/poa
brew install wang-q/tap/faops
brew install wang-q/tap/tsv-utils

```

### R Packages

```bash
## nloptr need `cmake`
##ln -s /usr/bin/cmake3 ~/bin/cmake
#
## brew unlink libxml2
#
## Can't use brewed libxml2
#Rscript -e ' install.packages(
#    "XML",
#    repos="http://mirrors.ustc.edu.cn/CRAN",
#    configure.args = "--with-xml-config=/usr/bin/xml2-config",
#    configure.vars = "CC=gcc"
#    ) '
#
## manually
##curl -L https://mirrors.ustc.edu.cn/CRAN/src/contrib/XML_3.99-0.18.tar.gz |
##    tar xvz
##cd XML
##./configure --with-xml-config=/usr/bin/xml2-config
##CC=gcc R CMD INSTALL . --configure-args='--with-xml-config=/usr/bin/xml2-config'
#
## export PKG_CONFIG_PATH="/usr/lib64/pkgconfig/"
## pkg-config --cflags libxml-2.0
## pkg-config --libs libxml-2.0
#Rscript -e ' install.packages(
#    "xml2",
#    repos="http://mirrors.ustc.edu.cn/CRAN",
#    configure.vars = "CC=gcc INCLUDE_DIR=/usr/include/libxml2 LIB_DIR=/usr/lib64"
#    ) '

brew install r
brew pin r

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

# cellranger
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { install.packages("{}", repos="http://mirrors.ustc.edu.cn/CRAN") } '\''
    ' ::: \
        Seurat dplyr tibble \
        ggplot2 pheatmap \
        ggsci ggrepel \
        viridis devtools NMF \
        tidyr clustree patchwork

# BioC packages
Rscript -e 'BiocManager::install(version = "3.20", ask = FALSE)'
parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { BiocManager::install("{}", version = "3.20") } '\''
    ' ::: \
        Biobase GEOquery GenomicDataCommons

parallel -j 1 -k --line-buffer '
    Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { BiocManager::install("{}", version = "3.20") } '\''
    ' ::: \
        monocle slingshot clusterProfiler org.Hs.eg.db GSVA GSEABase rtracklayer biomaRt harmony infercnv
Rscript -e 'devtools::install_github("cole-trapnell-lab/monocle3")'  #monocle3

# raster, classInt and spData need gdal
# units needs udunits2
# ranger, survminer might need a high version of gcc
# infercnv need jags
# nloptr need nlopt

```

### Backup WSL

```powershell
wsl --terminate CentH

wsl --export CentH $HOME\VM\CentH.tar

```

## My modules

```bash
# Manually
dotfiles/genomics.sh

brew install wang-q/tap/mash@2.3

# egaz
curl -fsSL https://raw.githubusercontent.com/wang-q/App-Egaz/master/share/check_dep.sh |
    bash

# anchr
curl -fsSL https://raw.githubusercontent.com/wang-q/anchr/main/templates/install_dep.sh | bash

brew install wang-q/tap/bifrost@1.3.5

curl -fsSL https://raw.githubusercontent.com/wang-q/anchr/main/templates/check_dep.sh | bash

# leading assemblers
brew install spades
spades.py --test
rm -fr spades_test

brew install brewsci/bio/megahit

# quast, assembly quality assessment
# https://github.com/ablab/quast/issues/140
brew install brewsci/bio/quast --HEAD
quast --test

rm -fr test_data quast_test_output

# Reinstall R modules missing from the previous steps

# can be built by gcc-4
Rscript -e 'library(remotes); options(repos = c(CRAN = "http://mirrors.ustc.edu.cn/CRAN")); remotes::install_version("ranger", version = "0.14.1")'
Rscript -e 'library(remotes); options(repos = c(CRAN = "http://mirrors.ustc.edu.cn/CRAN")); remotes::install_version("RcppTOML", version = "0.1.7")'

```

## .ssh

```bash
cp -R /mnt/c/Users/wangq/.ssh/ ~/

chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/known_hosts

```

## Mirror to remote server

```bash
export HPCC=202.119.37.253
export PORT=22

export HPCC=58.213.64.36
export PORT=8804

# ssh-copy-id

# CentS
rsync -avP -e "ssh -p ${PORT}" ~/bin/ wangq@${HPCC}:bin

rsync -avP -e "ssh -p ${PORT}" ~/share/gnuplot/ wangq@${HPCC}:share/gnuplot
rsync -avP -e "ssh -p ${PORT}" ~/share/graphviz/ wangq@${HPCC}:share/graphviz

rsync -avP -e "ssh -p ${PORT}" ~/share/Perl/ wangq@${HPCC}:share/Perl
rsync -avP -e "ssh -p ${PORT}" ~/share/Python/ wangq@${HPCC}:share/Python

rsync -avP -e "ssh -p ${PORT}" ~/share/as7env/ wangq@${HPCC}:share/as7env

rsync -avP -e "ssh -p ${PORT}" ~/.cargo/ wangq@${HPCC}:.cargo --exclude="*registry/*"
rsync -avP -e "ssh -p ${PORT}" ~/.nwr/ wangq@${HPCC}:.nwr

# CentH
rsync -avP -e "ssh -p ${PORT}" ~/homebrew/ wangq@${HPCC}:homebrew --exclude="*Taps/*"

rsync -avP -e "ssh -p ${PORT}" ~/share/R/ wangq@${HPCC}:share/R

rsync -avP -e "ssh -p ${PORT}" ~/.bashrc wangq@${HPCC}:.bashrc
rsync -avP -e "ssh -p ${PORT}" ~/.bash_profile wangq@${HPCC}:.bash_profile

# Sync back
rsync -avP -e "ssh -p ${PORT}" wangq@${HPCC}:share/ ~/share
rsync -avP -e "ssh -p ${PORT}" wangq@${HPCC}:bin/ ~/bin

rsync -avP -e "ssh -p ${PORT}" wangq@${HPCC}:homebrew/ ~/homebrew
rsync -avP -e "ssh -p ${PORT}" wangq@${HPCC}:share/R/ ~/share/R

```
