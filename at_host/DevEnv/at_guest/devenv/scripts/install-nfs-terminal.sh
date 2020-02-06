#!/bin/bash

echo "#"
echo "# Create a user/group for the 'terminal' file share"
echo "#"

if ! getent passwd terminal >/bin/null ; then
    # create user
    NEWUID=50000
    while getent passwd $NEWUID >/bin/null ; do
        NEWUID=$(( NEWUID + 1 ))
    done
    useradd -u $NEWUID -M -s /sbin/nologin terminal
fi
getent passwd terminal
groups terminal
getent group terminal
echo ""

# reference: https://www.howtoforge.com/tutorial/setting-up-an-nfs-server-and-client-on-centos-7/
echo "#"
echo "# Create and export the 'terminal' file share"
echo "#"

systemctl enable nfs-server.service
systemctl start nfs-server.service

mkdir -p /var/nfs/terminal   # file share for docker registry
chown nfsnobody:nfsnobody /var/nfs
chmod 755 /var/nfs
chown terminal:terminal /var/nfs/terminal
chmod 775 /var/nfs/terminal

if ! grep '/var/nfs/terminal' /etc/exports >/bin/null ; then
    cat <<EOF >> /etc/exports
/var/nfs/terminal   repo0(rw,sync,no_subtree_check)
/var/nfs/terminal   node(rw,sync,no_subtree_check)
EOF
fi
exportfs -a
echo ""

# for client to connect to NFS server:
# - add client to /etc/exports and run exportfs (see above)
# - on client:
#     yum -y install nfs-utils
#     mkdir -p /mnt/nfs/terminal
#     mount repo0:/var/nfs/terminal /mnt/nfs/terminal
#     chgrp terminal

echo "#"
echo "# Create storageClass and persistentVolume"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/terminal/nfs-terminal
echo "#"

# taint
date > ~/devenv/taints/installed-nfs-terminal
