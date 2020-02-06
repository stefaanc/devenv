#!/bin/bash

# reference: https://www.itzgeek.com/how-tos/linux/centos-how-tos/change-hostname-in-centos-7-rhel-7.html
echo "#"
echo "# set the hostname"
echo "#"

SERVERNAME=$( cat ~/devenv/dvd/config | grep HOSTNAME= | awk -F '=' '{ print $2 }' | tr -d "\n" | tr -d "\r" )
hostnamectl set-hostname $SERVERNAME
echo ""

# reference: https://www.altaro.com/hyper-v/ubuntu-linux-server-hyper-v-guest
echo "#"
echo "# rebuild SSH server's host keys."
echo "#"

rm /etc/ssh/ssh_host_*
ssh-keygen -A
echo ""

#  reference: http://www.mustbegeek.com/configure-static-ip-address-in-centos
echo "#"
echo "# update static IP addresses"
echo "#"

BOOTPROTO=$( cat /root/devenv/dvd/config | grep BOOTPROTO= | awk -F '=' '{ print $2 }' | tr -d "\n" | tr -d "\r" )
IPADDR=$( cat /root/devenv/dvd/config | grep IPADDR= | awk -F '=' '{ print $2 }' | tr -d "\n" | tr -d "\r" )
PREFIX=$( cat /root/devenv/dvd/config | grep PREFIX= | awk -F '=' '{ print $2 }' | tr -d "\n" | tr -d "\r" )
GATEWAY=$( cat /root/devenv/dvd/config | grep GATEWAY= | awk -F '=' '{ print $2 }' | tr -d "\n" | tr -d "\r" )
sed -i "s/BOOTPROTO=\".*\"/BOOTPROTO=\"${BOOTPROTO}\"/g" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "s/IPADDR=\".*\"/IPADDR=\"${IPADDR}\"/g" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "s/PREFIX=\".*\"/PREFIX=\"${PREFIX}\"/g" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "s/GATEWAY=\".*\"/GATEWAY=\"${GATEWAY}\"/g" /etc/sysconfig/network-scripts/ifcfg-eth0
sleep 5 # give the network time to start, before restarting
service network restart
echo ""

# remove .devenv_init
rm -f /root/.devenv_init

# taint
DISKNAME=$( find /root/devenv/taints -type f -printf '%T+ %p\n' | sort -r | head -n 1 | awk '{ print substr($2, match($2, "\/[a-zA-Z0-9_\.\-]*$")+14) }' )
date > /root/devenv/taints/restored-devenv-$DISKNAME
