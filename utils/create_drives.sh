cat drives.txt | xargs -i zfs create kodethon/production/drives/{}
cat drives.txt | xargs -i zfs create kodethon/production/system/{}
