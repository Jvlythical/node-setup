echo "Expecting user to have sudo permission, is that ok?"
sudo echo '' > /dev/null

# Export ENV variables
export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' env.yml)

# Notify master that we are updating
curl --data "ip_addr=$NODE_HOST&port=$NODE_PORT"  https://$MASTER_IP_ADDR:$MASTER_PORT/application/lock_node
echo ''

if [ -z $NODE_NAMESPACE ]; then
	echo "NODE_NAMESPACE is not set."
	exit
fi
lb_name=$NODE_NAMESPACE-load-balancer
temp_node=$NODE_NAMESPACE-node-temp

# Start a temp node container
docker start $temp_node
sleep 1
temp_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $temp_node)
echo "Starting backup node with ip addr: $tmp_ip_addr"
if [ -z "$(docker ps | grep $temp_node)" ]; then
	echo 'No backup node available, starting one...'
	cd app; sh driver.sh temp; cd ..
	sleep 5
	temp_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $temp_node)
fi
cd load-balancer; cat default.conf > default.conf.bak
s="\tserver $temp_ip_addr fail_timeout=30;\n"
sed -e "s/__MARKER__/$s/" template.conf > default.conf
cd ..
docker exec $lb_name service nginx reload

# Get number of containers
key=$NODE_NAMESPACE-node
max=$(docker ps | grep "$key" | wc | awk '{print $1}')
max=$((max - 1))
s='' # Keeps track of new ip addresses

# For each container...
for i in `seq 1 $max`
do
	#container=$(docker ps | grep "$key" | awk "FNR == $i {print}" | awk '{print $1}')
	container=$NODE_NAMESPACE-node-$i
	old_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $container)
	
	echo "Stopping $container..."
	docker stop $container
	docker rm $container
	# $1 is the fully qualified docker image name of the cde-node
	cd app; sh driver.sh $i $1; cd ..
	sleep 5
	new_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $container)

	echo "Old ip addr: $old_ip_addr - New ip addr: $new_ip_addr"
	s="$s\tserver $new_ip_addr fail_timeout=30;\n"
	#echo "Replacing $old_ip_addr with $new_ip_addr"
	#sed -i -e "s/$old_ip_addr/$new_ip_addr/g" load-balancer/default.conf
done

#seed=$NODE_NAMESPACE-node-1
#old_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $seed)
#echo "Stopping $seed..."
#docker stop $seed
#docker rm $seed
#cd app; sh driver.sh 1 $1; cd ..
#sleep 5
#new_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $seed)
#echo "Old ip addr: $old_ip_addr - New ip addr: $new_ip_addr"

#echo "Replacing $old_ip_addr with $new_ip_addr"
#sed -i -e "s/$old_ip_addr/$new_ip_addr/g" load-balancer/default.conf

cd load-balancer
#cat backup.conf > default.conf
sed -e "s/__MARKER__/$s/" template.conf > default.conf
docker exec $lb_name service nginx reload
#rm backup.conf
cd ..

# Start a new backup node
docker rm -f $temp_node
cd app; sh driver.sh temp; cd ..
sleep 5
docker stop $temp_node

# All done, remove backup
cd load-balancer; rm default.conf.bak; cd ..

# Finish up, reload nginx
#docker restart $lb_name
#docker exec $lb_name service nginx reload
#docker exec $lb_name service nginx stop
#sleep 5
#docker start $lb_name
