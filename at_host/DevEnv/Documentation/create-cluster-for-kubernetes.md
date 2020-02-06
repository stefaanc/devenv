## Create Cluster For Kubernetes

> **Remark:**
> **The following is based on the Kubernetes version `1.13.1`.  The steps below and the scripts for the Hyper-V guests may need to be adapted when using a different version.**

The steps are:
- [Create Master Node](#create-master-node)
- [Create Worker Nodes](#create-worker-nodes)
- [Test Nodes](#test-nodes)
- [Create Cluster](#create-cluster)
- [Test Cluster](#test-cluster)
- [Save Virtual Hard Disks For Kubernetes Cluster](#save-virtual-hard-disks-for-kubernetes-cluster)

in short:
- run `@ACP_Create-MasterNode` as an administrator
- run `@ACP_Create-WorkerNodes` as an administrator
  - in the consoles, login as `root`.
- optionally follow [Test Nodes](#test-nodes)
- run `@ACP_Create-Cluster` as an administrator.
- optionally follow [Test Cluster](#test-cluster)
- optionally follow [Save Temporary Virtual Hard Disks For Kubernetes Cluster](#save-temporary-virtual-hard-disks-for-kubernetes-cluster)

[Go back to Overview](../README.html#overview)



### Create Master Node

> Reference: https://stackoverflow.com/questions/24729024/open-firewall-port-on-centos-7 
> Reference: https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports.
> Reference: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm
> Reference: https://github.com/coreos/flannel

In File Explorer on the host, run `@ACP_Create-MasterNode` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Create-MasterNode devenv0
~~~

From the PowerShell terminal, the script will automatically open another terminal for `devenv0`, and run a guest script in it.

- You can find a dump of the PuTTY terminal sessions in the folder `$HOME\DevEnv\Scripts\PuTTY-log``.

[Go to Top](#create-cluster-for-kubernetes)
[Go back to Overview](../README.html#overview)



### Create Worker Nodes

In File Explorer on the host, run `@ACP_Create-WorkerNodes` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Restore-VMFromVHD devenv1 kubernetes
Restore-VMFromVHD devenv2 kubernetes
~~~

For each of the restored guest VMs `devenv1` and `devenv2`, from the PowerShell terminal, the script will automatically open a console for the new guest, and run a guest script in it.

- When the prompt to login appears, **login as `root`**.
- You will get the question "What is the number of this VM? devenv[0] >".  Type "1" for a VM with name `devenv1`, or "2" for a VM with name `devenv2`.  Press "Enter".  Remark that you can see the name of the virtual machine in the top-left corner of the console.
- Close your console.

For each of the restored guests VMs `devenv1` and `devenv2`, from the PowerShell terminal, the script will automatically open another terminal for the guest, and run a guest script in it.

- The scripts use `putty` and PuTTY's `pscp` commands.  They will ask you `Store key in cache? (y/n)` or `Update cached key? (y/n, Return cancels connection)`.  Type "y".
- You can find a dump of the PuTTY terminal sessions in the folder `$HOME\DevEnv\Scripts\PuTTY-log``.

These scripts create two virtual machines:
- Virtual Machines: 
  - "$HOME\DevEnv\Virtual Machines\devenv1"
  - "$HOME\DevEnv\Virtual Machines\devenv2"
- Virtual Hard Disks: 
  - "$HOME\DevEnv\Virtual Machines\devenv0\Virtual Hard Disks\devenv1.vhdx"
  - "$HOME\DevEnv\Virtual Machines\devenv0\Virtual Hard Disks\devenv2.vhdx"

[Go to Top](#create-cluster-for-kubernetes)
[Go back to Overview](../README.html#overview)



### Test Nodes

Check full network availability for each of the nodes.  

In a Command Prompt on the host
~~~
ping devenv-host
ping devenv0
ping devenv1
ping devenv2
~~~

In a terminal for `devenv0`
~~~
ping devenv-host
ping devenv0
ping devenv1
ping devenv2
~~~

In a terminal for `devenv1`
~~~
ping devenv-host
ping devenv0
ping devenv1
ping devenv2
~~~

In a terminal for `devenv2`
~~~
ping devenv-host
ping devenv0
ping devenv1
ping devenv2
~~~

[Go to Top](#create-cluster-for-kubernetes)
[Go back to Overview](../README.html#overview)



### Create Cluster

> Reference: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm

In File Explorer on the host, run `@ACP_Create-Cluster` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Generate-ClusterToken.ps1 devenv0
Join-Cluster.ps1 devenv1 devenv0
Join-Cluster.ps1 devenv2 devenv0
~~~

> **Remark:**
> On a slow host, the timers in the scripts may be a bit too short.  You can increase them, or introduce extra timers, using following guidelines: 

> - Once the master node is created, the POD-network is working, and all "coredns-*" PODs are "Running", you can create the cluster.
>   In a terminal for `devenv0`
>   ~~~
>   kubectl get pods --all-namespaces
>   ~~~
>
> - Once the cluster is created, and all nodes are "Ready", you can go to the next step.
>   In a terminal for `devenv0`
>   ~~~
>   kubectl get nodes
>   ~~~

[Go to Top](#create-cluster-for-kubernetes)
[Go back to Overview](../README.html#overview)



### Test Cluster

> **Remark:**
> If you run these tests after re-booting the nodes, then it may take one or two minutes for the cluster to start-up.  Your will get a message like `The connection to the server 192.168.0.51:6443 was refused - did you specify the right host or port?`
> Check the connectivity, as described under [Test Kubernetes Nodes](#test-kubernetes-nodes), and if all looks in order, try again after a couple of minutes.

Test that all nodes are "Ready".  In a terminal for `devenv0`
~~~
kubectl get nodes -o wide
~~~

You should get something like:
~~~
NAME        STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION              CONTAINER-RUNTIME
devenv0     Ready    master   3m43s   v1.13.1   192.168.0.50   <none>        CentOS Linux 7 (Core)   3.10.0-957.1.3.el7.x86_64   docker://18.9.0
devenv1     Ready    <none>   98s     v1.13.1   192.168.0.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.1.3.el7.x86_64   docker://18.9.0
devenv2     Ready    <none>   66s     v1.13.1   192.168.0.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.1.3.el7.x86_64   docker://18.9.0
~~~

Test that all pods are "Running".  In a terminal for `devenv0`
~~~
kubectl get pods --all-namespaces -o wide
~~~

You should get something like:
~~~
NAMESPACE     NAME                                READY   STATUS    RESTARTS   AGE     IP             NODE        NOMINATED NODE   READINESS GATES
kube-system   coredns-86c58d9df4-82wsz            1/1     Running   0          4m13s   10.244.0.2     devenv0     <none>           <none>
kube-system   coredns-86c58d9df4-vw2tl            1/1     Running   0          4m13s   10.244.0.3     devenv0     <none>           <none>
kube-system   etcd-devenv0                        1/1     Running   0          3m21s   192.168.0.50   devenv0     <none>           <none>
kube-system   kube-apiserver-devenv0              1/1     Running   0          3m18s   192.168.0.50   devenv0     <none>           <none>
kube-system   kube-controller-manager-devenv0     1/1     Running   0          3m11s   192.168.0.50   devenv0     <none>           <none>
kube-system   kube-flannel-ds-amd64-872ts         1/1     Running   0          4m13s   192.168.0.50   devenv0     <none>           <none>
kube-system   kube-flannel-ds-amd64-bc7x4         1/1     Running   1          115s    192.168.0.51   devenv1     <none>           <none>
kube-system   kube-flannel-ds-amd64-wkrkj         1/1     Running   0          2m27s   192.168.0.52   devenv2     <none>           <none>
kube-system   kube-proxy-2qrpz                    1/1     Running   0          4m13s   192.168.0.50   devenv0     <none>           <none>
kube-system   kube-proxy-2x9tg                    1/1     Running   0          115s    192.168.0.51   devenv1     <none>           <none>
kube-system   kube-proxy-tf7lh                    1/1     Running   0          2m27s   192.168.0.52   devenv2     <none>           <none>
kube-system   kube-scheduler-devenv0              1/1     Running   0          3m21s   192.168.0.50   devenv0     <none>           <none>
~~~

[Go to Top](#create-cluster-for-kubernetes)
[Go back to Overview](../README.html#overview)



### Save Virtual Hard Disks For Kubernetes Cluster

At this point it is a probably a good idea to save the virtual machine's virtual hard disk as for future use.

In File Explorer on the host, run `@ACP_Save-DevEnv-cluster` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Save-VHD devenv0 cluster-devenv0
Save-VHD devenv1 cluster-devenv1
Save-VHD devenv2 cluster-devenv2
~~~

This script creates virtual hard disks for the Kubernetes cluster:
- Virtual Hard Disks: 
  - `$HOME\DevEnv\Virtual Hard Disks\cluster-devenv0.vhdx`
  - `$HOME\DevEnv\Virtual Hard Disks\cluster-devenv1.vhdx`
  - `$HOME\DevEnv\Virtual Hard Disks\cluster-devenv2.vhdx`

[Go to Top](#create-cluster-for-kubernetes)
[Go back to Overview](../README.html#overview)



### What's Next?

- Go to previous step: [Create Node For Kubernetes](create-node-for-kubernetes.html)
- Go to next step: [Test Cluster With Sonobuoy](test-cluster-with-sonobuoy.html)

[Go to Top](#create-cluster-for-kubernetes)
[Go back to Overview](../README.html#overview)
