export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config.yml)

if [ -z $CDE_NODE_NAMESPACE ]; then
	echo "Namespace not specified, please set CDE_NODE_NAMESPACE"
	exit
fi

name=$CDE_NODE_NAMESPACE-backup

rails_root=/usr/share/nginx/html

# Should be path user files
host_drives_root=$CDE_NODE_DRIVES
container_drives_root=$rails_root/private/drives

# Should be path to private dir
host_system_root=$CDE_NODE_SYSTEM
container_system_root=$rails_root/private/system

docker_group='docker'
docker_gid=$(getent group docker | grep -Eo '[0-9]*')

docker run -d  -h "$(uname -n)" --name $name \
-v $host_drives_root:$container_drives_root \
-v $host_system_root:$container_system_root \
-v $(pwd)/backup:$rails_root/private/backup \
-v /var/run/docker.sock:/var/run/docker.sock \
jvlythical/cde-backup sh -c "groupadd $docker_group -g $docker_gid; usermod -aG $docker_group www-data; /sbin/run.sh"
