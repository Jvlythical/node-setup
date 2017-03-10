if [ -z $CDE_NODE_NAMESPACE ]; then
	echo "Namespace not specified, please set CDE_NODE_NAMESPACE"
	exit
fi

name=$CDE_NODE_NAMESPACE-cache
echo "Creating $name"
docker run -d --name $name -m 64m memcached 
