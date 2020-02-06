## Create Virtual Machine With Centos

> **Remark:**
> **The following is based on the Centos version `7.6.1810`.  The steps below and the scripts for the Hyper-V guests may need to be adapted when using a different version.**

The steps are:
- [Create Virtual Machine](#create-virtual-machine)
- [Install CentOS](#install-centos)
- [Complete CentOS Installation](#complete-centos-installation)
- [Save Virtual Hard Disk For CentOS](#save-virtual-hard-disk-for-centos)

in short:
- run `@ACP_Create-VM` as administrator.
- connect to `devenv0` and follow [Install CentOS](#install-centos).
- run `@ACP_Complete-Install-CentOS` as administrator.
- optionally run `@ACP_Save-DevEnv-centos` as administrator.

[Go back to Overview](../README.html#overview)



### Create Virtual Machine

> Reference: https://www.altaro.com/hyper-v/centos-linux-hyper-v

In File Explorer on the host, run `@ACP_Create-VM` as an administrator.
Alternatively, in a PowerShell:
~~~
Create-VM devenv0 <name of the ISO-file for CentOS installation>
~~~

To use the ISO-file that came with this package:
~~~
Create-VM devenv0 CentOS-7-x86_64-DVD-1810
~~~
 
This script creates a virtual machine:
- Virtual Machine: "$HOME\DevEnv\Virtual Machines\devenv0"
- Virtual Hard Disk: "$HOME\DevEnv\Virtual Machines\devenv0\Virtual Hard Disks\devenv0.vhdx"

A console will open for you.  Now follow the steps under [Install CentOS](#install-centos).
 

> **Remark:**
> We also added a PowerShell script to delete a VM and its virtual hard disk:
> ~~~
> Delete-VM <name of VM>
> ~~~

[Go to Top](#create-virtual-machine-with-centos)
[Go back to Overview](../README.html#overview)



### Install CentOS

> **Remark:**
> **The following is based on the `CentOS-7-x86_64-DVD-1810.iso` installation file.  Other versions may behave slightly different.**
>
> **Please pay special attention to the text in bold.**

If Hyper-V Manager is not yet running, start Hyper-V Manager on your host.  You should now see the `devenv0` virtual machine.  

If you don't have a console open yet, right-click on the virtual machine name and select "Connect...".  A terminal window to the virtual machine will pop-up.

Click "Start". The virtual machine will boot from the CentOS 7 ISO-file.

Press "Enter". The installation will begin.

On the "WELCOME TO CENTOS 7" page, select your language, and click "Continue".

> **Remark:**
> In our experience, mouse input is not always captured well at this point.  It seems to help when you don't move the mouse around for a while, after clicking "Continue".
> When you have a problem, close the terminal window.  In the Hyper-V Manager, right-click on the virtual machine name and select "Turn Off..." and "Connect...".

Select "INSTALLATION DESTINATION".

- Don't change anything, and click "Done".

**Select "NETWORK & HOST NAME".**

- **Change "Host name" to `devenv0`, and click "Apply".**

- **Click "Configure...".**
  
  - **Select the "Ethernet" tab.**
  
    - **Change "Device" to "eth0 (&lt;MAC address for eth0 adapter&gt;)".**
  
  - **Select the "IPv4 Settings" tab.**
    
    - **Change "Method" to "Manual".**

    - **Click "Add"**

	    - **set "Address" to `192.168.0.50`**
	    - **set "Netmask" to `2255.255.255.0`**
	    - **set "Gateway" to `192.168.0.1`** 
	    - **set "DNS servers" to `4.2.2.2, 8.8.8.8`**

	    - **click "Save".**

  - **Flip the switch for "Ethernet (eth0)" to "ON".**

  - Then click "Done".

- Click on "Begin Installation".

Select "ROOT PASSWORD".

- **Set password to `rootroot`** - the scripts depend on this, you can later change this to some other password.

- Then click "Done" twice.

**Select "USER CREATION".**

- **Create a "master" user, and tick "Make this user administrator"**. Set password to `mastmast` - you can later change this and add other users.

- Then click "Done" twice.

Click on "Finish configuration".

When the installation is completed, click "Reboot".

When the prompt to login appears, login as `root`.

Verify that you can `ping www.google.com`.

Close your console.

[Go to Top](#create-virtual-machine-with-centos)
[Go back to Overview](../README.html#overview)



### Complete CentOS Installation

> Reference: https://cyruslab.net/2014/07/11/installing-netstat-on-centos-7-minimal-installation
> Reference: https://www.altaro.com/hyper-v/centos-linux-hyper-v

Verify you can reach `devenv0` using Putty or WinSCP on your host or another computer.

Use following credentials on the host:
- Host name: `devenv0` or `192.168.0.50`
- Port number: `22`
- User name: `root`

Or use the following credentials from another computer (this will be forwarded to 192.168.0.50:22):
- Host name: `<the IP address of your host>`
- Port number: `50022`
- User name: `root`

In File Explorer on the host, run `@ACP_Complete-Install-CentOS` as an administrator.
Alternatively, in a PowerShell:
~~~
Complete-Install-CentOS devenv0
~~~

From the PowerShell terminal, the script will automatically open another terminal for `devenv0`, and run a guest script in it.

- The script uses `putty` and PuTTY's `pscp` commands.  It will ask you `Store key in cache? (y/n)` or `Update cached key? (y/n, Return cancels connection)`.  Type "y".
- You can find a dump of the PuTTY terminal sessions in the folder `$HOME\DevEnv\Scripts\PuTTY-log``.

> **Remark:**
> The `.bash*` files for the `root` account on `devenv0` will be overwritten.  If you updated the CentOS ISO-file, you may need to adapt the `.bash*` files that came with the DevEnv package, in the `$HOME\DevEnv\@guest` folder.


[Go to Top](#create-virtual-machine-with-centos)
[Go back to Overview](../README.html#overview)



### Save Virtual Hard Disk For CentOS

At this point it is a probably a good idea to save the virtual machine's virtual hard disk for future use.

In File Explorer on the host, run `@ACP_Save-DevEnv-centos` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Save-VHD devenv0 centos
~~~

This script saves a virtual hard disk for CentOS:
- Virtual Hard Disk: `$HOME\DevEnv\Virtual Hard Disks\centos.vhdx`

> **The CentOS installation is complete.**
> You can now restore the virtual machine to this point. See [Restore CentOS Virtual Machine](restore-development-environment-from-virtual-hard-disks.html#restore-centos-virtual-machine)

[Go to Top](#create-virtual-machine-with-centos)
[Go back to Overview](../README.html#overview)



### What's Next?

- Go to previous step: [Prepare Development Environment](prepare-development-environment.html)
- Go to next step: [Create Server For Docker](create-server-for-docker.html)

[Go to Top](#create-virtual-machine-with-centos)
[Go back to Overview](../README.html#overview)



