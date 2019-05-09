#if [ -z $CDE_NODE_IMAGE ]; then
#	echo "CDE_NODE_IMAGE is not set."
#	exit
#fi

if [ -z $NODE_NAMESPACE ]; then
	echo "NODE_NAMESPACE is not set."
	exit
fi

name=$NODE_NAMESPACE-node
if [ -z $1 ]; then
	echo "Suffix not specified, container will be called $name"
else
	name=$name-$1	
fi

docker_image_name=$2
if [ -z $2 ]; then
	docker_image_name='jvlythical/cde-node:1.4.2-rc'
fi


master_ip_addr=$MASTER_IP_ADDR
if [ -z $MASTER_IP_ADDR ]; then
	master_ip_addr='76.20.12.203'
  echo "MASTER_IP_ADDR is not set. Default to $master_ip_addr"
fi

master_port=$MASTER_PORT
if [ -z $MASTER_PORT ]; then
  master_port=3000
  echo "MASTER_PORT is not set. Default to $master_port"
fi

master_password=$MASTER_PASSWORD
if [ -z $MASTER_PASSWORD ]; then
  master_password=abc123
  echo "MASTER_password is not set. Default to $master_password"
fi

if [ -z $NODE_HOST ]; then
  echo "NODE_HOST is not set."
  exit 
fi

http_port=$NODE_PORT
if [ -z $NODE_PORT ]; then
  http_port=2375
  echo "NODE_PORT is not set. Default to $http_port"
fi

# Check where user files should be put
if [ -z $NODE_DRIVES ]; then 
  echo 'NODE_DRIVES is not set.'
  exit
fi

# Check where private files should be put
if [ -z $NODE_SYSTEM ]; then 
  echo 'NODE_SYSTEM is not set.'
  exit
fi

if [ -z $GROUP_PASSWORD ]; then
  echo 'GROUP_PASSWORD is not set.'
  exit
fi

if [ -z $NODE_APP_TYPE ]; then
	echo 'NODE_APP_TYPE is not set.'
	exit
fi

www_data_home=/var/www
rails_root=/usr/share/nginx/html

# Should be path user files
host_drives_root=$NODE_DRIVES
container_drives_root=$rails_root/private/drives

# Should be path to private dir
host_system_root=$NODE_SYSTEM
container_system_root=$rails_root/private/system

# Docker 
docker='/var/run/docker.sock'
docker_group='docker'
docker_gid=$(getent group docker | grep -Eo '[0-9]*' | head -n 1)

# Create logs folder
mkdir logs 2> /dev/null
production_log=production.log
touch "logs/$name.$production_log" 2> /dev/null
puma_stdout=puma.stdout.log
touch "logs/$name.$puma_stdout" 2> /dev/null
puma_stderr=puma.stderr.log
touch "logs/$name.$puma_stderr" 2> /dev/null

if [ -z  $(sudo ls /root/.ssh/id_rsa.pub) ]; then
	# Create root public/private key
    echo "Create root public/private key..."
    sudo -u root ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
fi

# Let's go
docker run -d  -h "$(uname -n)" --name $name \
--network docker-internal \
-v /root/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
-v $host_drives_root:$container_drives_root:shared \
-v $host_system_root:$container_system_root \
-v $(pwd)/share:$rails_root/public/share \
-v $(pwd)/sync:$rails_root/public/sync \
-v $(pwd)/backup:$rails_root/private/backup \
-v $(pwd)/../config/settings.yml:$rails_root/config/settings.yml \
-v $docker:/var/run/docker.sock -v $(pwd)/logs/$name.$production_log:$rails_root/log/$production_log \
-v $(pwd)/logs/$name.$puma_stdout:$rails_root/log/$puma_stdout \
-v $(pwd)/logs/$name.$puma_stderr:$rails_root/log/$puma_stderr \
-v $(pwd)/rsa_1024_priv.pem:$www_data_home/rsa_1024_priv.pem  -v $(pwd)/rsa_1024_pub.pem:$www_data_home/rsa_1024_pub.pem \
-v /usr/lib/x86_64-linux-gnu/libapparmor.so.1:/usr/lib/x86_64-linux-gnu/libapparmor.so.1 \
-e "HOST_IP_ADDR=$NODE_HOST" -e "IS_HTTPS=true" -e "RAILS_ENV=production" \
-e "HOST_SYSTEM_ROOT=$host_system_root" -e "HOST_DRIVES_ROOT=$host_drives_root" \
-e "HOST_PORT=$http_port" -e "GROUP_PASSWORD=$GROUP_PASSWORD" -e "MASTER_PASSWORD=$master_password" \
-e "MASTER_IP_ADDR=$master_ip_addr" -e "MASTER_PORT=$master_port" -e "APP_TYPE=$NODE_APP_TYPE" \
-e "SELF_SYSTEM_ROOT=$container_system_root" -e "SELF_DRIVES_ROOT=$container_drives_root" \
-e "MEMCACHE_HOSTNAME=$NODE_NAMESPACE-cache" -e "RABBITMQ_HOSTNAME=$NODE_NAMESPACE-rabbitmq" \
$docker_image_name sh -c "groupadd $docker_group -g $docker_gid; usermod -aG $docker_group www-data; /sbin/run.sh"

# Ensure log folder has proper permissions
docker exec $name chown -R www-data:www-data log

# cd /usr/share/nginx/html; export SECRET_KEY_BASE=\$(RAILS_ENV=production rake secret);
#(nohup /sbin/my_init &);
#-v $(which docker):/usr/bin/docker

#-v $CDE_NODE_SRC:/root/cde-node -v $CDE_NODE_HOME_CONF:$www_data_home/.config \

#--link $NODE_NAMESPACE-cache:memcache \
#--link $NODE_NAMESPACE-rabbitmq:rabbitmq \
