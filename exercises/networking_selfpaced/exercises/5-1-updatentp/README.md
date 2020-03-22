# Exercise 2.0 - Updating the router configurations using Ansible

Using Ansible you can update the configuration of routers either by pushing a configuration file to the device or you can push configuration lines directly to the device.  Herein you will see how to update SNMP.

#### Step 1

Create a new file called `router_configs.yml` (use either `vim` or `nano` on the jumphost to do this or use a local editor on your laptop and copy the contents to the jumphost later). Add the following play definition to it:


``` yaml
---
- name: SNMP RO/RW STRING CONFIGURATION
  hosts: cisco
  gather_facts: no
  connection: network_cli

```

#### Step 2

Add a task to ensure that the SNMP strings `ansible-public` and `ansible-private` are present on all the routers. Use the `ios_config` module for this task

> Note: For help on the **ios_config** module, use the **ansible-doc ios_config** command from the command line or check docs.ansible.com. This will list all possible options with usage examples.


``` yaml

---
- name: FIX NTP
  hosts: cisco
  gather_facts: no
  connection: network_cli

  tasks:

    - name: ENSURE NTP IS CONFIGURED
      ios_config:
        commands:
          ntp_servers:
            - ntp server 216.239.35.0
            - ntp server 216.239.35.4
   tasks:

     - name: get the current ntp server configs
       ios_command:
         commands:
           - "show running-config full | include ntp server"
           register: get_config
           debug: var=get_config.stdout_lines
      - name: set ntp server commands
        with_items: "{{ ntp_servers }}"
          ios_config:
            lines:  
              - "{{ item }}"
          register: set_ntp

      - name: remove ntp server commands
        when: "(get_config.stdout_lines[0] != '') and (item not in ntp_servers)"
          with_items: "{{ get_config.stdout_lines[0] }}"
        register: remove_ntp
          ios_config:
            lines:
              - "no {{ item }}"
```

#### Step 3

Run the playbook:

``` shell
[student1@ansible networking-workshop]$ ansible-playbook -i lab_inventory/hosts router_configs.yml

PLAY [UPDATE THE SNMP RO/RW STRINGS] ********************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] *************************************************
changed: [rtr4]
changed: [rtr1]
changed: [rtr3]
changed: [rtr2]

PLAY RECAP **********************************************************************************************
rtr1                       : ok=1    changed=1    unreachable=0    failed=0   
rtr2                       : ok=1    changed=1    unreachable=0    failed=0   
rtr3                       : ok=1    changed=1    unreachable=0    failed=0   
rtr4                       : ok=1    changed=1    unreachable=0    failed=0   

[student1@ansible networking-workshop]$

```

Feel free to log in and check the configuration update:

```bash
ssh rtr1
rtr1#show snmp community
rtr1#show run | section snmp
rtr1# exit
```


#### Step 4

The `ios_config` module is idempotent. This means, a configuration change is  pushed to the device if and only if that configuration does not exist on the end hosts. To validate this, go ahead and re-run the playbook:


``` shell
[student1@ansible networking-workshop]$ ansible-playbook -i lab_inventory/hosts router_configs.yml  

PLAY [UPDATE THE SNMP RO/RW STRINGS] ********************************************************************************************************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] *************************************************************************************************************************************
ok: [rtr1]
ok: [rtr2]
ok: [rtr4]
ok: [rtr3]

PLAY RECAP **********************************************************************************************************************************************************************************
rtr1                       : ok=1    changed=0    unreachable=0    failed=0   
rtr2                       : ok=1    changed=0    unreachable=0    failed=0   
rtr3                       : ok=1    changed=0    unreachable=0    failed=0   
rtr4                       : ok=1    changed=0    unreachable=0    failed=0   

[student1@ansible networking-workshop]$



```

> Note: See that the **changed** parameter in the **PLAY RECAP** indicates 0 changes.


#### Step 5

Now update the task to add one more SNMP RO community string:


``` yaml
---
- name: UPDATE THE SNMP RO/RW STRINGS
  hosts: cisco
  gather_facts: no
  connection: network_cli

  tasks:

    - name: ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT
      ios_config:
        commands:
          - snmp-server community ansible-public RO
          - snmp-server community ansible-private RW
          - snmp-server community ansible-test RO
```



#### Step 6

This time however, instead of running the playbook to push the change to the device, execute it using the `--check` flag in combination with the `-v` or verbose mode flag:


``` shell
[student1@ansible networking-workshop]$ ansible-playbook -i lab_inventory/hosts router_configs.yml  --check -v
Using /home/student1/.ansible.cfg as config file

PLAY [UPDATE THE SNMP RO/RW STRINGS] ********************************************************************************************************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] *************************************************************************************************************************************
changed: [rtr3] => {"banners": {}, "changed": true, "commands": ["snmp-server community ansible-test RO"], "updates": ["snmp-server community ansible-test RO"]}
changed: [rtr1] => {"banners": {}, "changed": true, "commands": ["snmp-server community ansible-test RO"], "updates": ["snmp-server community ansible-test RO"]}
changed: [rtr2] => {"banners": {}, "changed": true, "commands": ["snmp-server community ansible-test RO"], "updates": ["snmp-server community ansible-test RO"]}
changed: [rtr4] => {"banners": {}, "changed": true, "commands": ["snmp-server community ansible-test RO"], "updates": ["snmp-server community ansible-test RO"]}

PLAY RECAP **********************************************************************************************************************************************************************************
rtr1                       : ok=1    changed=1    unreachable=0    failed=0   
rtr2                       : ok=1    changed=1    unreachable=0    failed=0   
rtr3                       : ok=1    changed=1    unreachable=0    failed=0   
rtr4                       : ok=1    changed=1    unreachable=0    failed=0   

[student1@ansible networking-workshop]$

```

The `--check` mode in combination with the `-v` flag will display the exact changes that will be deployed to the end device without actually pushing the change. This is a great technique to validate the changes you are about to push to a device before pushing it.

> Go ahead and log into a couple of devices to validate that the change has not been pushed.


Also note that even though 3 commands are being sent to the device as part of the task, only the one command that is missing on the devices will be pushed.


#### Step 7

Finally re-run this playbook again without the `-v` or `--check` flag to push the changes.

``` shell
[student1@ansible networking-workshop]$ ansible-playbook -i lab_inventory/hosts router_configs.yml  

PLAY [UPDATE THE SNMP RO/RW STRINGS] ********************************************************************************************************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] *************************************************************************************************************************************
changed: [rtr1]
changed: [rtr2]
changed: [rtr4]
changed: [rtr3]

PLAY RECAP **********************************************************************************************************************************************************************************
rtr1                       : ok=1    changed=1    unreachable=0    failed=0   
rtr2                       : ok=1    changed=1    unreachable=0    failed=0   
rtr3                       : ok=1    changed=1    unreachable=0    failed=0   
rtr4                       : ok=1    changed=1    unreachable=0    failed=0   

[student1@ansible networking-workshop]$
```


# Complete

You have completed lab exercise 2.0

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTU5MDE2MTgzMV19
-->