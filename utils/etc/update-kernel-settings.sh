echo "vm.dirty_bytes = 314572800" >> /etc/sysctl.conf
echo "vm.dirty_background_bytes = 10485760" >> /etc/sysctl.conf
/sbin/sysctl vm.dirty_bytes=314572800
/sbin/sysctl vm.dirty_background_bytes=10485760

