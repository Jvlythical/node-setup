if [ -z $1 ]; then
	exit
fi

if [ -z $2 ]; then
	exit
fi

cd ..

mv $1 $1.bak
zfs create kodethon/production/$1

cd $1.bak
for f in *; do
	echo "Creating zfs dataset kodethon/production/$1/$f"
	zfs create kodethon/production/$1/$f

	echo "Setting $2 quota for zfs dataset kodethon/production/$1/$f"
	zfs set quota=$2 kodethon/production/$1/$f

	for v in $f/*; do
		echo "Moving $v to ../$1/$f"
		mv $v ../$1/$f
	done
done
