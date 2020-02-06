#!/bin/bash

echo "#"
echo "# stop firewall"
echo "#"

systemctl stop firewalld
systemctl status firewalld
echo ""

# taint
date > ~/devenv/taints/stopped-firewall
