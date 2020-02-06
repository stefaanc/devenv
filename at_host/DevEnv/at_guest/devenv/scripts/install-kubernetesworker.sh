#!/bin/bash

echo "#"
echo "# !!! master node will also be a worker !!!"
echo "#"
echo ""

# reference: https://kubernetes.io/docs/setup/independent/install-kubeadm//#check-required-ports
# reference: https://stackoverflow.com/questions/24729024/open-firewall-port-on-centos-7
# reference: https://github.com/coreos/flannel/blob/master/Documentation/troubleshooting.md#firewalls
echo "#"
echo "# Open firewall ports for worker node"
echo "#"

firewall-cmd --permanent --zone=public --add-port=8472/udp        # flannel vxlan backend
firewall-cmd --permanent --zone=public --add-port=10250/tcp       # kubelet
firewall-cmd --permanent --zone=public --add-port=30000-32767/tcp # Kubernetes NodePort Services
firewall-cmd --reload
echo ""

# reference: https://kubernetes.io/docs/setup/independent/install-kubeadm/#before-you-begin
# reference: https://www.tecmint.com/disable-swap-partition-in-centos-ubuntu
echo "#"
echo "# Disable swap"
echo "#"

sed -i 's+/dev/mapper/centos.*-swap+# &+g' /etc/fstab
mount -a
echo ""

# reference: https://kubernetes.io/docs/setup/independent/install-kubeadm
echo "#"
echo "# Set SELinux in permisive mode"
echo "#"

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
echo ""

# reference: https://kubernetes.io/docs/setup/independent/install-kubeadm
echo "#"
echo "# Prepare sysctl config"
echo "#"

cat <<EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
echo ""

# reference: https://kubernetes.io/docs/setup/cri
echo "#"
echo "# Prepare CRI"
echo "#"

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker
echo ""

# reference: https://github.com/coreos/flannel/issues/799
# reference: https://www.freedesktop.org/software/systemd/man/systemd.service.html
echo "#"
echo "# restore flannel config after docker restart"
echo "#"


mkdir -p /opt/docker/systemd/
cat <<EOF > /opt/docker/systemd/restore-devenv-flannel.sh
#!/bin/bash

firewall-cmd --permanent --direct --add-passthrough ipv4 -I FORWARD 1 -i cni0 -j ACCEPT -m comment --comment "flannel subnet"
firewall-cmd --permanent --direct --add-passthrough ipv4 -I FORWARD 1 -o cni0 -j ACCEPT -m comment --comment "flannel subnet"
firewall-cmd --permanent --direct --add-passthrough ipv4 -t nat -A POSTROUTING -s 10.244.0.0/16 ! -d 10.244.0.0/16 -j MASQUERADE
firewall-cmd --reload
EOF
chmod +755 /opt/docker/systemd/restore-devenv-flannel.sh
sed -i 's+^ExecStart=.*$+&\nExecStartPost=/opt/docker/systemd/restore-devenv-flannel.sh+' /usr/lib/systemd/system/docker.service
/opt/docker/systemd/restore-devenv-flannel.sh
echo ""

# reference: https://kubernetes.io/docs/setup/independent/install-kubeadm
echo "#"
echo "# Install kubelet and kubeadm"
echo "#"

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
yum install -y kubelet kubeadm --disableexcludes=kubernetes
systemctl enable kubelet
systemctl start kubelet
echo ""

# taint
date > ~/devenv/taints/installed-kubernetesworker
