cd ..
mv drives drives.bak
ls drives.bak | xargs -I{} sudo zfs create kodethon/production/drives/{}
ls drives.bak | xargs -I{} sudo zfs set quota=10G kodethon/production/drives/{}

cd drives.bak
for f in *; do
	for v in $f/*; do
		echo "Moving $v to ../drives/$f"
		mv $v ../drives/$f
	done
done
