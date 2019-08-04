#!/bin/bash

DISK_USAGE_BEFORE_CLEANUP=$(df -h)

echo "==> Cleaning up tmp"
rm -rf /tmp/*

# Clean up log files
find /var/log -type f \
    | while read f;
    do
        echo -ne '' > "${f}";
    done;

echo "==> Whiteout root"
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$((count - 1))
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
rm /tmp/whitespace

# This is for Ubuntu:
# https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one
echo "==> Zero disk"
dd if=/dev/zero of=/EMPTY bs=1M || echo "dd exit code $? is suppressed"
rm -f /EMPTY

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync

echo "==> Disk usage before cleanup"
echo "${DISK_USAGE_BEFORE_CLEANUP}"

echo "==> Disk usage after cleanup"
df -h
