## Before You Start

Contents:

- [How To Run Scripts](#how-to-run-scripts)
- [How To Download Latest Versions](#how-to-download-latest-versions)
- [How To Find The IP Address Of Host](#how-to-find-the-ip-address-of-host)

[Go back to Overview](../README.html#overview)



### How To Run Scripts

This topic assumes you already saved the DevEnv package on your machine.  See [Install DevEnv Package](prepare-development-environment.html#install-devenv-package).

Scripts for the host can be found in the `$HOME\DevEnv\Scripts` folder.  They come in two flavours:

- Scripts you run on a Command Prompt (`*.bat`)
  These scripts **need** to be "Run as administrator".  The name of these scripts all start with `@ACP_` which stands for "Administrator Command Prompt".  The "Run as administrator" option is available when you right-click on the script in File Explorer.

- Scripts you run in a Windows PowerShell (`*.ps1`)
  These scripts **need** to be run in a PowerShell that is started with option `-ExecutionPolicy Bypass`.  We provide the ACP script `@ACP_Start-PowerShell.bat` to start such a PowerShell.

  To run a PowerShell script, in such an PowerShell:
  ~~~
  <name of a .ps1 script>
  ~~~

Scripts for the guest can be found in the `$HOME\DevEnv\@guest\Scripts` folder

- To run a bash script, in a terminal for a virtual machine:
  ~~~
  sudo -i
  ~/devenv/scripts/<name of .sh script>.sh
  exit
  ~~~

[Go to Top](#before-you-start)
[Go back to Overview](../README.html#overview)



### How To Download Latest Versions

This topic assumes you already saved the DevEnv package on your machine.  See [Install DevEnv Package](prepare-development-environment.html#install-devenv-package).

In this package, you can find a number of files that we downloaded from the internet.

- Virtual DVD disks in the `$HOME\DevEnv\Virtual Machines\Virtual DVD Disks` folder.

  - `CentOS-7-x86_64-DVD-1810.iso`: a DVD image to install CentOS 7 on the virtual machines.  You can download the latest version from https://www.centos.org/download, and replace the file under `$HOME\DevEnv\Virtual Machines\Virtual DVD Disks` with the new version.
  
    When downloading a new version, for the scripts to work, **you need to update some ACP scripts that use file:**
    
    - `$HOME\DevEnv\Scripts\@ACP_Create-VM-Master.bat`
  
    When downloading a new version, the steps described under [Install CentOS](create-virtual-machine-with-centos.html#install-centos) may need slight modifications.


- Applications for the host in the `$HOME\DevEnv\Downloads` folder.
  
  - `putty-64bit-0.70-installer.msi`: a Windows application that gives you a terminal window to the virtual machines, and allows a PowerShell on the host to remotely perform some actions on the guest machines.  You can download the latest version from https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html and replace the file under `$HOME\DevEnv\Downloads` with the new version.
  
  - `WinSCP-5.13.6-Setup.exe`: a Windows application to transfer files from host to virtual machine, and from virtual machine to host.  You can download the latest version from https://winscp.net/eng/download.php and replace the file under `$HOME\DevEnv\Downloads` with the new version.


- Executables for the host in the `$HOME\DevEnv\Scripts` folder (although these are technically speaking not really "scripts").

  - `kubectl.exe`: a Windows version of the Kubernetes `kubectl` application - the version we downloaded is v1.6,3.  You can download the latest version from https://github.com/eirslett/kubectl-windows/releases and replace the file under `$HOME\DevEnv\Downloads` with the new version.


- Configuration files for the guests in the `$HOME\DevEnv\@guest\devenv\downloads\kubectl-configs` folder.

  - `kube-flannel.yml`
  - `kube-flannel-rbac.yml`
  - **!!! TBD !!!**
  
  You can download the latest versions, in a Linux terminal (f.i. after you created a virtual machine for CentOS):
  ~~~
  curl -LO https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  curl -LO https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
  curl -LO
  curl -LO
  curl -LO
  curl -LO 
  ~~~

  When downloading a new version, **you need to update some of the config files**:
  **!!! TBD !!!**

  Now you can move the downloaded files to `$HOME\DevEnv\@guest\devenv\downloads\kubectl-configs`.


- Applications for the guests in the `$HOME\DevEnv\@guest\devenv\downloads` folder.
  
  - `helm\helm-v2.12.1-linux-386.tar.gz`
  - `helm\helm-v2.12.1-linux-amd64.tar.gz`

    Remark that we only included the package for a host with the `386`- and `amd64`-architecture. To check if this is your arrchitecture, in a Linux terminal (f.i. after you created a virtual machine for CentOS):
    ~~~
    ARCH=$(uname -m)
    case $ARCH in
      armv5*) ARCH="armv5";;
      armv6*) ARCH="armv6";;
      armv7*) ARCH="armv7";;
      aarch64) ARCH="arm64";;
      x86) ARCH="386";;
      x86_64) ARCH="amd64";;
      i686) ARCH="386";;
      i386) ARCH="386";;
    esac
    echo $ARCH
    ~~~
    If not, then you will need to download the correct one following the procedure for downloading a new version.
    Instead of the latest release, you may want to use the version we used for this package - just set the version in a `$DESIRED_VERSION`-variable, before starting the download script:
    ~~~
    DESIRED_VERSION=v2.12.1
    ~~~
 
    You can download the latest version (or desired version) from https://github.com/helm/helm/releases, or you can use the following script.  In a Linux terminal (f.i. after you created a virtual machine for CentOS):
    ~~~
    RELEASE=$( \
      curl -SsL https://github.com/helm/helm/releases/${DESIRED_VERSION:-latest} \
      | awk '/\/tag\//' \
      | grep -v no-underline \
      | head -n 1 \
      | cut -d '"' -f 2 \
      | awk '{n=split($NF,a,"/");print a[n]}' \
      | awk 'a !~ $0{print}; {a=$0}' \
    )

    ARCH=$(uname -m)
    case $ARCH in
      armv5*) ARCH="armv5";;
      armv6*) ARCH="armv6";;
      armv7*) ARCH="armv7";;
      aarch64) ARCH="arm64";;
      x86) ARCH="386";;
      x86_64) ARCH="amd64";;
      i686) ARCH="386";;
      i386) ARCH="386";;
    esac

    curl -LO https://storage.googleapis.com/kubernetes-helm/helm-$RELEASE-linux-$ARCH.tar.gz
    ~~~
    Now you can move (f.i. using WinSCP) the downloaded file to `$HOME\DevEnv\@guest\devenv\downloads\helm`.  Don't forget to clean-up your Linux folder.
    
    When downloading a new version, when the name changes, **you need to update some guest scripts that use file:**
    
    - `$HOME\DevEnv\@guest\devenv\scripts\install-helm.sh`


