#!/bin/bash

DISK_USAGE_BEFORE_CLEANUP=$(df -h)

echo "==> Clean caches before release"
rm -fr $HOME/.cache/
rm -fr $HOME/.npm/
rm -fr $HOME/.node-gyp/
rm -fr $HOME/.cpan/
rm -fr $HOME/.cpanm/
rm -fr $HOME/.plenv/cache/

brew cleanup
rm -rf $(brew --cache)

echo "==> Clean the Bash history"
cat /dev/null > $HOME/.bash_history

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync
