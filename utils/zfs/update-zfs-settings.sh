#!/usr/bin/env bash

# Change ZFS settings at runtime.
#
# To make these changes permanent, it is recommended that you:
# 1. Create the file /etc/modprobe.d/zfs.conf.
# 2. update initramfs
#
# Run this script as sudo.

# Adjust IO scheduler
printf 'noop' | sudo tee /sys/module/zfs/parameters/zfs_vdev_scheduler

# This should be auto-adjusted by ZFS?
#printf 'noop' | sudo tee /sys/block/<device>/queue/scheduler

# Adjust ARC size while running
echo "2147483648" | sudo tee /sys/module/zfs/parameters/zfs_arc_max
echo "536870912" | sudo tee /sys/module/zfs/parameters/zfs_arc_min

# Add optimizations
echo "1" | sudo tee /sys/module/zfs/parameters/zfs_prefetch_disable
echo "0" | sudo tee /sys/module/zfs/parameters/zfs_per_txg_dirty_frees_percent

# Make changes permanent
if [ ! -f "zfs.conf" ]; then
	echo "zfs.conf not found!"
	exit 1
fi

if [ ! -d "/etc/modprobe.d" ]; then
	echo "/etc/modprobe.d not found!"
	exit 1
fi

cp zfs.conf /etc/modprobe.d
if [ ! -f "/etc/modprobe.d/zfs.conf" ]; then
	echo "/etc/modprobe.d/zfs.conf not found!"
	exit 1
fi
chown root:root /etc/modprobe.d/zfs.conf

update-initramfs -u -k all
