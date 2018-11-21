## Description

The Kodethon cluster consists of a master server(s) and slave server(s). This repository holds configuration files and scripts for preparing and adding a slave server to the Kodethon cluster.

## Getting Started

Please refer to <a href="https://docs.kodethon.com/advanced/custom.html" target="blank">Kodethon Docs</a>.

## Setup

### Run
sh utils/setup.sh
cd utils/zfs; sh create_drives.sh; sh zfs.sh
cd utils; sh update-kernele-settings.sh

### Edit
config/settings.yml
config/env.yml


## Usage

### Init
Starts Kodethon node(s), load-balancer, memcache, RabitMQ, CDE-Sentinel, and reverse-proxy containers.
``` 
sh init.sh NUM_NODES
cd reverse-proxy; sh start-reverse-proxy.sh
```

### Update
Updates the node containers to a new build.
```
sh migrate.sh
```

### Revive
After server reboot, bring containers back alive.
```
sh revive.sh
```
