# Development Environment
---

This document describes the creation and installation of the development environment.
It is intended to run on a laptop with Windows 10 installed and Hyper-V running.

To install the DevEnv environment, you have one of these options.

- follow the [Detailed Installation Procedure](#detailed-installation-procedure) section.
- follow the [Fast Installation Procedure](#fast-installation-procedure) section.
- follow the [Faster Installation Procedure](#faster-installation-procedure) section.
- follow the [Fastest Installation Procedure](#fastest-installation-procedure) section.

For all the options, it is advisable to first go through the [Before You Start](documentation/before-you-start.html) chapter.

If this guide is followed to the letter, then some users are created for this development environment:
- user `root` with password `rootroot`
- user `master` with password `mastmast`
- user `admin` with password `admiadmi`
- user `editor` with password `editedit`
- user `viewer` with password `viewview`

When all is well after this installation, you can reach `devenv0` using Putty or WinSCP on your host or another computer.

- Use following credentials on the host:
  - Host name: `devenv0` or `192.168.0.50`
  - Port number: `22`
  - User name: `root`, `master`, `admin`, `editor` or `viewer`


- Use the following credentials from another computer (this will be forwarded to 192.168.0.50:22):
  - Host name: `<the IP address of your host>`
  - Port number: `50022`
  - User name: `root`, `master`, `admin`, `editor` or `viewer`



## Overview

- [Before You Start](documentation/before-you-start.html)
  - [How To Run Scripts](documentation/before-you-start.html#how-to-run-scripts)
  - [How To Download Latest Versions](documentation/before-you-start.html#how-to-download-latest-versions)
  - [How To Find The IP Address Of Host](documentation/before-you-start.html#how-to-find-the-ip-address-of-host)


- [Detailed Installation Procedure](#detailed-installation-procedure)
- [Fast Installation Procedure](#fast-installation-procedure)
- [Faster Installation Procedure](#faster-installation-procedure)
- [Fastest Installation Procedure](#fastest-installation-procedure)


- [Restore Development Environment From Virtual Hard Disks](documentation/restore-development-environment-from-virtual-hard-disks.html)
  - [Restore CentOS Virtual Machine](documentation/restore-development-environment-from-virtual-hard-disks.html#restore-centos-virtual-machine)
  - [Restore Docker Server](documentation/restore-development-environment-from-virtual-hard-disks.html#restore-docker-server)
  - [Restore Kubernetes Node](documentation/restore-development-environment-from-virtual-hard-disks.html#restore-kubernetes-node)
  - [Restore Kubernetes Cluster](documentation/restore-development-environment-from-virtual-hard-disks.html#restore-kubernetes-cluster)

[Go to Top](#development-environment)
[Go to Overview](#overview)



## Detailed Installation Procedure

The detailed procedure goes through every step of the installation, with detailed explanations and references.  You may want to use this to learn about this installation, or to debug when one of the other installation procedures fail.

- [Prepare Development Environment](documentation/prepare-development-environment.html)
- [Create Virtual Machine With CentOS](documentation/create-virtual-machine-with-centos.html)
- [Create Server For Docker](documentation/create-server-for-docker.html)
- [Create Node For Kubernetes](documentation/create-node-for-kubernetes.html)
- [Create Cluster For Kubernetes](documentation/create-cluster-for-kubernetes.html)
- [Test Cluster With Sonobuoy](documentation/test-cluster-with-sonobuoy.html)
- [Create Sandbox For Kubernetes](documentation/create-sandbox-for-kubernetes.html)
- [Deploy Helm Package Manager For Kubernetes](documentation/deploy-helm-package-manager-for-kubernetes.html)
- [Deploy Dashboard For Kubernetes](documentation/deploy-dashboard-for-kubernetes.html)
- [Use Dashboard For Kubernetes](documentation/use-dashboard-for-kubernetes.html)

[Go to Top](#development-environment)
[Go to Overview](#overview)



## Fast Installation Procedure

The fast installation procedure is essentially the same as the [detailed installation procedure](#detailed-installation-procedure), but leaving out all the explanations, references and remarks.  You may want to use this to debug when the [faster](#faster-installation-procedure) and [fastest](#faster-installation-procedure) installation procedures fail.
We **strongly advise** not to use this for your first deployment.
  
- ###### Prepare Development Environment

  > **Only when the first time:**
  > - follow [Install DevEnv Package](documentation/prepare-development-environment.html#install-devenv-package).
  > - run `@ACP_Start-PowerShell` as administrator and execute `Update-Hosts`.
  > - run `@ACP_Delete-NATNetwork` as administrator.
  > - run `@ACP_Create-NATNetwork` as administrator.
  
  - run `@ACP_Delete-NATRules` as administrator.
  - run `@ACP_Create-NATRules` as administrator.


- ###### Create Virtual Machine With CentOS

  - run `@ACP_Create-VM` as administrator.
  - connect to `devenv0` and follow [Install CentOS](documentation/create-virtual-machine-with-centos.html#install-centos).
  - run `@ACP_Complete-Install-CentOS` as administrator.
  - optionally run `@ACP_Save-DevEnv-centos` as administrator.


- ###### Create Server For Docker

  - run `@ACP_Install-Docker` as an administrator.
  - optionally follow [Test Docker](documentation/create-server-for-docker.html#test-docker)
  - optionally run `@ACP_Save-DevEnv-docker` as administrator.


- ###### Create Node For Kubernetes

  - run `@ACP_Install-Kubernetes` as an administrator.
  - run `@ACP_Save-DevEnv-kubernetes` as administrator.


- ###### Create Cluster For Kubernetes

  - run `@ACP_Create-MasterNode` as an administrator
  - run `@ACP_Create-WorkerNodes` as an administrator
    - in the consoles, login as `root`.
  - optionally follow [Test Nodes](documentation/create-cluster-for-kubernetes.html#test-nodes)
  - run `@ACP_Create-Cluster` as an administrator.
  - optionally follow [Test Cluster](documentation/create-cluster-for-kubernetes.html#test-cluster)
  - optionally follow [Save Virtual Hard Disks For Kubernetes Cluster](documentation/create-cluster-for-kubernetes.html#save-virtual-hard-disks-for-kubernetes-cluster)


- ###### Test Cluster With Sonobuoy

  - optionally follow [Test Cluster](documentation/test-cluster-with-sonobuoy.html)


- ###### Create Sandbox For Kubernetes


- ###### Deploy Helm Package Manager For Kubernetes


- ###### Deploy Dashboard For Kubernetes


- ###### Use Dashboard For Kubernetes

  - follow [Use Dashboard For Kubernetes](documentation/use-dashboard-for-kubernetes.html)

[Go to Top](#development-environment)
[Go to Overview](#overview)



## Faster Installation Procedure

The faster installation procedure tries to compress the [fast installation procedure](#fast-installation-procedure) in as few steps as possible, without [restoring the development environment from virtual hard disks](documentation/restore-development-environment-from-virtual-hard-disks.html).  This installation procedure skips all optional steps of the [fast installation procedure](#fast-installation-procedure).  You may want to use this to debug when the [fastest installation procedure](#faster-installation-procedure) fails.  
We **strongly advise** not to use this for your first deployment.

- ###### Create Kubernetes Environment

  > **Only when the first time:**
  > - follow [Install DevEnv Package](documentation/prepare-development-environment.html#install-devenv-package).
  > - run `@ACP_Start-PowerShell` as administrator and execute `Update-Hosts`.
  > - run `@ACP_Delete-NATNetwork` as administrator.
  > - run `@ACP_Create-NATNetwork` as administrator.

  - run `@@ACP_DevEnv-Step1` as administrator.
  - connect to `devenv0` and follow [Install CentOS](documentation/create-virtual-machine-with-centos.html#install-centos).
  - run `@@ACP_DevEnv-Step2` as administrator.
    - in the consoles, login as `root`.
  - run `@@ACP_DevEnv-Step3` as administrator.


- ###### Test Kubernetes Environment

  - optionally follow [Test Docker](documentation/create-server-for-docker.html#test-docker)
  - optionally follow [Test Nodes](documentation/create-cluster-for-kubernetes.html#test-nodes)
  - optionally follow [Test Cluster](documentation/create-cluster-for-kubernetes.html#test-cluster)
  - optionally follow [Test Cluster With Sonobuoy](documentation/test-cluster-with-sonobuoy.html)


- ###### Use Kubernetes Environment

  - follow [Use Dashboard For Kubernetes](documentation/use-dashboard-for-kubernetes.html)

[Go to Top](#development-environment)
[Go to Overview](#overview)



## Fastest Installation Procedure

The fastest installation procedure [restores the development environment from virtual hard disks](documentation/restore-development-environment-from-virtual-hard-disks.html#restore-kubernetes-cluster).

- ###### Restore Kubernetes Environment From Virtual Hard Disk

  > **Only when the first time:**
  > - follow [Install DevEnv Package](documentation/prepare-development-environment.html#install-devenv-package).
  > - run `@ACP_Start-PowerShell` as administrator and execute `Update-Hosts`.
  > - run `@ACP_Delete-NATNetwork` as administrator.
  > - run `@ACP_Create-NATNetwork` as administrator.

  If it is the first you deploy the development environment, we **strongly advise** you to 
  - follow [Restore Kubernetes Cluster](documentation/restore-development-environment-from-virtual-hard-disks.html#restore-kubernetes-cluster)

  Otherwise, you can
  - run `@ACP_Delete-NATRules` as an administrator.
  - run `@ACP_Create-NATRules` as an administrator.
  - run `@ACP_Restore-DevEnv-Cluster` as administrator.
    - in the consoles, login as `root`.


- ###### Test Restored Kubernetes Environment

  - optionally follow [Test Docker](documentation/create-server-for-docker.html#test-docker)
  - optionally follow [Test Nodes](documentation/create-cluster-for-kubernetes.html#test-nodes)
  - optionally follow [Test Cluster](documentation/create-cluster-for-kubernetes.html#test-cluster)
  - optionally follow [Test Cluster With Sonobuoy](documentation/test-cluster-with-sonobuoy.html)


- ###### Use Restored Kubernetes Environment

  - follow [Use Dashboard For Kubernetes](documentation/use-dashboard-for-kubernetes.html)

[Go to Top](#development-environment)
[Go to Overview](#overview)
