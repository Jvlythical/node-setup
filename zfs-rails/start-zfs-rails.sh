sudo -v # Require sudo permission

rails_root=$(pwd)
PUMA_PID_FILE=$rails_root/src/tmp/pids/puma.pid
PUMA_SOCKET=$rails_root/src/tmp/sockets/puma.sock

mkdir -p $rails_root/src/tmp/sockets 2> /dev/null

if [ -f $PUMA_PID_FILE ]; then
	echo 'Stopping zfs-rails...'
	sudo kill -s TERM `cat $PUMA_PID_FILE`
	sudo rm -f $PUMA_PID_FILE
	sudo rm -f $PUMA_SOCKET
fi

cd src; sudo build/run.sh
if [ -z $(ls $rails_root/src/tmp/sockets 2> /dev/null) ]; then
	echo 'Socket does not exist.'
else
	name=zfs-rails
	docker rm -f $name 2> /dev/null
	docker run -d --name $name -v $PUMA_SOCKET:/usr/share/nginx/html/tmp/sockets/puma.sock jvlythical/zfs-rails
fi
