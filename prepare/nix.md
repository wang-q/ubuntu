# nix

```shell
curl -LO \
    https://github.com/DavHau/nix-portable/releases/download/v010/nix-portable

chmod +x nix-portable

curl -L https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m) > ./nix-portable

chmod +x ./nix-portable
./nix-portable

./nix-portable nix --version
# nix (Nix) 2.20.6

./nix-portable nix-channel --update

./nix-portable nix-shell -p bash

export NIXPKGS_ALLOW_UNFREE=1

```
