#!/bin/bash

echo "#"
echo "# Create a user/group for the 'depot' file share"
echo "#"

if ! getent passwd depot >/bin/null ; then
    # create user
    NEWUID=50000
    while getent passwd $NEWUID >/bin/null ; do
        NEWUID=$(( NEWUID + 1 ))
    done
    useradd -u $NEWUID -M -s /sbin/nologin depot
fi
getent passwd depot
groups depot
getent group depot
echo ""

# reference: https://www.howtoforge.com/tutorial/setting-up-an-nfs-server-and-client-on-centos-7/
echo "#"
echo "# Create and export the 'depot' file share"
echo "#"

systemctl enable nfs-server.service
systemctl start nfs-server.service

mkdir -p /var/nfs/depot   # file share for depot
chown nfsnobody:nfsnobody /var/nfs
chmod 755 /var/nfs
chown depot:depot /var/nfs/depot
chmod 775 /var/nfs/depot

if ! grep '/var/nfs/depot' /etc/exports >/bin/null ; then
    cat <<EOF >> /etc/exports
/var/nfs/depot   repo0(rw,sync,no_subtree_check)
/var/nfs/depot   node(rw,sync,no_subtree_check)
EOF
fi
exportfs -a
echo ""

# for client to connect to NFS server:
# - add client to /etc/exports and run exportfs (see above)
# - on client:
#     yum -y install nfs-utils
#     mkdir -p /mnt/nfs/depot
#     mount repo0:/var/nfs/depot /mnt/nfs/depot
#     chgrp depot

echo "#"
echo "# Create storageClass and persistentVolume"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/depot/nfs-depot
echo "#"

# taint
date > ~/devenv/taints/installed-nfs-depot
