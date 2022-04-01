# CentOS 7

For HPCC in NJU

# Install

```shell
# wget -N https://mirrors.nju.edu.cn/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-DVD-1908.iso

wget -N https://mirrors.nju.edu.cn/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso

```

Let Parallels use the express installation. Customize the VM before installation as 4 cores, 4GB
RAM, and 64G disk. Remove all unnecessary devices, e.g. printer, camera, or sound card.

Change the VM to Bridged Network (Default Adapter)

SSH in as `root`.

# Change the Home directory

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
yum -y groupinstall 'Compatibility Libraries'
yum install glibc-devel.x86_64 libgcc.x86_64 libstdc++-devel.x86_64 ncurses-devel.x86_64
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
yum-config-manager --disable city-fan.org

yum --enablerepo=city-fan.org install -y libcurl libcurl-devel

curl --version
# curl 7.82.0

# https://github.com/Linuxbrew/legacy-linuxbrew/issues/46#issuecomment-308758171
yum remove yum-utils

# libs
yum install -y libdb4-devel libdb4-utils

```

# Install Linuxbrew without sudo

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

# Sudo

We *must* install Homebrew as a non-sudoer.

```shell
usermod -aG wheel wangq
visudo

# wangq  ALL=(ALL) NOPASSWD:ALL

```

# Packages

* Build from sources for all dependcies of gcc

* Use bottled gcc@11 and gcc@5
    * gcc@5 `make bootstrap` requires `crti.o`. This seems to be a bug

* Build core libraries from sources

```shell

export HOMEBREW_NO_AUTO_UPDATE=1

# gcc@5
brew install --build-from-source zlib
brew install --build-from-source binutils
brew install --build-from-source linux-headers@4.4
brew install --build-from-source m4
brew install --build-from-source gmp
brew install --build-from-source mpfr
brew install --build-from-source libmpc
brew install --build-from-source isl@0.18

brew install --build-from-source glibc

brew install --build-from-source isl
brew install --build-from-source gpatch
brew install --build-from-source pkg-config
brew install --build-from-source ncurses

brew install --force-bottle gcc@5

brew install --build-from-source openssl@1.1
brew install cmake
brew install --build-from-source zstd

# # find /usr/ -name crt*
# sudo ln -s /usr/lib64/crt1.o /usr/lib/crt1.o
# sudo ln -s /usr/lib64/crti.o /usr/lib/crti.o
# sudo ln -s /usr/lib64/crtn.o /usr/lib/crtn.o

brew install --force-bottle gcc@11

# alias gcc='gcc-5'
# alias cc='gcc-5'
# alias g++='g++-5'
# alias c++='c++-5'
# alias gfortran='gfortran-5'

# python
brew install --build-from-source gdbm
brew install --build-from-source berkeley-db

brew install --build-from-source berkeley-db@4

brew install --build-from-source libffi
brew install --build-from-source readline
brew install --build-from-source bison

brew install --build-from-source bzip2
brew install --build-from-source xz
brew install --build-from-source sqlite
brew install --build-from-source mpdecimal

brew install --build-from-source python@3.7
brew unlink python@3.7 && brew link --force --overwrite python@3.7

if grep -q -i PYTHON_37_PATH $HOME/.bashrc; then
    echo "==> .bashrc already contains PYTHON_37_PATH"
else
    echo "==> Updating .bashrc with PYTHON_37_PATH..."
    PYTHON_37_PATH="export PATH=\"$(brew --prefix)/opt/python@3.7/bin:$(brew --prefix)/opt/python@3.7/libexec/bin:\$PATH\""
    echo '# PYTHON_37_PATH' >> $HOME/.bashrc
    echo ${PYTHON_37_PATH} >> $HOME/.bashrc
    echo >> $HOME/.bashrc

    # make the above environment variables available for the rest of this script
    eval ${PYTHON_37_PATH}
fi

brew install --build-from-source expat
brew install --build-from-source unzip

brew install --build-from-source python

# curl
brew install --build-from-source brotli
brew install --build-from-source libssh2
brew install --build-from-source libnghttp2
brew install --build-from-source rtmpdump

brew install --build-from-source libunistring
brew install --build-from-source libidn2

brew install --build-from-source libxml2
brew install --build-from-source gettext
brew install --build-from-source krb5

# brew install ruby
brew install --force-bottle util-linux
brew install --build-from-source openldap
brew install --build-from-source curl

# perl
echo "==> Install Perl 5.34"
brew install --build-from-source perl

if grep -q -i PERL_534_PATH $HOME/.bashrc; then
    echo "==> .bashrc already contains PERL_534_PATH"
else
    echo "==> Updating .bashrc with PERL_534_PATH..."
    PERL_534_BREW=$(brew --prefix)/Cellar/$(brew list --versions perl | sed 's/ /\//' | head -n 1)
    PERL_534_PATH="export PATH=\"$PERL_534_BREW/bin:\$PATH\""
    echo '# PERL_534_PATH' >> $HOME/.bashrc
    echo $PERL_534_PATH    >> $HOME/.bashrc
    echo >> $HOME/.bashrc

    # make the above environment variables available for the rest of this script
    eval $PERL_534_PATH
fi

hash cpanm 2>/dev/null || {
    curl -L https://cpanmin.us |
        perl - -v --mirror-only --mirror http://mirrors.ustc.edu.cn/CPAN/ App::cpanminus
}

brew install --build-from-source autoconf
brew install --build-from-source automake
brew install --build-from-source libtool

# fontconfig
brew install --build-from-source gperf
brew install --build-from-source json-c

brew install --build-from-source libpng
brew install --build-from-source jpeg
brew install --build-from-source libtiff
brew install --build-from-source freetype

brew install --build-from-source fontconfig

# gd
brew install --build-from-source giflib
brew install --build-from-source webp
brew install --build-from-source nasm
brew install --build-from-source yasm
brew install aom
brew install --build-from-source libavif
brew install --build-from-source gd

# libs
brew install --build-from-source gsl
brew install --build-from-source libgit2
brew install --build-from-source libgcrypt
brew install --build-from-source libxslt

# java
brew install --build-from-source openjdk

# r
brew install --build-from-source r

# Test your installation
brew install hello
brew test hello

# bash-completion
brew unlink util-linux
brew install --build-from-source bash-completion

cat <<EOF >> ~/.bashrc

# bash-completion
[[ -r "$HOME/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "$HOME/.linuxbrew/etc/profile.d/bash_completion.sh"

EOF

```

# Mirror to remote server

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

