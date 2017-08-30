docker ps | grep '\-fs' | awk '{print $1}' | xargs -I % sh -c "docker exec % ls | grep Sync > /dev/null && echo %" > .check-kodrive-tmp

# Stop kodrive for each problematic container
cat .check-kodrive-tmp | xargs -I % docker exec % /home/kodrive/.local/bin/kodrive sys stop

# Clean up kodrive metadata
cat .check-kodrive-tmp | xargs -I % docker exec % sh -c "echo 'Removing metadata...'; rm -rf .config/kodrive; rm -rf .config/syncthing"

# Clean volume
cat .check-kodrive-tmp | xargs -I % docker exec % sh -c "echo 'Removing files...'; rm -rf *"

# Stop container
cat .check-kodrive-tmp | xargs -I % docker stop %


