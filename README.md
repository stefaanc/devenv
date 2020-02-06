# Development Environment
---

This document describes the creation and installation of the development environment.
It is intended to run on a laptop with Windows 10 installed and Hyper-V running.

Before you start, 
- we didn't copy the ISO-file for centos to Github - you will need to do that if you want the scripts to work.  The current scripts are looking for `@host\DevEnv\Virtual Machines\Virtual DVD Disks\CentOS-7-x86_64-DVD-1810.iso`
- the folders `at_home` and `at_guest` need to be renamed to `@host` and `@guest` for the scripts to run.  We had to rename these because they create problems with uploading to Github.

To learn more about the DevEnv environment, read [README](@host/DevEnv/README.md).

To install the DevEnv environment on your laptop, start with [Install DevEnv Package](@host/DevEnv/Documentation/prepare-development-environment.md), and then follow the `$HOME\DevEnv\README`.