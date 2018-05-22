echo "vm.dirty_bytes = 314572800" >> /etc/sysctl.conf
echo "vm.dirty_background_bytes = 10485760" >> /etc/sysctl.conf
/sbin/sysctl vm.dirty_bytes=314572800
/sbin/sysctl vm.dirty_background_bytes=10485760

# Adjust ZFS arc size for future
echo "options zfs zfs_arc_max=2147483648" >> /etc/modprobe.d/zfs.conf
echo "options zfs zfs_arc_min=536870912" >> /etc/modprobe.d/zfs.conf

# Adjust it while running
echo "2147483648" | sudo tee /sys/module/zfs/parameters/zfs_arc_max
echo "536870912" | sudo tee /sys/module/zfs/parameters/zfs_arc_min
update-initramfs -u -k all

# Adjust IO scheduler
#printf 'noop' | sudo tee /sys/block/<device>/queue/scheduler

# Adjust ZFS internal scheduler
printf 'cfq' | sudo tee /sys/module/zfs/parameters/zfs_vdev_scheduler
