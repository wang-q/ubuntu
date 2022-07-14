# nix

## Installation

```shell
curl -L -o nix-user-chroot \
    https://github.com/nix-community/nix-user-chroot/releases/download/1.2.2/nix-user-chroot-bin-1.2.2-x86_64-unknown-linux-musl

mv nix-user-chroot ~/bin
chmod +x ~/bin/nix-user-chroot

mkdir -m 0755 ~/.nix
nix-user-chroot ~/.nix bash -c "curl -L https://nixos.org/nix/install | bash"

#mkdir ~/.nix
#export PROOT_NO_SECCOMP=1
#proot -b ~/.nix:/nix
#export PROOT_NO_SECCOMP=1
#curl -L https://nixos.org/nix/install | sh


```

## Usage

`/nix` is owned by your user.

```shell
nix-user-chroot ~/.nix bash -l

nix --version
#nix (Nix) 2.10.1

```
