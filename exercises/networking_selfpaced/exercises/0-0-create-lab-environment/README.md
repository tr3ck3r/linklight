# Exercise 0.0 - Creating the lab environment

To get started, you are going to need four Cisco routers and an Ansible supporting Linux environment.  While this can be done a variety of ways, we are going to cover doing this with GNS3.

## Step 1

Install GNS3.  

You may chose to install it locally or on a remote server such as a VM Ware ESXi server.  Since we are only running five VMs; the requirements are light enough to work on many workstations.

## Step 2

Configure one routers and get the idle time optimized.  Simplest would be to use vIOS from Cisco if you have access to this.  You will need to support four router interfaces that are Gigabit Ethernet. 

Once the first router is working correctly, duplicate it three times.

## Step 4
Configure your Ansible environment.  You may chose to use an existing appliance or create your own from scratch.  It must have Ansible installed.  

For this documentation, Ubuntu will be used but other Linux OSes can be used.

## Step 3

Create a hub which will serve for the Out Of Band (OOB) connection between all devices.  Many of the labs can be done with only the OOB part of the network working; however, the goal is to configure a BGP connection between two data centers which are running OSPF internally.  Connect all Cisco routers up to OOB on the Gig0/3 interface and the Ansible on the single Ethernet interface. 

## Step 4
Add a 

## Step 5

In the above output every `[ ]` defines a group. For example `[dc1]` is a group that contains the hosts `rtr1` and `rtr2`. Groups can also be _nested_. The group `[routers]` is a parent group to the group `[cisco]`

> Parent groups are declared using the `children` directive. Having nested groups allows the flexibility of assigining more specific values to variables.


> Note: A group called **all** always exists and contains all groups and hosts defined within an inventroy.


We can associate variables to groups and hosts. Host variables are declared/defined on the same line as the host themselves. For example for the host `rtr1`:

```
rtr1 ansible_host=52.90.196.252 ansible_ssh_user=ec2-user private_ip=172.16.165.205 ansible_network_os=ios

```

 - `rtr1` - The name that Ansible will use.  This can but does not have to rely on DNS
 - `ansible_host` - The IP address that ansible will use, if not configured it will default to DNS
 - `ansible_ssh_user` - The user ansible will use to login to this host, if not configured it will default to the user the playbook is run from
 - `private_ip` - This value is not reserved by ansible so it will default to a [host variable](http://docs.ansible.com/ansible/latest/intro_inventory.html#host-variables).  This variable can be used by playbooks or ignored completely.
- `ansible_network_os` - This variable is necessary while using the `network_cli` connection type within a play definition, as we will see shortly.

# Complete

You have completed lab exercise 0.0

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTM1MzYxMzc1MF19
-->