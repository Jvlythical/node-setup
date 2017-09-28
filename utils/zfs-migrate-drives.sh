cd ..

mv drives drives.bak
zfs create kodethon/production/drives

cd drives.bak
for f in *; do
	echo "Creating zfs dataset kodethon/production/drives/$f"
	zfs create kodethon/production/drives/$f

	echo "Setting 10G quota for zfs dataset kodethon/production/drives/$f"
	zfs set quota=10G kodethon/production/drives/$f

	for v in $f/*; do
		echo "Moving $v to ../drives/$f"
		mv $v ../drives/$f
	done
done
