#!/bin/bash

echo "#"
echo "# Open firewall ports for chartmuseum"
echo "#"

firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --reload
echo ""

# taint
date > ~/devenv/taints/opened-firewallports-chartmuseum
