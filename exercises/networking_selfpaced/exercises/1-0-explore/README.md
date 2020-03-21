# Exercise 1.0 - Exploring the lab environment

Let's familiarize ourselves with the environment and config.

## Step 1

Navigate to the `networking-workshop` directory.  If this directory does not exist, create it.

```
root@Ansible:~# cd networking-workshop/
bash: cd: networking-workshop/: No such file or directory
root@Ansible:~# mkdir networking-workshop/
root@Ansible:~# cd networking-workshop/
root@Ansible:~/networking-workshop#

```

## Step 2

Run the `ansible` command with the `--version` command to look at what is configured:

```
root@Ansible:~/networking-workshop# ansible --version
ansible 2.9.6
  config file = /root/.ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.17 (default, Nov  7 2019, 10:07:09) [GCC 7.4.0]
root@Ansible:~/networking-workshop#
```
> Note: The ansible version you see might differ from the above output

This command gives you information about the version of Ansible, location of the executable, version of Python, search path for the modules and location of the `ansible configuration file`.

## Step 3

Use the `echo` command to create and `cat` to view the contents of the `ansible.cfg` file.  Your configuration file may differ or you may need to create it and apply this configuration depending on where you got the Ansible VM from.

```
root@Ansible:~/networking-workshop# cat <<EOF > ~/.ansible.cfg
[defaults]
stdout_callback = yaml
connection = smart
timeout = 60
deprecation_warnings = False
host_key_checking = False
retry_files_enabled = False
inventory = ~/networking-workshop/lab_inventory/hosts
EOF
```
Use the `cat` to view the contents of the `ansible.cfg` file.  
```
root@Ansible:~/networking-workshop# cat ~/.ansible.cfg
[defaults]
stdout_callback = yaml
connection = smart
timeout = 60
deprecation_warnings = False
host_key_checking = False
retry_files_enabled = False
inventory = /home/student1/networking-workshop/lab_inventory/hosts
[persistent_connection]
connect_timeout = 60
root@Ansible:~/networking-workshop#
```

Note the following parameters within the `ansible.cfg` file:

 - `inventory`: shows the location of the ansible inventory being used

## Step 4

The scope of a `play` within a `playbook` is limited to the groups of hosts declared within an Ansible **inventory**. Ansible supports multiple [inventory](http://docs.ansible.com/ansible/latest/intro_inventory.html) types. An inventory could be a simple flat file with a collection of hosts defined within it or it could be a dynamic script (potentially querying a CMDB backend) that generates a list of devices to run the playbook against.

In this lab you will work with a file based inventory written in the **ini** format. Use the `cat` command to view the contents of your inventory:

```
root@Ansible:~/networking-workshop# cat <<EOF > ~/.ansible.cfg
[defaults]
stdout_callback = yaml
connection = smart
timeout = 60
deprecation_warnings = False
host_key_checking = False
retry_files_enabled = False
inventory = ~/networking-workshop/lab_inventory/hosts


[cisco]
rtr1 ansible_host=192.168.122.101
rtr2 ansible_host=192.168.122.102
rtr3 ansible_host=192.168.122.103
rtr4 ansible_host=192.168.122.104

[cisco:vars]
ansible_user=cisco
ansible_network_os=ios
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

root@Ansible:~/networking-workshop# cat ~/networking-workshop/lab_inventory/hosts
[all:vars]
ansible_ssh_private_key_file=/home/student1/.ssh/aws-private.pem
[routers:children]
cisco

[cisco]
rtr1 ansible_host=54.86.240.200 private_ip=172.16.53.225
rtr2 ansible_host=35.172.211.215 private_ip=172.17.2.181
rtr3 ansible_host=18.232.174.85 private_ip=172.16.237.202
rtr4 ansible_host=174.129.69.1 private_ip=172.17.120.151


[cisco:vars]
ansible_user=ec2-user
ansible_network_os=ios
ansible_connection=network_cli


[dc1]
rtr1
rtr3

[dc2]
rtr2
rtr4

[hosts]
host1 ansible_host=34.234.88.188 ansible_user=ec2-user private_ip=172.17.62.146

[control]
ansible ansible_host=34.229.83.26 ansible_user=student1 private_ip=172.16.103.177
EOF
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

# Complete

You have completed lab exercise 1.0

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)

<!--stackedit_data:
eyJoaXN0b3J5IjpbNTA2MDA4NDU4LDM3MDE0MzgxMCwtMjgwMD
Y1NTIxXX0=
-->