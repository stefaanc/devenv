## Restore Development Environment From Virtual Hard Disks

The options are:
- [Restore CentOS Virtual Machine](#restore-centos-virtual-machine)
- [Restore Docker Server](#restore-docker-server)
- [Restore Kubernetes Node](#restore-kubernetes-node)
- [Restore Kubernetes Cluster](#restore-kubernetes-cluster)

> **Remark:**
> 
> If the saved virtual hard disks were saved from an installation that was following this guide to the letter, then two users were created for this development environment:
> - user `root` with password `rootroot`
> - user `master` with password `mastmast`
> 
> You can change the passwords after completing the restoration.

[Go back to Overview](../README.html#overview)



### Restore CentOS Virtual Machine

In File Explorer on the host, run `@ACP_Restore-DevEnv-centos` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Restore-VMFromVHD devenv0 centos
~~~

From the PowerShell terminal, the script will automatically open a console for the new guest, and run a guest script in it.

- When the prompt to login appears, **login as `root`**.
- You will get the question "What is the number of this VM? devenv[0] >".  Type "0" for a VM with name `devenv0`, or "1" for a VM with name `devenv1`, or "2" for a VM with name `devenv2`, ...  Press "Enter".  Remark that you can see the name of the virtual machine in the top-left corner of the console.
- Close your console.

From the PowerShell terminal, the script will automatically open another terminal for the guest, and run a guest script in it.

- The script uses `putty` and PuTTY's `pscp` commands.  It will ask you `Store key in cache? (y/n)` or `Update cached key? (y/n, Return cancels connection)`.  Type "y".

Optionally, if you have `devenv1` or `devenv2` VMs in your environment, you can in a PowerShell on the host:
~~~
Delete-VM devenv1
Delete-VM devenv2
~~~

> **The CentOS installation is complete.**
>
> You are now ready to continue with one of these options:
>
> - follow the detailed procedure starting from the [Create Server For Docker](create-server-for-docker.html) chapter.
> - follow the fast procedure starting from the [Create Server For Docker](../README.html#create-server-for-docker) step.

[Go to Top](#restore-development-environment-from-virtual-hard-disks)
[Go back to Overview](../README.html#overview)



### Restore Docker Server

In File Explorer on the host, run `@ACP_Restore-DevEnv-docker` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Restore-VMFromVHD devenv0 docker
~~~

From the PowerShell terminal, the script will automatically open a console for the new guest, and run a guest script in it.

- When the prompt to login appears, **login as `root`**.
- You will get the question "What is the number of this VM? devenv[0] >".  Type "0" for a VM with name `devenv0`, or "1" for a VM with name `devenv1`, or "2" for a VM with name `devenv2`, ...  Press "Enter".  Remark that you can see the name of the virtual machine in the top-left corner of the console.
- Close your console.

From the PowerShell terminal, the script will automatically open another terminal for the guest, and run a guest script in it.

- The script uses `putty` and PuTTY's `pscp` commands.  It will ask you `Store key in cache? (y/n)` or `Update cached key? (y/n, Return cancels connection)`.  Type "y".

Optionally, if you have `devenv1` or `devenv2` VMs in your environment, you can in a PowerShell on the host:
~~~
Delete-VM devenv1
Delete-VM devenv2
~~~

> **The Docker installation is complete.**
> 
> You can test the installed components:
>
> - follow [Test Docker](create-server-for-docker.html#test-docker)
> 
> You are now ready to continue with one of these options:
>
> - follow the detailed procedure starting from the [Create Node For Kubernetes](create-node-for-kubernetes.html) chapter.
> - follow the fast procedure starting from the [Create Node For Kubernetes](../README.html#create-node-for-kubernetes) step.

[Go to Top](#restore-development-environment-from-virtual-hard-disks)
[Go back to Overview](../README.html#overview)



### Restore Kubernetes Node

In File Explorer on the host, run `@ACP_Restore-DevEnv-kubernetes` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Restore-VMFromVHD devenv0 kubernetes
~~~

From the PowerShell terminal, the script will automatically open a console for the new guest, and run a guest script in it.

- When the prompt to login appears, **login as `root`**.
- You will get the question "What is the number of this VM? devenv[0] >".  Type "0" for a VM with name `devenv0`, or "1" for a VM with name `devenv1`, or "2" for a VM with name `devenv2`, ...  Press "Enter".  Remark that you can see the name of the virtual machine in the top-left corner of the console.
- Close your console.

From the PowerShell terminal, the script will automatically open another terminal for the guest, and run a guest script in it.

- The script uses `putty` and PuTTY's `pscp` commands.  It will ask you `Store key in cache? (y/n)` or `Update cached key? (y/n, Return cancels connection)`.  Type "y".

Optionally, if you have `devenv1` or `devenv2` VMs in your environment, you can in a PowerShell on the host:
~~~
Delete-VM devenv1
Delete-VM devenv2
~~~

> **The Kubernetes Node installation is complete.**
> 
> You can test the installed components:
>
> - follow [Test Docker](create-server-for-docker.html#test-docker)
> 
> You are now ready to continue with one of these options:
> 
> - follow the detailed procedure starting from the [Create Cluster For Kubernetes](create-cluster-for-kubernetes.html) chapter.
> - follow the fast procedure starting from the [Create Cluster For Kubernetes](../README.html#create-cluster-for-kubernetes) step.

[Go to Top](#restore-development-environment-from-virtual-hard-disks)
[Go back to Overview](../README.html#overview)



### Restore Kubernetes Cluster

In File Explorer on the host, run `@ACP_Restore-DevEnv-cluster` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Restore-VMFromVHD devenv0 cluster-devenv0
Restore-VMFromVHD devenv1 cluster-devenv1
Restore-VMFromVHD devenv2 cluster-devenv2
~~~

For each of the restored guest VMs `devenv0`, `devenv1` and `devenv2`, from the PowerShell terminal, the script will automatically open a console for the new guest, and run a guest script in it.

- When the prompt to login appears, **login as `root`**.
- You will get the question "What is the number of this VM? devenv[0] >".  Type "0" for a VM with name `devenv0`, or "1" for a VM with name `devenv1`, or "2" for a VM with name `devenv2`, ...  Press "Enter".  Remark that you can see the name of the virtual machine in the top-left corner of the console.
- Close your console.

For each of the restored guests VMs `devenv0`, `devenv1` and `devenv2`, from the PowerShell terminal, the script will automatically open another terminal for the guest, and run a guest script in it.

- The scripts use `putty` and PuTTY's `pscp` commands.  They will ask you `Store key in cache? (y/n)` or `Update cached key? (y/n, Return cancels connection)`.  Type "y".

> **The Kubernetes Cluster installation is complete.**
>
> You can test the installed components:
>
> - follow [Test Docker](create-server-for-docker.html#test-docker)
> - follow [Test Nodes](create-cluster-for-kubernetes.html#test-nodes)
> - follow [Test Cluster](create-cluster-for-kubernetes.html#test-cluster)
> - follow [Test Cluster With Sonobuoy](test-cluster-with-sonobuoy.html)
> 
> You are now ready to continue with one of these options:
>
> - follow the detailed procedure starting from the [Use Dashboard For Kubernetes](use-dashboard-for-kubernetes.html) chapter.
> - follow the fast procedure starting from the [Use Dashboard For Kubernetes](../README.html#use-dashboard-for-kubernetes) step.
> - follow the faster procedure starting from the [Use Kubernetes Cluster](../README.html#use-kubernetes-cluster) step.
> - follow the fastest procedure starting from the [Use Restored Kubernetes Cluster](../README.html#use-restored-kubernetes-cluster) step.

[Go to Top](#restore-development-environment-from-virtual-hard-disks)
[Go back to Overview](../README.html#overview)



