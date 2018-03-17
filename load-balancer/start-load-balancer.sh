export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../env.yml)

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

name=$NODE_NAMESPACE-load-balancer

docker run -d -p 1337:80 --name $name \
-e "VIRTUAL_HOST=$NODE_HOST"  \
-e "HTTPS_METHOD=noredirect" \
-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf \
-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
nginx

# Add below if using letsencrypt for ssl
#-e "LETSENCRYPT_HOST=$NODE_HOST" \
#-e "LETSENCRYPT_EMAIL=$NODE_OWNER" \

#docker exec $name mkdir /usr/share/nginx/html/public
#docker exec $name certbot certonly --email jvlarble@gmail.com --agree-tos --text --non-interactive --webroot  -w /usr/share/nginx/html/public -d dev.kodethon.com
