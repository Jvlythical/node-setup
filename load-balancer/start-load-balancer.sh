if [ -z $CDE_NODE_NAMESPACE ]; then
	echo "Namespace not specified, please set CDE_NODE_NAMESPACE"
	exit
fi

if [ -z $CDE_NODE_HOST ]; then
	echo "Node host not specified, please set CDE_NODE_HOST"
fi

if [ -z $CDE_NODE_PORT ]; then
	echo "Node port not specified, please set CDE_NODE_PORT"
	exit
fi

if [ -z $CDE_NODE_OWNER ]; then
	echo "Node owner not specified, please set CDE_NODE_OWNER"
fi

name=$CDE_NODE_NAMESPACE-load-balancer

docker run -d -p $CDE_NODE_PORT:80 --name $name \
-e "VIRTUAL_HOST=$CDE_NODE_HOST"  \
-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf \
-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
nginx

# Add below if using letsencrypt for ssl
#-e "LETSENCRYPT_HOST=$CDE_NODE_HOST" \
#-e "LETSENCRYPT_EMAIL=$CDE_NODE_OWNER" \

#docker exec $name mkdir /usr/share/nginx/html/public
#docker exec $name certbot certonly --email jvlarble@gmail.com --agree-tos --text --non-interactive --webroot  -w /usr/share/nginx/html/public -d dev.kodethon.com
