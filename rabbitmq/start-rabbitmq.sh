if [ -z $NODE_NAMESPACE ]; then
	echo "NODE_NAMESPACE is not set."
	exit
fi

name=$NODE_NAMESPACE-rabbitmq
echo "Creating $name"
docker run -d --network docker-internal --name $name rabbitmq
sleep 1
ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $name)
echo "IP Address: $ip_addr"
