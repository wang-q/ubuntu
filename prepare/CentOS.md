# CentOS 7

For HPCC in NJU

# Install

```bash
wget -N https://mirrors.nju.edu.cn/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso

```

Let Parallels use the express installation. Customize the VM before installation as 4 cores and 4GB RAM.

SSH in as `root`.

# Change the Home directory

`usermod` is the command to edit an existing user. `-d` (abbreviation for `--home`) will change the
user's home directory. Adding `-m` (abbreviation for `--move-home` will also move the content from
the user's current directory to the new directory.

```bash
pkill -KILL -u wangq

# Change the Home directory
mkdir -p /share/home
usermod -m -d /share/home/wangq wangq

# Development Tools
yum -y groupinstall 'Development Tools'
yum -y install curl file git vim

```

# Install Linuxbrew without sudo

* SSH in as `wangq`

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

# can't sudo
# Ctrl+D to install linuxbrew to PATH=$HOME/.linuxbrew
# RETURN to start installation

echo >> ~/.bashrc
echo '# HOMEBREW' >> ~/.bashrc
/share/home/wangq/.linuxbrew/bin/brew shellenv >> ~/.bashrc
echo 'export HOMEBREW_NO_ANALYTICS=1' >> ~/.bashrc
echo 'export HOMEBREW_NO_AUTO_UPDATE=1' >> ~/.bashrc

source ~/.bashrc

```

* Test your installation:

```bash
brew install hello
brew test hello
brew remove hello
```

# Sudo

```bash
usermod -aG wheel wangq
visudo
```

# Mirror to remote server

```bash
rsync -avP ~/.linuxbrew/ wangq@202.119.37.251:.linuxbrew
rsync -avP ~/share/ wangq@202.119.37.251:share
rsync -avP ~/bin/ wangq@202.119.37.251:bin
rsync -avP ~/.bashrc wangq@202.119.37.251:.bashrc
rsync -avP ~/.bash_profile wangq@202.119.37.251:.bash_profile

```
