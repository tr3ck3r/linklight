# Exercise 2.2 - Using Ansible to restore the backed up configuration

>WARNING, there are some examples below which do not work.  There is a need to tweak things which has not been figured out yet.  Section 1 works, Section 2 does not.
## Section 1 - Using copy from flash to running
```
cat << EOF > restore.yml
---
- name: RESTORE GOLDEN CONFIGURATIONS
  hosts: cisco
  connection: network_cli
  gather_facts: no

  tasks:
    - name: DISABLE FILE PROMPTING
      tags: golden
      ios_config:
        config:
        lines:
          "file prompt quiet"

    - name: SAVE golden.cfg TO running-config 
      tags: golden
      ios_command:
        commands:
          - "copy flash:/golden.cfg start"
          - "copy "

EOF
```
### Step 2 - Execute playbook

```
root@Ansible:~/networking-workshop# ansible-playbook -i ~/networking-workshop/lab_inventory/hosts -k restore.yml -v | grep -v Deprecation
Using /root/networking-workshop/ansible.cfg as config file
SSH password:

PLAY [RESTORE GOLDEN CONFIGURATIONS] *******************************************

TASK [DISABLE FILE PROMPTING] **************************************************
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host rtr4 should use
/usr/bin/python3, but is using /usr/bin/python for backward compatibility with
prior Ansible releases. A future Ansible release will default to using the
discovered platform python for this host. See https://docs.ansible.com/ansible/
2.9/reference_appendices/interpreter_discovery.html for more information. This
feature will be removed in version 2.12. Deprecation warnings can be disabled
by setting deprecation_warnings=False in ansible.cfg.
ok: [rtr4] => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false}
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host rtr3 should use
/usr/bin/python3, but is using /usr/bin/python for backward compatibility with
prior Ansible releases. A future Ansible release will default to using the
discovered platform python for this host. See https://docs.ansible.com/ansible/
2.9/reference_appendices/interpreter_discovery.html for more information. This
feature will be removed in version 2.12. Deprecation warnings can be disabled
by setting deprecation_warnings=False in ansible.cfg.
ok: [rtr3] => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false}
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host rtr2 should use
/usr/bin/python3, but is using /usr/bin/python for backward compatibility with
prior Ansible releases. A future Ansible release will default to using the
discovered platform python for this host. See https://docs.ansible.com/ansible/
2.9/reference_appendices/interpreter_discovery.html for more information. This
feature will be removed in version 2.12. Deprecation warnings can be disabled
by setting deprecation_warnings=False in ansible.cfg.
ok: [rtr2] => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false}
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host rtr1 should use
/usr/bin/python3, but is using /usr/bin/python for backward compatibility with
prior Ansible releases. A future Ansible release will default to using the
discovered platform python for this host. See https://docs.ansible.com/ansible/
2.9/reference_appendices/interpreter_discovery.html for more information. This
feature will be removed in version 2.12. Deprecation warnings can be disabled
by setting deprecation_warnings=False in ansible.cfg.
ok: [rtr1] => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false}

TASK [SAVE golden.cfg TO running-config] ***************************************
ok: [rtr1] => {"changed": false, "stdout": ["%Hog profiling already off\n3881 bytes copied in 0.342 secs (11348 bytes/sec)"], "stdout_lines": [["%Hog profiling already off", "3881 bytes copied in 0.342 secs (11348 bytes/sec)"]]}
ok: [rtr2] => {"changed": false, "stdout": ["%Hog profiling already off\n3890 bytes copied in 0.336 secs (11577 bytes/sec)"], "stdout_lines": [["%Hog profiling already off", "3890 bytes copied in 0.336 secs (11577 bytes/sec)"]]}
ok: [rtr3] => {"changed": false, "stdout": ["%Hog profiling already off\n3636 bytes copied in 0.318 secs (11434 bytes/sec)"], "stdout_lines": [["%Hog profiling already off", "3636 bytes copied in 0.318 secs (11434 bytes/sec)"]]}
ok: [rtr4] => {"changed": false, "stdout": ["%Hog profiling already off\n3636 bytes copied in 0.306 secs (11882 bytes/sec)"], "stdout_lines": [["%Hog profiling already off", "3636 bytes copied in 0.306 secs (11882 bytes/sec)"]]}

PLAY RECAP *********************************************************************
rtr1                       : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rtr2                       : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rtr3                       : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rtr4                       : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

root@Ansible:~/networking-workshop#

```

## Section 2 - Using SCP
> Warning: The below has not been made to work successfully yet.  You have been warned.

In the previous lab you learned how to backup the configuration of the 4 cisco routers. In this lab you will learn how to restore the configuration. The backups had been saved into a local directory called `backup`.


