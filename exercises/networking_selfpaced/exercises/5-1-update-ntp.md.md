# Exercise 5.1 - Updating ntp using Ansible

Using Ansible you can update the configuration of routers either by pushing a configuration file to the device or you can push configuration lines directly to the device.  Herein you will see how to update ntp.

#### Step 1

Create a new file called `update-ntp.yml` (use either `vim` or `nano` on the jumphost to do this or use a local editor on your laptop and copy the contents to the jumphost later). Add the following play definition to it:


``` 
cat << EOF > update-ntp.yml
---
- hosts: cisco
  gather_facts: no


  vars:
  
    ntp_servers:
      - ntp server 216.239.35.0
      - ntp server 216.239.35.4

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

Create a new file called `checkntp.yml` (use either `vim` or `nano` on the jumphost to do this or use a local editor on your laptop and copy the contents to the jumphost later). Add the following play definition to it:


``` yaml
---
- hosts: cisco
  gather_facts: no

  tasks:
  
  - name: get the current ntp server configs
    ios_command:
      commands:
        - "show ntp status "
    register: ntp_status

  - debug: var=ntp_status.stdout_lines

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
eyJoaXN0b3J5IjpbODU1NTk5NDc3LDE5NTM1MzU4OTZdfQ==
-->