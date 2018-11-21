if [ -z $NODE_NAMESPACE ]; then
	echo "NODE_NAMESPACE is not specified."
	exit
fi

if [ -z $NODE_HOST ]; then
	echo "NODE_HOST is not specified."
fi

if [ -z $NODE_PORT ]; then
	echo "NODE_PORT not specified."
	exit
fi

if [ -z $NODE_OWNER ]; then
	echo "NODE_OWNER is not specified."
fi

if [ -z $(ls ../env.yml 2> /dev/null) ]; then
        echo 'Please create config/env.yml'
        exit
else
        # Export ENV variables
        export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../env.yml)
fi

name=$NODE_NAMESPACE-load-balancer
if [ -z $USE_LETSENCRYPT ]; then
	docker run -d -p 1337:80 --name $name \
	-e "VIRTUAL_HOST=$NODE_HOST"  \
	-e "HTTPS_METHOD=noredirect" \
	-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf \
	-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
	nginx
else
	docker run -d -p 1337:80 --name $name \
	-e "VIRTUAL_HOST=$NODE_HOST"  \
	-e "HTTPS_METHOD=noredirect" \
	-e "LETSENCRYPT_HOST=$NODE_HOST" \
	-e "LETSENCRYPT_EMAIL=$NODE_OWNER" \
	-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf \
	-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
	nginx
fi

#docker exec $name mkdir /usr/share/nginx/html/public
#docker exec $name certbot certonly --email jvlarble@gmail.com --agree-tos --text --non-interactive --webroot  -w /usr/share/nginx/html/public -d dev.kodethon.com
