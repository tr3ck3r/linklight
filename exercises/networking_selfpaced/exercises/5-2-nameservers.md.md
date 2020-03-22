
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
      - ip domain-lookup

  tasks:
  - name: GET CURRENT DNS SETTINGS
    ios_command:
      commands:
        - "show running-config full | include (ip domain-lookup|ip name-server )"
    register: get_config

  - debug: var=get_config.stdout_lines

  - name: SET NAMESERVER COMMANDS
    with_items: "{{ name_servers }}"
    ios_config:
      lines:
          - "{{ item }}"
      match: exact
      replace: line
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
root@Ansible:~/networking-workshop# ansible-playbook -i lab_inventory/hosts -k nameserver-update.yml
```


#### Step 3
> NTP is a slow protocol, and the formation of NTP associations can take a long time. So, don't expect anything to happen fast. Synchronization may take many minutes to complete.

Create a new file called `nameserver-check.yml` (use either `vim` or `nano` on the jumphost to do this or use a local editor on your laptop and copy the contents to the jumphost later). Add the following play definition to it:


``` yaml
cat << EOF > nameserver-check.yml 
---
- hosts: cisco
  gather_facts: no

  tasks:
  
  - name: CHECK DNS LOOKUP
    ios_command:
      commands:
        - "ping pool.ntp.org repeat 1"
    register: nameserver_status

  - debug: var=nameserver_status.stdout_lines
EOF
```

```
ansible-playbook -i lab_inventory/hosts -k nameserver-check.yml --limit rtr1
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
eyJoaXN0b3J5IjpbLTY5MTQ0MjI4MywxOTkzNTE1OTY5LDQ1Mz
k5MzIwXX0=
-->