#!/bin/bash

#
# chmod devenv directories and files
#

. ~/devenv/scripts/chmod-devenv.sh

echo "#"
echo "# update /etc/hosts"
echo "#"

cat <<EOF >> /etc/hosts
#192.168.0.1   host host.localdomain gateway gateway.localdomain
#192.168.0.20  repo0 repo0.localdomain
#192.168.0.21  repo1 repo1.localdomain
#192.168.0.22  repo2 repo2.localdomain
#192.168.0.50  dev0 dev0.localdomain
#192.168.0.51  dev1 dev1.localdomain
#192.168.0.52  dev2 dev2.localdomain
#192.168.0.53  dev3 dev3.localdomain
#192.168.0.54  dev4 dev4.localdomain
#192.168.0.55  dev5 dev5.localdomain
#192.168.0.56  dev6 dev6.localdomain
#192.168.0.57  dev7 dev7.localdomain
#192.168.0.58  dev8 dev8.localdomain
#192.168.0.59  dev9 dev9.localdomain
#192.168.0.250 node node.localdomain
EOF
echo ""

# reference: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-managing_users_and_groups
echo "#"
echo "# change minimum uid and gid for non-system users"
echo "#"

sed -i 's/^UID_MIN.*/UID_MIN                  5000/' /etc/login.defs
sed -i 's/^GID_MIN.*/GID_MIN                  5000/' /etc/login.defs
echo ""

# reference: https://www.altaro.com/hyper-v/centos-linux-hyper-v
echo "#"
echo "# enable dynamic memory"
echo "#"

cat <<EOF > /etc/udev/rules.d/dev-env.rules
SUBSYSTEM=="memory", ACTION=="add", ATTR{state}="online"
EOF
echo ""

# reference: https://www.altaro.com/hyper-v/centos-linux-hyper-v
echo "#"
echo "# change disk I/O scheduler"
echo "#"

echo noop > /sys/block/sda/queue/scheduler
echo ""

# reference: https://www.altaro.com/hyper-v/centos-linux-hyper-v
echo "#"
echo "# update yum"
echo "#"

yum -y update
yum -y upgrade
yum clean all
echo ""

# reference: https://www.altaro.com/hyper-v/centos-linux-hyper-v
echo "#"
echo "# install hyperv-daemons"
echo "#"

yum -y install hyperv-daemons
echo ""

# reference: https://access.redhat.com/solutions/58790
echo "#"
echo "# install advanced-configuration-and power-interface (acpi) daemon"
echo "#"

yum -y install acpid
systemctl enable acpid
echo ""

# reference: https://cyruslab.net/2014/07/11/installing-netstat-on-centos-7-minimal-installation
echo "#"
echo "# install net-tools and bind-tools (dns)"
echo "#"

yum -y install net-tools
yum -y install bind-utils
echo ""

# reference: https://www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation/3/#C15
echo "#"
echo "# install wget"
echo "#"

yum -y install wget
echo ""

# reference: https://www.tecmint.com/how-to-enable-epel-repository-for-rhel-centos-6-5/
echo "#"
echo "# enable epel repository for yum (needed fot bash-completion-extras"
echo "#"

wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum -y update
yum -y upgrade
yum clean all
rm -f epel-release-latest-7.noarch.rpm
echo ""

# reference: https://www.altaro.com/hyper-v/centos-linux-hyper-v
# reference: https://linux.die.net/man/1/nano
echo "#"
echo "# install nano"
echo "#"

yum -y install nano
echo ""

# reference: https://linux.die.net/man/1/mailx
echo "#"
echo "# install mailx client for sendmail messages"
echo "#"

yum -y install mailx
echo ""

echo "#"
echo "# install auto-completion for bash"
echo "#"

yum -y install bash-completion bash-completion-extras
echo ""

echo "#"
echo "# install git"
echo "#"

yum -y install git
echo ""

# reference: https://www.tecmint.com/set-accurate-server-time-in-centos/
echo "#"
echo "# install ntp and ntpdate"
echo "#"

yum -y install ntp ntpdate
ntpdate -u -s 0.centos.pool.ntp.org 1.centos.pool.ntp.org 2.centos.pool.ntp.org
systemctl enable ntpd
systemctl start ntpd
hwclock -w
echo ""

# reference: https://www.howtoforge.com/tutorial/setting-up-an-nfs-server-and-client-on-centos-7/
echo "#"
echo "# install NFS server"
echo "#"

yum -y install nfs-utils
echo ""

# reference: https://www.howtoforge.com/tutorial/setting-up-an-nfs-server-and-client-on-centos-7/
echo "#"
echo "# open firewall ports for NFS"
echo "#"

firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --reload
echo ""

# reference: https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-on-a-vps
echo "#"
echo "# setup cron jobs"
echo "#"

cat <<EOF > /var/spool/cron/root
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
MAILTO=root

@reboot if [ -f /root/.devenv_init ]; then . /root/.devenv_init; fi
@reboot /usr/sbin/ntpd -gq
@dayly /usr/sbin/ntpd -gq
EOF
chmod 600 /var/spool/cron/root
echo ""

# taint
date > ~/devenv/taints/installed-centos
