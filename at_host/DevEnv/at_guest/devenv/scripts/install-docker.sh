#!/bin/bash

# reference: https://docs.docker.com/install/linux/docker-ce/centos
echo "#"
echo "# Set up the repository"
echo "#"

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo ""

# reference: https://docs.docker.com/install/linux/docker-ce/centos
echo "#"
echo "# Install Docker CE"
echo "#"

yum install -y docker-ce
systemctl start docker
echo ""

# reference: https://docs.docker.com/install/linux/linux-postinstall#configure-docker-to-start-on-boot
echo "#"
echo "# Configure Docker to start on boot"
echo "#"

systemctl enable docker
echo ""

# reference: https://success.docker.com/article/firewalld-problems-with-container-to-container-network-communications
echo "#"
echo "# Configure firewall for ssh from one container to another container on the same node"
echo "#"

firewall-cmd --permanent --zone=trusted --add-interface=docker0
firewall-cmd --permanent --zone=trusted --add-port=4243/tcp
firewall-cmd --reload
echo ""

# for the case where a virtual machine is restored from a virtual hard disk
echo "#"
echo "# Restore docker configuration after restore from virtual hard disk"
echo "#"

cat <<EOF > /etc/sysctl.d/restore-devenv-docker.conf
net.ipv4.ip_forward = 1
EOF
sysctl --system
echo ""

# taint
date > ~/devenv/taints/installed-docker