```
backup
├── rtr1.config
├── rtr1_config.2018-06-07@20:36:05
├── rtr2.config
├── rtr2_config.2018-06-07@20:36:07
├── rtr3.config
├── rtr3_config.2018-06-07@20:36:04
├── rtr4.config
└── rtr4_config.2018-06-07@20:36:06

```


Our objective is to apply this "last known good configuraion backup" to the routers.

#### Step 1


On one of the routers (`rtr1`) manually make a change. For instance add a new loopback interface.

Log into `rtr1` using the `ssh rtr1` command and add the following:

```
rtr1#config terminal
Enter configuration commands, one per line.  End with CNTL/Z.
rtr1(config)#interface loopback 101
rtr1(config-if)#ip address 169.1.1.1 255.255.255.255
rtr1(config-if)#end
rtr1#

```

Now verify the newly created Loopback Interface

```
rtr1#sh run interface loopback 101
Building configuration...

Current configuration : 67 bytes
!
interface Loopback101
 ip address 169.1.1.1 255.255.255.255
end

rtr1#
```
#### Step 2

We are going to use the net_put Ansible module to copy the config backup to the routers. This requires the scp python module. We need to install that first:

```
sudo pip install scp
```

#### Step 3

Step 1 simulates our "Out of process/band" changes on the network. This change needs to be reverted. So let's write a new playbook to apply the backup we collected from our previous lab to achieve this.

Create a file called `restore_config.yml` using your favorite text editor and add the following play definition:

``` yaml
---
- name: RESTORE CONFIGURATION
  hosts: cisco
  connection: network_cli
  gather_facts: no

```


#### Step 4

Write the task to copy over the previously backed up configuration file to the routers.

``` yaml
---
- name: RESTORE CONFIGURATION
  hosts: cisco
  connection: network_cli
  gather_facts: no

  tasks:
    - name: COPY RUNNING CONFIG TO ROUTER
      net_put: 
        src: ./backup/{{inventory_hostname}}.config
        dest: flash:/{{inventory_hostname}}.config
      vars:
        ansible_command_timeout: 120

```

> Note the use of the **inventory_hostname** variable. For each device in the inventory file under the cisco group, this task will secure copy (scp) over the file that corresponds to the device name onto the bootflash: of the CSR devices.


#### Step 5

Go ahead and run the playbook.

```
[student1@ansible networking-workshop]$ ansible-playbook -i lab_inventory/hosts restore_config.yml

PLAY [RESTORE CONFIGURATION] *********************************************************

TASK [COPY RUNNING CONFIG TO ROUTER] *************************************************
changed: [rtr1]
changed: [rtr2]
changed: [rtr3]
changed: [rtr4]

PLAY RECAP ***************************************************************************
rtr1                       : ok=1    changed=1    unreachable=0    failed=0   
rtr2                       : ok=1    changed=1    unreachable=0    failed=0   
rtr3                       : ok=1    changed=1    unreachable=0    failed=0   
rtr4                       : ok=1    changed=1    unreachable=0    failed=0   

[student1@ansible networking-workshop]$



```


#### Step 6

Log into the routers to check that the file has been copied over

> Note **rtr1.config** at the bottom of the bootflash:/ directory

```
[student1@ansible networking-workshop]$ ssh rtr1


rtr1#dir
Directory of bootflash:/

   11  drwx            16384  May 11 2018 21:30:28 +00:00  lost+found
   12  -rw-        380928984  May 11 2018 21:32:05 +00:00  csr1000v-mono-universalk9.16.08.01a.SPA.pkg
   13  -rw-         38305434  May 11 2018 21:32:06 +00:00  csr1000v-rpboot.16.08.01a.SPA.pkg
   14  -rw-             1967  May 11 2018 21:32:06 +00:00  packages.conf
235713  drwx             4096   Jun 4 2018 18:08:56 +00:00  .installer
186945  drwx             4096   Jun 4 2018 18:08:44 +00:00  core
   15  -rw-               58   Jun 4 2018 18:08:30 +00:00  iid_check.log
113793  drwx             4096   Jun 4 2018 18:08:32 +00:00  .prst_sync
73153  drwx             4096   Jun 4 2018 18:08:44 +00:00  .rollback_timer
81281  drwx             4096   Jun 7 2018 22:03:48 +00:00  tracelogs
227585  drwx             4096   Jun 4 2018 18:16:10 +00:00  .dbpersist
130049  drwx             4096   Jun 4 2018 18:09:41 +00:00  virtual-instance
   16  -rw-               30   Jun 4 2018 18:11:05 +00:00  throughput_monitor_params
   17  -rw-            10742   Jun 4 2018 18:16:08 +00:00  cvac.log
   18  -rw-               16   Jun 4 2018 18:11:14 +00:00  ovf-env.xml.md5
   19  -rw-               16   Jun 4 2018 18:11:14 +00:00  .cvac_skip_once
   20  -rw-              209   Jun 4 2018 18:11:15 +00:00  csrlxc-cfg.log
170689  drwx             4096   Jun 4 2018 18:11:16 +00:00  onep
373889  drwx             4096   Jun 8 2018 00:41:04 +00:00  syslog
   21  -rw-               34   Jun 4 2018 18:16:15 +00:00  pnp-tech-time
   22  -rw-            50509   Jun 4 2018 18:16:16 +00:00  pnp-tech-discovery-summary
341377  drwx             4096   Jun 4 2018 18:16:21 +00:00  iox
   23  -rw-           394307   Jun 8 2018 01:26:51 +00:00  rtr1.config

7897378816 bytes total (7073292288 bytes free)
rtr1#

```




