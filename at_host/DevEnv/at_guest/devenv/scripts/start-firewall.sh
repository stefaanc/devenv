#!/bin/bash

echo "#"
echo "# start firewall"
echo "#"

systemctl start firewalld
systemctl status firewalld
echo ""

# reference: https://success.docker.com/article/why-am-i-having-network-problems-after-firewalld-is-restarted
echo "#"
echo "# restart docker"
echo "#"

systemctl restart docker
echo ""

# taint
date > ~/devenv/taints/started-firewall
