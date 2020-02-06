#!/bin/bash

echo "#"
echo "# Create a user/group for the 'atlas' file share"
echo "#"

if ! getent passwd atlas >/bin/null ; then
    # create user
    NEWUID=50000
    while getent passwd $NEWUID >/bin/null ; do
        NEWUID=$(( NEWUID + 1 ))
    done
    useradd -u $NEWUID -M -s /sbin/nologin atlas
fi
getent passwd atlas
groups atlas
getent group atlas
echo ""

# reference: https://www.howtoforge.com/tutorial/setting-up-an-nfs-server-and-client-on-centos-7/
echo "#"
echo "# Create and export the 'atlas' file share"
echo "#"

systemctl enable nfs-server.service
systemctl start nfs-server.service

mkdir -p /var/nfs/atlas   # file share for chartmuseum
chown nfsnobody:nfsnobody /var/nfs
chmod 755 /var/nfs
chown atlas:atlas /var/nfs/atlas
chmod 775 /var/nfs/atlas

if ! grep '/var/nfs/atlas' /etc/exports >/bin/null ; then
    cat <<EOF >> /etc/exports
/var/nfs/atlas   repo0(rw,sync,no_subtree_check)
/var/nfs/atlas   node(rw,sync,no_subtree_check)
EOF
fi
exportfs -a
echo ""

# for client to connect to NFS server:
# - add client to /etc/exports and run exportfs (see above)
# - on client:
#     yum -y install nfs-utils
#     mkdir -p /mnt/nfs/atlas
#     mount repo0:/var/nfs/atlas /mnt/nfs/atlas
#     chgrp atlas

echo "#"
echo "# Create storageClass and persistentVolume"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/atlas/nfs-atlas
echo "#"

# taint
date > ~/devenv/taints/installed-nfs-atlas
