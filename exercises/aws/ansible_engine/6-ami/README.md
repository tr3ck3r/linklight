# Exercise 6 - Roles

## Step 1 - Creating a custom AMI from an ec2 instance 

Let's create an AMI image from one of our ec2 instances using the ec2_ami module.

We'll also now introduce the concept of an Ansible role.


```bash
cd ~/linklight/exercises/aws/ansible_engine/6-ami
vi aws_ec2_ami.yml
```

Add the following lines, remember Ansible uses YAML to enforce indentation, so watch your spaces and tabs!

```bash
---

- name: create a custom AMI using a role
  hosts: localhost
  connection: local
  gather_facts: false
  vars_files:
    - ../aws_keys.yml

  roles:
    - ami
```

## Step 2 - What is a Role?


## Step 3 - Create the Role Structure

```bash
mkdir -p roles/ami/tasks group_vars
```

## Step 4 - Final Solution (optional)

If you hit issues and want to see it working, then run this:
```bash
ansible-playbook aws_ec2_ami_solution.yml --ask-vault
Vault password:

PLAY [create a custom AMI using a role] *********************************************************************************

TASK [ami : discover our filtered instance to clone] ********************************************************************
ok: [localhost]

TASK [ami : debug] ******************************************************************************************************
skipping: [localhost]

TASK [ami : create a custom AMI] ****************************************************************************************
changed: [localhost]

PLAY RECAP **************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0
```

That completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
