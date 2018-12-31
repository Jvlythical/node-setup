if [ -z $(ls ../config/env.yml 2> /dev/null) ]; then
        echo 'Please create config/env.yml'
        exit
else
        # Export ENV variables
        export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)
fi

docker run -d --name datadog-agent \
  --network docker-internal \
  -v $(pwd)/conf.yaml:/etc/datadog-agent/conf.d/mcache.d/auto_conf.yaml \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  -e DD_API_KEY=$DATADOG_API_KEY \
  -e DD_APM_ENABLED=true \
  -e DD_APM_NON_LOCAL_TRAFFIC=true \
  datadog/agent:latest
