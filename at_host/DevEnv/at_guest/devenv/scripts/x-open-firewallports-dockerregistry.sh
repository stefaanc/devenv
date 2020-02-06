#!/bin/bash

echo "#"
echo "# Open firewall ports for docker-registry"
echo "#"

firewall-cmd --permanent --zone=public --add-port=30443/tcp
firewall-cmd --reload
echo ""

# taint
date > ~/devenv/taints/opened-firewallports-dockerregistry
