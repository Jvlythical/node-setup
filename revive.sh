docker start CDE-rabbitmq
docker start CDE-cache
docker start CDE-node-1
docker start CDE-node-2
docker start CDE-load-balancer
#docker start CDE-sentinel
#docker start CDE-backup
docker start nginx-proxy
docker start datadog-agent
sh migrate.sh
cd lib/CDE-Sentinel; sudo bundle exec rake daemon:zfs:start; sudo bundle exec rake daemon:monitor:start; cd ../..
