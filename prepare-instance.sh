#!/usr/bin/env bash

set -euo pipefail

echo "### Setting SSH keys for cloning from GitHub started"
echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" >> ~/.ssh/known_hosts
echo "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=" >> ~/.ssh/known_hosts
echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> ~/.ssh/known_hosts
echo "### Setting SSH keys for cloning from GitHub finished"

echo "### Installing packages started"
export DEBIAN_FRONTEND=noninteractive
# removing the needrestart package to prevent service restart prompts during installation
sudo apt purge -y needrestart
sudo apt update
sudo apt install -y docker.io maven vim nmon bmon python3-pip zip silversearcher-ag parallel awscli s4cmd
sudo gpasswd -a ${USER} docker
echo "### Installing packages finished"

echo "### Creating RAID disk started"
export NUM_DISKS=$(lsblk | grep ^nvme[^0] | wc -l)
echo ${NUM_DISKS}
sudo mdadm --create --verbose /dev/md0 --level=0 --name=MY_RAID --raid-devices=${NUM_DISKS} $(seq -f "/dev/nvme%gn1" 1 ${NUM_DISKS}) --force
sudo mkfs.ext4 -L MY_RAID /dev/md0
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm.conf
sudo mkdir -p /data
sudo mount LABEL=MY_RAID /data
sudo bash -c 'echo "LABEL=MY_RAID       /data   ext4    defaults,nofail        0       2" >> /etc/fstab'
sudo mount -a
sudo chown -R ${USER}:${USER} /data
echo "### Creating RAID disk finished"

echo "### Cloning repository started"
cd /data
git clone --branch v1.0.3.1 https://github.com/ldbc/ldbc_snb_bi
echo "### Cloning repository finished"

cd /data/ldbc_snb_bi

echo "### Installing Paramgen dependencies started"
paramgen/scripts/install-dependencies.sh
echo "### Installing Paramgen dependencies finished"

echo "### Installing Umbra dependencies started"
umbra/scripts/install-dependencies.sh
echo "### Installing Umbra dependencies finished"
