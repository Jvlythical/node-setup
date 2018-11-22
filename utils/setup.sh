sdb_exists=$(lsblk | grep sdb)
if [ -z "$sdb_exists" ]; then
        echo 'sdb does not exist.'
        exit
fi

sdc_exists=$(lsblk | grep sdc)
if [ -z "$sdc_exists" ]; then
        echo 'sdc does not exist.'
        exit
fi

# Create kodethon user
sudo useradd -m kodethon
usermod -aG sudo kodethon
echo 'kodethon ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers

# Install ZFS
sudo apt install -y zfsutils-linux 
sudo zpool create -f zpool-docker /dev/sdb 
sudo zfs create -o mountpoint=/var/lib/docker zpool-docker/docker
sudo zpool create -f kodethon /dev/sdc
sudo zfs create -o mountpoint=/home/kodethon/production kodethon/production
sudo zfs create -o mountpoint=/home/kodethon/production/drives kodethon/production/drives
sudo zfs create -o mountpoint=/home/kodethon/production/system kodethon/production/system
sudo chown -R kodethon:kodethon /home/kodethon/production

# Install applicaiton files
cd /home/kodethon/production && \
        sudo -u kodethon git clone https://github.com/Jvlythical/node-setup.git && \
        sudo -u kodethon mv node-setup/.* node-setup/* . && sudo rm -rf node-setup 

# Install Docker
sudo apt-get update
sudo apt-get install -y     apt-transport-https     ca-certificates     curl     software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
sudo apt-get update
apt-cache docker-ce
apt-cache madison docker-ce
sudo apt-get install -y docker-ce=17.09.0~ce-0~ubuntu
sudo usermod -aG docker kodethon

# Update docker config to use zfs storage driver
echo "{\n\"storage-driver\": \"zfs\"\n}" | sudo tee /etc/docker/daemon.json

echo 'Creating zfs drives...'
cd utils/zfs; sudo sh create_drives.sh; sudo sh update-zfs-settings.sh;

echo 'Updating system settings...'
cd ..; sudo sh etc/update-kernel-settings.sh

cd ~; rm -rf node-setup
sudo su - kodethon