#### Step 7

Now that the known good configuration is on the destination devices, add a new task to the playbook to replace the running configuration with the one we copied over.



``` yaml
{%raw%}
---
- name: RESTORE CONFIGURATION
  hosts: cisco
  connection: network_cli
  gather_facts: no

  tasks:
    - name: COPY RUNNING CONFIG TO ROUTER
      net_put: 
        src: ./backup/{{inventory_hostname}}.config
        dest: flash:/{{inventory_hostname}}.config
      vars:
        ansible_command_timeout: 120

    - name: CONFIG REPLACE
      ios_command:
        commands:
          - config replace flash:{{inventory_hostname}}.config force

{%endraw%}
```


> Note: Here we take advantage of Cisco's **archive** feature. The config replace will only update the differences to the router and not really a full config replace.


#### Step 8

Let's run the updated playbook:

```

[student1@ansible networking-workshop]$ ansible-playbook -i lab_inventory/hosts restore_config.yml -v

PLAY [RESTORE CONFIGURATION] *********************************************************

TASK [COPY RUNNING CONFIG TO ROUTER] *************************************************
changed: [rtr1]
changed: [rtr3]
changed: [rtr2]
changed: [rtr4]

TASK [CONFIG REPLACE] ****************************************************************
ok: [rtr2] => changed=false 
  stdout:
  - |-
    Total number of passes: 0
    Rollback Done
  stdout_lines: <omitted>
ok: [rtr4] => changed=false 
  stdout:
  - |-
    Total number of passes: 0
    Rollback Done
  stdout_lines: <omitted>
ok: [rtr3] => changed=false 
  stdout:
  - |-
    Total number of passes: 0
    Rollback Done
  stdout_lines: <omitted>
ok: [rtr1] => changed=false 
  stdout:
  - |-
    Total number of passes: 1
    Rollback Done
  stdout_lines: <omitted>

PLAY RECAP ***************************************************************************
rtr1                       : ok=2    changed=1    unreachable=0    failed=0   
rtr2                       : ok=2    changed=1    unreachable=0    failed=0   
rtr3                       : ok=2    changed=1    unreachable=0    failed=0   
rtr4                       : ok=2    changed=1    unreachable=0    failed=0   

[student1@ansible networking-workshop]$


```


#### Step 9



Validate that the new loopback interface we added in **Step 1**  is no longer on the device.


```
[student1@ansible networking-workshop]$ ssh rtr1



rtr1#sh ip int br
Interface              IP-Address      OK? Method Status                Protocol
GigabitEthernet1       172.16.165.205  YES DHCP   up                    up      
Loopback0              192.168.1.101   YES manual up                    up      
Loopback1              10.1.1.101      YES manual up                    up      
Tunnel0                10.100.100.1    YES manual up                    up      
Tunnel1                10.200.200.1    YES manual up                    up      
VirtualPortGroup0      192.168.35.101  YES TFTP   up                    up      
rtr1#sh run inter
rtr1#sh run interface Loo
rtr1#sh run interface Loopback 101
                               ^
% Invalid input detected at '^' marker.

rtr1#

```

The output above shows that the Loopback 101 interface is no longer present, you have successfully backed up and restored configurations on your Cisco routers!

### Step 10 Alternative code
``` yaml
---
- name: RESTORE CONFIGURATION
  hosts: cisco
  connection: network_cli
  gather_facts: no

  tasks:
    - name: COPY RUNNING CONFIG TO ROUTER
      command: scp ./backup/{{inventory_hostname}}.config {{inventory_hostname}}:/{{inventory_hostname}}.config

    - name: CONFIG REPLACE
      ios_command:
        commands:
          - config replace flash:{{inventory_hostname}}.config force

```

# Complete

You have completed lab exercise 2.2

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTM5NjQ4MjcyLC0yMDUxNjIzNzQ3LC0xMj
U5MzcxODE1LC0xNjI1MDUwNzUsLTE5OTM5MTcwMzFdfQ==
-->