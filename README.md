## Getting Started

Please refer to <a href="https://docs.kodethon.com/advanced/custom.html" target="blank">Kodethon Docs</a>.

## Usage

### Init
Starts Kodethon node(s), load-balancer, memcache, RabitMQ, CDE-Sentinel, and reverse-proxy.
``` 
sh init.sh NUM_NODES
cd reverse-proxy; sh start-reverse-proxy.sh
```

### Update
Updates the nodes to a new build.
```
sh migrate.sh
```

### Revive
After server reboot, bring the nodes back alive.
```
sh revive.sh
```
