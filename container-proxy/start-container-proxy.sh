docker rm -f container-proxy
docker run -d --name container-proxy -p 8080:80 \
	-e "VIRTUAL_HOST=abc123.dev.kodethon.com" \
	-e "CERT_NAME=kodethon.com" \
	-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf nginx

#	-e "LETSENCRYPT_HOST=test3.dev.kodethon.com" \
#	-e "LETSENCRYPT_EMAIL=jvlarble@gmail.com" \

#-e "LETSENCRYPT_HOST=containers.dev.kodethon.com" \
#-e "LETSENCRYPT_EMAIL=jvlarble@gmail.com" \
