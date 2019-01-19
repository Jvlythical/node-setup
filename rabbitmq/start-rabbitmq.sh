if [ -z $(ls ../config/env.yml 2> /dev/null) ]; then
        echo 'Please create config/env.yml'
        exit
else
        # Export ENV variables
        export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)
fi

if [ -z $NODE_NAMESPACE ]; then
	echo "NODE_NAMESPACE is not set."
	exit
fi

user=$RABBITMQ_DEFAULT_USER
if [ -z $user ]; then
	user=guest
fi
password=$RABBITMQ_DEFAULT_PASS
if [ -z $password ]; then
	password=guest
fi

name=$NODE_NAMESPACE-rabbitmq
echo "Creating $name"
docker run -d --network docker-internal -p 15672:15672 \
	-e RABBITMQ_DEFAULT_USER=$user -e RABBITMQ_DEFAULT_PASS=$password \
	--name $name rabbitmq:3-management
sleep 1
ip_addr=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $name)
echo "IP Address: $ip_addr"
