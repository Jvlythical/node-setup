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

key=$NODE_NAMESPACE-node

# Get number of containers
max=$(docker ps | grep "$key" | wc | awk '{print $1}')

for i in `seq 2 $max`
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
	#echo "Replacing $old_ip_addr with $new_ip_addr"
	#sed -i -e "s/$old_ip_addr/$new_ip_addr/g" load-balancer/default.conf

done

seed=$NODE_NAMESPACE-node-1
old_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $seed)
echo "Stopping $seed..."
docker stop $seed
docker rm $seed
cd app; sh driver.sh 1 $1; cd ..
sleep 5
new_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $seed)
echo "Old ip addr: $old_ip_addr - New ip addr: $new_ip_addr"
#echo "Replacing $old_ip_addr with $new_ip_addr"
#sed -i -e "s/$old_ip_addr/$new_ip_addr/g" load-balancer/default.conf

# Finish up, reload nginx
#docker restart $lb_name
#docker exec $lb_name service nginx reload
#docker exec $lb_name service nginx stop
#sleep 5
#docker start $lb_name