[Go to Top](#before-you-start)
[Go back to Overview](../README.html#overview)



### How To Find The IP Address Of Host

You may need the host's IP address, for instance to configure your router, or for instance to connect to the virtual machines from other computers.  When you are installing this on a laptop, these IP addresses will change when you connect to a different router in a different place.  

I find the easiest way is to create external switches for Hyper-V and use `ipconfig` on a Command Prompt.

- Start Hyper-V Manager on your host, and click "Virtual Switch Manager..."

- Check if you already have an **"External"** virtual switch for every adapter.  If not, add them, and remember their names.  Your host will now provide an IP address for every adapter.

- On a Command Prompt or in a PowerShell:
  ~~~
  ipconfig
  ~~~

For instance on my laptop, I have two adapters (you will see this in Hyper-V Manager, opening Virtual Switch Manager, click "Create Virtual Switch", under "External network"):

- "Intel(R) Centrino(R) Advanced-N 6235" used for my WiFi connection
- "Intel(R) Ethernet Connection I217-LM" used for my cable connection

So I created two external virtual switches on top of the internal external switch I already had, and got the following:
~~~
Windows IP Configuration


Ethernet adapter vEthernet (Virtual Switch Internal):

   Connection-specific DNS Suffix  . :
   Link-local IPv6 Address . . . . . : fe80::90a9:6d38:3c67:5b8a%10
   IPv4 Address. . . . . . . . . . . : 192.168.0.1
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . :

Ethernet adapter vEthernet (Virtual Switch External - WiFi):

   Connection-specific DNS Suffix  . :
   Link-local IPv6 Address . . . . . : fe80::fcb9:be9:3818:4f2a%14
   IPv4 Address. . . . . . . . . . . : 192.168.2.50
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.2.1

Ethernet adapter vEthernet (Virtual Switch External - Cable):

   Connection-specific DNS Suffix  . :
   Link-local IPv6 Address . . . . . : fe80::f023:935:25da:2977%3
   IPv4 Address. . . . . . . . . . . : 192.168.2.250
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.2.1
~~~

> **Tip:**
> Configure your router's DHCP server to always assign the same IP addresses to your host.  If you have multiple adapters connecting to your router at the same time, you should give each of them a different address.
> This will work at home but you will need to run `ipconfig` again when connecting to a different network, so leave the external virtual switches there.

[Go to Top](#before-you-start)
[Go back to Overview](../README.html#overview)



### What's Next?

- Goto next step:
  - [Detailed Installation Procedure](../README.html#detailed-installation-procedure)
  - [Fast Installation Procedure](../README.html#fast-installation-procedure)
  - [Faster Installation Procedure](../README.html#faster-installation-procedure)
  - [Fastest Installation Procedure](../README.html#fastest-installation-procedure)
  - [Restore Development Environment From Virtual Hard Disks](restore-development-environment-from-virtual-hard-disks.html)

[Go to Top](#before-you-start)
[Go back to Overview](../README.html#overview)



