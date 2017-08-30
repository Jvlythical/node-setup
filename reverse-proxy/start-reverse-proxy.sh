docker rm -f nginx-proxy
docker rm -f letsencrypt

docker run -d -p 80:80 -p 443:443 \
	--name nginx-proxy \
	-v $(pwd)/my_proxy.conf:/etc/nginx/conf.d/my_proxy.conf:ro \
	-v $(pwd)/certs:/etc/nginx/certs:ro \
	-v /etc/nginx/vhost.d \
	-v /usr/share/nginx/html \
	-v /var/run/docker.sock:/tmp/docker.sock:ro \
	jwilder/nginx-proxy

docker run -d \
	--name letsencrypt \
	-v $(pwd)/certs:/etc/nginx/certs:rw \
	--volumes-from nginx-proxy \
	-v /var/run/docker.sock:/var/run/docker.sock:ro \
	jrcs/letsencrypt-nginx-proxy-companion
