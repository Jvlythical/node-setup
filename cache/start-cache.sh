if [ -z $NODE_NAMESPACE ]; then
	echo "NODE_NAMESPACE is not set."
	exit
fi

name=$NODE_NAMESPACE-cache
echo "Creating $name"
docker run -d --network docker-internal --name $name -m 64m memcached 
