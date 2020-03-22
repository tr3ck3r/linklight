# Exercise 5.1 - Updating ntp using Ansible

Using Ansible you can update the configuration of routers either by pushing a configuration file to the device or you can push configuration lines directly to the device.  Herein you will see how to update ntp.

#### Step 1

Create a new file called `ntp-update.yml` (use either `vim` or `nano` on the jumphost to do this or use a local editor on your laptop and copy the contents to the jumphost later). Add the following play definition to it:


``` 
cat << EOF > update-ntp.yml
---
- hosts: cisco
  gather_facts: no


  vars:
  
    ntp_servers:
      - ntp server 216.239.35.0
      - ntp server 216.239.35.4
      - ntp server 192.168.122.101
      - ntp server 192.168.122.102
      - ntp server 192.168.122.103
      - ntp server 192.168.122.104
      - ntp server 23.129.64.227
      - ntp server 103.105.51.156


  tasks:
  
  - name: get the current ntp server configs
    ios_command:
      commands:
        - "show running-config full | include ntp server "
    register: get_config

  - debug: var=get_config.stdout_lines

  - name: set ntp server commands
    with_items: "{{ ntp_servers }}"
    ios_config:
      lines:
          - "{{ item }}"
          - "ntp update-calendar"
          - "clock timezone UTC 0"
    register: set_ntp

  - name: remove ntp server commands
    when: "(get_config.stdout_lines[0] != '') and (item not in ntp_servers)"
    with_items: "{{ get_config.stdout_lines[0] }}"
    register: remove_ntp
    ios_config:
      lines:
        - "no {{ item }}"

EOF
```

#### Step 2

Run the playbook:

``` shell
[student1@ansible networking-workshop]$ ansible-playbook -i lab_inventory/hosts updatentp.yml
```


#### Step 3
> NTP is a slow protocol, and the formation of NTP associations can take a long time. So, don't expect anything to happen fast. You can keep an eye on it using the  _debug ntp <option>_ set of commands.  Syncronization may take many mini


Create a new file called `ntp-check.yml` (use either `vim` or `nano` on the jumphost to do this or use a local editor on your laptop and copy the contents to the jumphost later). Add the following play definition to it:


``` yaml
cat << EOF > ntp-check.yml 
---
- hosts: cisco
  gather_facts: no

  tasks:
  
  - name: CHECK NTP SYNC
    ios_command:
      commands:
        - "show ntp status | inc Clock is"
    register: ntp_status

  - debug: var=ntp_status.stdout_lines
EOF
```

#### Step 4

Feel free to log in and check the ntp configuration :

```bash
ssh rtr1
rtr1#show ntp assoc
rtr1#show ntp status
rtr1#show run | section ntp
rtr1# exit
```


# Complete

You have completed lab exercise 2.0

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTM3MzEwNjE1OSwxMzU5OTIwMzA2LDI0OT
IyMDUxMiwxNTc1NDE1OTE3LDg1NTU5OTQ3Nyw4NTU1OTk0Nzcs
MTk1MzUzNTg5Nl19
-->