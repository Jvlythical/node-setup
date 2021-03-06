zfs create -o mountpoint=/home/kodethon/production kodethon/production
zfs create kodethon/production/drives
zfs create kodethon/production/system
cat drives.txt | xargs -i zfs create kodethon/production/drives/{}
cat drives.txt | xargs -i zfs create kodethon/production/system/{}

chown www-data:www-data /home/kodethon/production/drives/*
chown www-data:www-data /home/kodethon/production/system/*
