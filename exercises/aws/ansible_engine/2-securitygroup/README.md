# Exercise 2 - First Playbook

So we should be good to go now, with the correct config and credentials.

So let's start automating to test it out!

## Step 1 - Creating A Security Group

One of the first things we need to do in EC2, before we can do things like create instances, is to create an AWS Security Group. This is used to provide or deny access to other services.

We'll create a bare minimum playbook to spin up a new Security Group which will also serve to test out our credentials :)

```bash
cd ~/linklight/exercises/aws/ansible_engine/2-securitygroup
vi aws_security_group.yml
```

Add the following lines, remember Ansible uses YAML to enforce indentation, so watch your spaces and tabs!

```bash
---
- hosts: localhost
  connection: local
  gather_facts: False
  vars:
    security_group: "{{ student }}_sg"
    region: eu-west-2
    teardown: false
  vars_files:
    - ../aws_keys.yml
```

This is just setting up a few initial parameters and variables we'll be using.

Now add a task, which will use the ec2_group Ansible module to perform the action.

```bash
  tasks:
    - name: Create a security group
      ec2_group:
        aws_access_key: "{{ aws_access_key }}"
        aws_secret_key: "{{ aws_secret_key }}"
        security_token: "{{ security_token }}"
        region: "{{ region }}"
        name: "{{ security_group }}"
        description: The {{ student }} security group
        rules:
          - proto: tcp
            from_port: 22
            to_port: 22
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 80
            to_port: 80
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 443
            to_port: 443
            cidr_ip: 0.0.0.0/0
        rules_egress:
          - proto: all
            cidr_ip: 0.0.0.0/0
      when: not teardown

```

## Step 2 - Run the Playbook

We should have enough in our playbook now to create a Security Group in AWS, so let's test it out!

```bash
$ ansible-playbook aws_security_group.yml
ERROR! Attempting to decrypt but no vault secrets found
```

Oh wait, what went wrong?! Well Ansible knows we've used an encrypted Vault file but doesn't have anyway to decrypt it.

So we need a way to supply the password, which we can do by passing the --ask-vault-pass argument:

```bash
$ ansible-playbook aws_security_group.yml --ask-vault-pass
Vault password:
```

If you've got the password right, in a very short while Ansible should have created a Security Group for you.

The output should resemble this:

```bash
PLAY [localhost] *************************************************************************************************************

TASK [Create a security group] ***********************************************************************************************
changed: [localhost]

PLAY RECAP *******************************************************************************************************************
localhost                  : ok=1    changed=1    unreachable=0    failed=0
```

## Step 3 - Run the playbook again

Ansible is a desired start engine. So we can re-run the playbook and we shouldn't see any changes:

```bash
$ ansible-playbook aws_security_group.yml --ask-vault-pass
Vault password:
```

Note the output this time.

```bash
Vault password: 

PLAY [localhost] *****************************************************************************************************************************************************************************

TASK [Create a security group] ***************************************************************************************************************************************************************
ok: [localhost]

PLAY RECAP ***********************************************************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0   
```

We can also run playbooks with increased verbosity using -v. Let's try that.

```bash
$ ansible-playbook aws_security_group.yml --ask-vault-pass -v
Vault password:
```


## Step 4 - Adding a Delete Task

This is a great start, but we can easily extend the same playbook so we can use it to delete the Security Group as well.
We initially set a variable 'teardown' to false, so by default, we create the group. 

Add the following lines to the bottom of your playbook:

```bash
    - name: Delete a security group
      ec2_group:
        aws_access_key: "{{ aws_access_key }}"
        aws_secret_key: "{{ aws_secret_key }}"
        security_token: "{{ security_token }}"
        region: "{{ region }}"
        name: "{{ security_group }}"
        state: absent
      when: teardown
```

This will fire when teardown is set to 'true'. But we don't want to be editing the playbook each time we want to delete the group, so how can we do this on the fly?

Well we can set teardown to true, by passing it in as 'extra vars' via the command line.

Now try this:

```bash
ansible-playbook aws_security_group.yml --ask-vault-pass --extra-vars "teardown=true"
```

The output should resemble this:

```bash
PLAY [localhost] *************************************************************************************************************

TASK [Create a security group] ***********************************************************************************************
skipping: [localhost]

TASK [Delete a security group] ***********************************************************************************************
ok: [localhost]

PLAY RECAP *******************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0

```

Run it again if you'd like to check out that idempotence again :)

NOTE: Please ensure you have your studentN security group created, as it'll be used throughout the remaining exercises.

Either recall the command, or cut and paste this again:

```bash
$ ansible-playbook aws_security_group.yml --ask-vault-pass
Vault password:
```

## Step 5 - Final Solution (optional)

If you hit issues and want to see it working, then run this:
```bash
ansible-playbook aws_security_group_solution.yml --ask-vault-pass
```

That completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
