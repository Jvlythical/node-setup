#!/usr/bin/env bash

# Change ZFS settings at runtime.
#
# To make these changes permanent, it is recommended that you:
# 1. Create the file /etc/modprobe.d/zfs.conf.
# 2. update initramfs
# 3. Reboot?
#
# Run this script as sudo.

# Change the IO Scheduler.
# This ensures that the cgroup block weight settings are enforced.
printf 'cfq' > /sys/module/zfs/parameters/zfs_vdev_scheduler
cat /sys/module/zfs/parameters/zfs_vdev_scheduler

# Make changes permanent
if [ ! -f "zfs.conf" ]; then
    echo "zfs.conf not found!"
		exit 1
fi
if [ ! -d "/etc/modprobe.d" ]; then
    echo "/etc/modprobe.d not found!"
		exit 1
fi
mv zfs.conf /etc/modprobe.d
if [ ! -f "/etc/modprobe.d/zfs.conf" ]; then
    echo "/etc/modprobe.d/zfs.conf not found!"
		exit 1
fi
chown root:root /etc/modprobe.d/zfs.conf

