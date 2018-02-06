export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../env.yml)

if [ -z $CDE_NODE_NAMESPACE ]; then
	echo "Namespace not specified, please set CDE_NODE_NAMESPACE"
	exit
fi

name=$CDE_NODE_NAMESPACE-sentinel

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
docker_gid=$(getent group docker | grep -Eo '[0-9]*' | head -n 1)

# Create logs folder
mkdir logs 2> /dev/null
touch "logs/$name.log"

# Let's go
docker run -itd  -h "$(uname -n)" --name $name \
--link $CDE_NODE_NAMESPACE-cache:memcache \
-v $host_drives_root:$container_drives_root \
-v $host_system_root:$container_system_root \
-v $(pwd)/../app/settings.yml:$rails_root/config/settings.yml \
-v $docker:/var/run/docker.sock -v $(pwd)/logs/$name.log:$rails_root/log/production.log \
-v /usr/lib/x86_64-linux-gnu/libapparmor.so.1:/usr/lib/x86_64-linux-gnu/libapparmor.so.1 \
-e "HOST_IP_ADDR=$CDE_NODE_HOST" -e "APP_TYPE=$CDE_NODE_APP_TYPE" \
-e "HOST_SYSTEM_ROOT=$host_system_root" -e "HOST_DRIVES_ROOT=$host_drives_root" \
-e "HOST_PORT=$http_port" -e "GROUP_PASSWORD=$CDE_GROUP_PASSWORD" \
-e "MASTER_IP_ADDR=$master_ip_addr" -e "MASTER_PORT=$master_port" \
-e "SELF_SYSTEM_ROOT=$container_system_root" -e "SELF_DRIVES_ROOT=$container_drives_root" \
jvlythical/cde-sentinel:0.3.0 sh -c "groupadd $docker_group -g $docker_gid; usermod -aG $docker_group www-data; bundle exec whenever -w; service cron restart; /bin/bash"

# cd /usr/share/nginx/html; export SECRET_KEY_BASE=\$(RAILS_ENV=production rake secret);
#(nohup /sbin/my_init &);
#-v $(which docker):/usr/bin/docker

#-v $CDE_NODE_SRC:/root/cde-node -v $CDE_NODE_HOME_CONF:$www_data_home/.config \
