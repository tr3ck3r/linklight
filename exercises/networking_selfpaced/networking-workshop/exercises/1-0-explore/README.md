# Exercise 1.0 - Exploring the lab environment

## Step 1

Navigate to the `networking-workshop/` directory.


```
[student1@ansible ~]$ cd networking-workshop/
[student1@ansible networking-workshop]$

```

## Step 2

Run the `ansible` command with the `--version` command to look at what is configured:


```
[root@Ansible networking-workshop]$ ansible --version
ansible 2.9.6
  config file = /root/.ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.17 (default, Nov  7 2019, 10:07:09) [GCC 7.4.0]
[root@Ansible networking-workshop]$


```

> Note: The ansible version you see might differ from the above output


This command gives you information about the version of Ansible, location of the executable, version of Python, search path for the modules and location of the `ansible configuration file`.

## Step 3

Use the `cat` command to view the contents of the `ansible.cfg` file.

```
[student1@ansible networking-workshop]$ cat ~/.ansible.cfg
[defaults]
connection = smart
timeout = 60
inventory = /home/student1/networking-workshop/lab_inventory/hosts
host_key_checking = False
private_key_file = /home/student1/.ssh/aws-private.pem
[student1@ansible networking-workshop]$

```

Note the following parameters within the `ansible.cfg` file:

 - `inventory`: shows the location of the ansible inventory being used


## Step 4

The scope of a `play` within a `playbook` is limited to the groups of hosts declared within an Ansible **inventory**. Ansible supports multiple [inventory](http://docs.ansible.com/ansible/latest/intro_inventory.html) types. An inventory could be a simple flat file with a collection of hosts defined within it or it could be a dynamic script (potentially querying a CMDB backend) that generates a list of devices to run the playbook against.

In this lab you will work with a file based inventory written in the **ini** format. Use the `cat` command to view the contents of your inventory:


```
root@Ansible:~# cat ~/networking_workshop/lab_inventory/hosts
[cisco]
rtr1 ansible_host=192.168.122.101
rtr2 ansible_host=192.168.122.102
rtr3 ansible_host=192.168.122.103
rtr4 ansible_host=192.168.122.104

[cisco:vars]
ansible_user=cisco
ansible_network_os=ios
ansible_ssh_common_args='-o StrictHostKeyChecking=no'


```

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

## Step 6

If you want to have ability to have more than one thing on the screen at a time; tmux is a wonderful tool for that.

```
sudo apt-get update
sudo apt-get install tmux
```

To utilitize, type tmux and then if you want to have a top and bottom screen you can use the CTRL+SHIFT+B and then " to get two horizontally seperated screens.  CTRL+SHIFT+B up or down will switch between them.

# Complete

You have completed lab exercise 1.0

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)
