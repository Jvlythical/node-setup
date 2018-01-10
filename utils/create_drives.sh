cd ../drives && cat ../utils/drives.txt | xargs -i zfs create kodethon/production/drives/{}
cd ../drives && cat ../utils/drives.txt | xargs -i zfs create kodethon/production/system/{}
