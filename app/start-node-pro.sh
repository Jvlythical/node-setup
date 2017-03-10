if [ -z $CDE_NODE_NAMESPACE ]; then
	echo "Namespace not specified, please set CDE_NODE_NAMESPACE"
	exit
fi

name=$CDE_NODE_NAMESPACE-node
if [ -z $1 ]; then
	echo "Suffix not specified, container will be called $name"
else
	name=$name-$1	
fi

if [ -z $CDE_NODE_CONTAINER_PROXY ]; then
	echo "CDE_NODE_CONTAINER_PROXY not set."
	exit
fi

master_ip_addr=$MASTER_IP_ADDR
if [ -z $MASTER_IP_ADDR ]; then
	master_ip_addr='76.20.12.203'
  echo "Master ip addr not specified.  Default to $master_ip_addr"
fi

master_port=$MASTER_PORT
if [ -z $MASTER_PORT ]; then
  master_port=3000
  echo "Master port not specified.  Default to $master_port"
fi

if [ -z $CDE_NODE_HOST ]; then
  echo "Host not specified."
  exit 
fi

http_port=$CDE_NODE_PORT
if [ -z $CDE_NODE_PORT ]; then
  http_port=2375
  echo "Host port not specified.  Default to $http_port"
fi

# Check where user files should be put
if [ -z $CDE_NODE_DRIVES ]; then 
  echo 'CDE_NODE_DRIVES is not set.'
  exit
fi

# Check where private files should be put
if [ -z $CDE_NODE_SYSTEM ]; then 
  echo 'CDE_NODE_SYSTEM is not set.'
  exit
fi

if [ -z $CDE_GROUP_PASSWORD ]; then
  echo 'CDE_GROUP_PASSWORD is not set.'
  exit
fi

if [ -z $CDE_NODE_APP_TYPE ]; then
	echo 'CDE_NODE_APP_TYPE is not set.'
	exit
fi

www_data_home=/var/www
rails_root=/usr/share/nginx/html

# Should be path user files
host_drives_root=$CDE_NODE_DRIVES
container_drives_root=$rails_root/private/drives

# Should be path to private dir
host_system_root=$CDE_NODE_SYSTEM
container_system_root=$rails_root/private/system

# Docker 
docker='/var/run/docker.sock'
docker_group='docker'
docker_gid=$(getent group docker | grep -Eo '[0-9]*')

touch "logs/$name.log"
docker run -d  -h "$(uname -n)" --name $name \
--link $CDE_NODE_NAMESPACE-cache:memcache \
-v $host_drives_root:$container_drives_root \
-v $host_system_root:$container_system_root \
-v $(pwd)/share:$rails_root/public/share \
-v $(pwd)/backup:$rails_root/private/backup \
-v $(pwd)/settings.yml:$rails_root/config/settings.yml \
-v $docker:/var/run/docker.sock -v $(pwd)/logs/$name.log:$rails_root/log/production.log \
-v $(pwd)/rsa_1024_priv.pem:$www_data_home/rsa_1024_priv.pem  -v $(pwd)/rsa_1024_pub.pem:$www_data_home/rsa_1024_pub.pem \
-v /usr/lib/x86_64-linux-gnu/libapparmor.so.1:/usr/lib/x86_64-linux-gnu/libapparmor.so.1 \
-e "HOST_IP_ADDR=$CDE_NODE_HOST" -e "CONTAINER_PROXY=$CDE_NODE_CONTAINER_PROXY" \
-e "HOST_SYSTEM_ROOT=$host_system_root" -e "HOST_DRIVES_ROOT=$host_drives_root" \
-e "HOST_PORT=$http_port" -e "GROUP_PASSWORD=$CDE_GROUP_PASSWORD" \
-e "MASTER_IP_ADDR=$master_ip_addr" -e "MASTER_PORT=$master_port" -e "APP_TYPE=$CDE_NODE_APP_TYPE" \
-e "SELF_SYSTEM_ROOT=$container_system_root" -e "SELF_DRIVES_ROOT=$container_drives_root" \
jvlythical/cde-node:v0.9.1-alpha sh -c "groupadd $docker_group -g $docker_gid; usermod -aG $docker_group www-data; /sbin/run.sh"

# cd /usr/share/nginx/html; export SECRET_KEY_BASE=\$(RAILS_ENV=production rake secret);
#(nohup /sbin/my_init &);
#-v $(which docker):/usr/bin/docker

#-v $CDE_NODE_SRC:/root/cde-node -v $CDE_NODE_HOME_CONF:$www_data_home/.config \
