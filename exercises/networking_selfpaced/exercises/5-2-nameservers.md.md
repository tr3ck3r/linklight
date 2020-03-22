
# Exercise 5.1 - Updating name servers using Ansible

Using Ansible you can update the configuration of routers either by pushing a configuration file to the device or you can push configuration lines directly to the device.  Herein you will see how to update DNS.

#### Step 1

Create a new file called `nameserver-update.yml` (use either `vim` or `nano` on the jumphost to do this or use a local editor on your laptop and copy the contents to the jumphost later). Add the following play definition to it:


``` 
cat << EOF > nameserver-update.yml
---
- hosts: cisco
  gather_facts: no

  vars:
    name_servers:
      - ip name-server 8.8.8.8
      - ip name-server 8.8.4.4

  tasks:
  - name: GET CURRENT DNS SETTINGS
    ios_command:
      commands:
        - "show running-config full | include ip name-server "
    register: get_config

  - debug: var=get_config.stdout_lines

  - name: SET NAMESERVER COMMANDS
    with_items: "{{ name_servers }}"
    ios_config:
      lines:
          - "{{ item }}"
          - "ip domain-lookup"
    register: set_nameserver

  - name: REMOVE EXTRA NAME SERVERS COMMANDS
    when: "(get_config.stdout_lines[0] != '') and (item not in name_servers)"
    with_items: "{{ get_config.stdout_lines[0] }}"
    register: remove_nameserver
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
> NTP is a slow protocol, and the formation of NTP associations can take a long time. So, don't expect anything to happen fast. Synchronization may take many minutes to complete.

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
eyJoaXN0b3J5IjpbMzY5NzM1MTI5XX0=
-->