## Create Server For Docker

> **Remark:**
> **The following is based on the Docker version `18.09.0`.  The steps below and the scripts for the Hyper-V guests may need to be adapted when using a different version.**

The steps are:
- [Install Docker](#install-docker)
- [Test Docker](#test-docker)
- [Save Virtual Hard Disk For Docker](#save-virtual-hard-disk-for-docker)

in short:
- run `@ACP_Install-Docker` as an administrator.
- optionally follow [Test Docker](#test-docker)
- optionally run `@ACP_Save-DevEnv-docker` as administrator.

[Go back to Overview](../README.html#overview)



### Install Docker

> Reference: https://docs.docker.com/install/linux/docker-ce/centos
> Reference: https://docs.docker.com/install/linux/linux-postinstall
> Reference: https://support.plesk.com/hc/en-us/articles/360007029113-Docker-startup-on-firewalld-Warning-COMMAND-FAILED-No-chain-target-match-by-that-name
In File Explorer on the host, run `@ACP_Install-Docker` as an administrator.
Alternatively, in a PowerShell:
~~~
Install-Docker devenv0
~~~

From the PowerShell terminal, the script will automatically open another terminal for `devenv0`, and run a guest script in it.

- You can find a dump of the PuTTY terminal sessions in the folder `$HOME\DevEnv\Scripts\PuTTY-log``.

[Go to Top](#create-server-for-docker)
[Go back to Overview](../README.html#overview)



### Test Docker

> Reference: https://docs.docker.com/install/linux/docker-ce/centos
> Reference: https://docs.docker.com/install/linux/linux-postinstall

Check Docker works.  In a terminal for `devenv0`, **login as `master`**
~~~
sudo docker run hello-world
~~~

Clean up.  In the terminal for `devenv0`
~~~
sudo docker ps -a
sudo docker rm <CONTAINER ID>
sudo docker ps -a
sudo docker images
sudo docker rmi <IMAGE ID>
sudo docker images
~~~

Check Docker works without `sudo`.  In the terminal for `devenv0`
~~~
docker run hello-world
~~~

Clean up.  In the terminal for `devenv0`
~~~
docker ps -a
docker rm <CONTAINER ID>
docker ps -a
docker images
docker rmi <IMAGE ID>
docker images
~~~

[Go to Top](#create-server-for-docker)
[Go back to Overview](../README.html#overview)



### Save Virtual Hard Disk For Docker

At this point it is a probably a good idea to save the virtual machine's virtual hard disk as for future use.

In File Explorer on the host, run `@ACP_Save-DevEnv-docker` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Save-VHD devenv0 docker
~~~

This script creates a virtual hard disk for Docker:
- Virtual Hard Disk: `$HOME\DevEnv\Virtual Hard Disks\docker.vhdx`

> **The Docker installation is complete.**
> You can now restore the virtual machines to this point. See [Restore Docker Server](restore-development-environment-from-virtual-hard-disks.html#restore-docker-server)

[Go to Top](#create-server-for-docker)
[Go back to Overview](../README.html#overview)



### What's Next?

- Go to previous step: [Create Virtual Machine With CentOS](create-virtual-machine-with-centos.html)
- Go to next step: [Create Node For Kubernetes](create-node-for-kubernetes.html)

[Go to Top](#create-server-for-docker)
[Go back to Overview](../README.html#overview)



