## Prepare Development Environment

The steps are:
- [Install DevEnv Package](#install-devenv-package)
- [Update Hosts File](#update-hosts-file)
- [Delete Existing NAT Network](#delete-existing-nat-network)
- [Create NAT Network](#create-nat-network)
- [Create NAT Rules](#create-nat-rules)

in short:
- when first time, follow [Install DevEnv Package](#install-devenv-package).
- when first time, run `@ACP_Start-PowerShell` as administrator and execute `Update-Hosts`.
- when first time, run `@ACP_Delete-NATNetwork` as administrator.
- run `@ACP_Delete-NATRules` as administrator.
- when first time, run `@ACP_Create-NATNetwork` as administrator.
- run `@ACP_Create-NATRules` as administrator.

[Go back to Overview](../README.html#overview)



### Install DevEnv Package

Copy the content of the `<package>\DevEnv for Laptop\@host` folder to your host, under `<home directory>` (this is the directory specified by the environment variables `$HOMEDRIVE` and `$HOMEPATH` - typically: `C:\Users\<user name>`) - **don't put it somewhere else because the scripts depend on this**.

Prepare the PowerShell environment:

- Check if there is a `<home directory>\Documents\WindowsPowerShell` folder, and if not then create it.


- Check if this folder contains a `profile.ps1` file
  - If there isn't, then copy the `profile.ps1` script from the `<home directory>\DevEnv\Scripts` folder.
  - If there is, then you need to merge the `profile.ps1` script from the `<home directory>\DevEnv\Scripts` folder manually into the existing file.


- Try to run the `@ACP_Start-PowerShell.bat` script **as administrator** and check that it brings you to your `<home directory>\DevEnv\Scripts` folder.
  - If it doesn't, then you will need to adapt the "HOMEDRIVE" and "HOMEPATH" variables in the `profile.ps1` script (see instructions in the script).


- If you don't have Powershell open anymore, run the `@ACP_Start-PowerShell.bat` script **as administrator**, try
  ~~~
  Get-Path.ps1
  ~~~

  - If this doesn't work, we will need to add the path to your environment variables
    ~~~ 
    ~/DevEnv/Scripts Set-Path.ps1
    ~~~
    Logout and login again.


[Go to Top](#prepare-development-environment)
[Go back to Overview](../README.html#overview)



### Update Hosts File

Check if the `C:\Windows\System32\drivers\etc\hosts`-file contains the names of our machines.  In a PowerShell:
~~~
Get-Hosts
~~~

The result should contain:
~~~
"192.168.0.1    devenv-host"
"192.168.0.1    devenv-gateway"
"192.168.0.50   devenv0"
"192.168.0.51   devenv1"
"192.168.0.52   devenv2"
"192.168.0.53   devenv3"
"192.168.0.54   devenv4"
"192.168.0.55   devenv5"
"192.168.0.56   devenv6"
"192.168.0.57   devenv7"
"192.168.0.58   devenv8"
"192.168.0.59   devenv9"
~~~

If not, then:
~~~
Update-Hosts
~~~

You should now be able to ping any of the virtual machines by name, once they are created.

[Go to Top](#prepare-development-environment)
[Go back to Overview](../README.html#overview)



### Delete Existing NAT Network

> Reference: https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network

If you already have a NAT network, you will first need to delete it (Hyper-V allows only one NAT network), or manually make the necessary modifications to the existing NAT network based on the [Create NAT Network](#create-nat-network) section.

Check that there is no NAT network. In a PowerShell:
~~~
Get-NetNAT
~~~

To remove the existing NAT network:
~~~
Remove-NetNAT
~~~

Check that there are no **"Internal"** VM switches:
~~~
Get-VMSwitch
~~~

To remove the **"Internal"** VM switches:
~~~
Remove-VMSwitch "<name of internal VM switch>"
~~~

> **Remark:**
> We have an ACP script `@ACP_Delete-NATNetwork` to remove the NAT network (**!!! all of it**) and to remove the internal VM switch with name `Virtual Switch Internal` (**only a switch with this name, provided it exists**)

Check that there are no NAT rules left:
~~~
Get-NetNATStaticMapping
~~~

To remove the NAT rules:
~~~
Remove-NetNATStaticMapping
~~~

> **Remark:**
> We have an ACP script `@ACP_Delete-NATRules` to remove the NAT rules (**!!! all of them**)

Check if there are private IP addresses from the old NAT still assigned to an adapter:
~~~
Get-NetIPAddress -InterfaceAlias "vEthernet (<name of internal VM-switch>)"
~~~

To remove the old private IP addresses:
~~~
Remove-NetIPAddress -InterfaceAlias "vEthernet (<name of internal VM-switch>)" -IPAddress <IP address>
~~~

[Go to Top](#prepare-development-environment)
[Go back to Overview](../README.html#overview)



### Create NAT Network

> Reference: https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network
> Reference: https://www.petri.com/using-nat-virtual-switch-hyper-v
> Reference: https://anandthearchitect.com/2018/01/06/windows-10-how-to-setup-nat-network-for-hyper-v-guests

In File Explorer on the host, run `@ACP_Create-NATNetwork` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Create-NATNetwork
~~~

This script creates a virtual switch and a NAT network:
- switch: "Virtual Switch Internal"
- network: "NAT Network Internal"
- internal IP addresses:
	- network: "192.168.0.0"
	- netmask: "255.255.255.0"
	- gateway: "192.168.0.1"
	- DNS: "4.2.2.2, 8.8.8.8"
- external IP address: the IP address of the host.

[Go to Top](#prepare-development-environment)
[Go back to Overview](../README.html#overview)



### Create NAT Rules

> Reference: https://www.petri.com/create-nat-rules-hyper-v-nat-virtual-switch

In File Explorer on the host, run `@ACP_Create-NATRules` as an administrator.
Alternatively, in a PowerShell:
~~~
Create-NATRules
~~~

This script creates NAT rules:
- TCP
	- 0.0.0.0:6443  -> 192.168.0.50:6443
	- 0.0.0.0:6443  -> 192.168.0.50:8443
	- 0.0.0.0:50022 -> 192.168.0.50:22
	- 0.0.0.0:51022 -> 192.168.0.51:22
	- 0.0.0.0:52022 -> 192.168.0.52:22

[Go to Top](#prepare-development-environment)
[Go back to Overview](../README.html#overview)



### What's Next?

- Go to previous step: [Before You Start](before-you-start.html)
- Go to next step: [Create Virtual Machine With CentOS](create-virtual-machine-with-centos.html)

[Go to Top](#prepare-development-environment)
[Go back to Overview](../README.html#overview)
