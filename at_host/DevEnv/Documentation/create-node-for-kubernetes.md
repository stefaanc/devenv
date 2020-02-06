## Create Node For Kubernetes

> **Remark:**
> **The following is based on the Kubernetes version `1.13.1`.  The steps below and the scripts for the Hyper-V guests may need to be adapted when using a different version.**

The steps are:
- [Install Kubernetes](#install-kubernetes)
- [Save Virtual Hard Disk For Kubernetes](#save-virtual-hard-disk-for-kubernetes)

in short:
- run `@ACP_Install-Kubernetes` as an administrator.
- run `@ACP_Save-DevEnv-kubernetes` as administrator.

[Go back to Overview](../README.html#overview)



### Install Kubernetes

> Reference: https://stackoverflow.com/questions/24729024/open-firewall-port-on-centos-7
> Reference: https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports.
> Reference: https://github.com/coreos/flannel/blob/master/Documentation/troubleshooting.md#firewalls
> Reference: https://www.tecmint.com/disable-swap-partition-in-centos-ubuntu
> Reference: https://kubernetes.io/docs/setup/cri
> Reference: https://kubernetes.io/docs/setup/independent/install-kubeadm

In File Explorer on the host, run `@ACP_Install-Kubernetes` as an administrator.
Alternatively, in a PowerShell:
~~~
Install-Kubernetes devenv0
~~~

From the PowerShell terminal, the script will automatically open another terminal for `devenv0`, and run a guest script in it.

- You can find a dump of the PuTTY terminal sessions in the folder `$HOME\DevEnv\Scripts\PuTTY-log``.

[Go to Top](#create-node-for-kubernetes)
[Go back to Overview](../README.html#overview)



### Save Virtual Hard Disk For Kubernetes

At this point we **need** to save the virtual machine's virtual hard disk, so we can clone it to make worker nodes for Kubernetes.

In File Explorer on the host, run `@ACP_Save-DevEnv-kubernetes` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Save-VHD devenv0 kubernetes
~~~

This script creates a virtual hard disk for Kubernetes:
- Virtual Hard Disk: `$HOME\DevEnv\Virtual Hard Disks\kubernetes.vhdx`

> **The Kubernetes installation is complete.**
> You can now restore the virtual machines to this point. See [Restore Kubernetes Node](restore-development-environment-from-virtual-hard-disks.html#restore-kubernetes-node)

[Go to Top](#create-node-for-kubernetes)
[Go back to Overview](../README.html#overview)



### What's Next?

- Go to previous step: [Create Server For Docker](create-server-for-docker.html)
- Go to next step: [Create Cluster For Kubernetes](create-cluster-for-kubernetes.html)

[Go to Top](#create-node-for-kubernetes)
[Go back to Overview](../README.html#overview)
