# Exercise 3 - More Playbook Action

## Step 3.1 - Creating ec2 Instances

Let's create a number of ec2 virtual machine instances so we can use them as an application platform.


```bash
cd ~/linklight/exercises/aws/ansible_engine/3-instances
vi aws_ec2_instances.yml
```

Add the following lines, remember Ansible uses YAML to enforce indentation, so watch your spaces and tabs!

```bash
---
- hosts: localhost
  connection: local
  gather_facts: false
  vars:
    region: "eu-west-2"
  vars_files:
    - ../aws_keys.yml

  tasks:

    - name: Find latest RedHat Linux AMI to use
      ec2_ami_find:
        aws_access_key: "{{ aws_access_key }}"
        aws_secret_key: "{{ aws_secret_key }}"
        security_token: "{{ security_token }}"
        region: "{{region}}"
        name: "RHEL-8*"
        owner: 309956199498 
        sort: name
        sort_order: descending
        sort_end: 1
      register: ami_find

    - debug:
        msg: "This is the AMI ID {{ami_find.results[0].ami_id}}"
        verbosity: 1

    - name: Save the AMI ID so we can re-use
      set_fact:
        ami_id: "{{ami_find.results[0].ami_id}}"

    - name: Launch LINUX instance(s)
      vars:
        security_group: "{{student}}_sg"
        ami_id: "{{ami_id}}"
        ec2_instance_name: ansible-linux
        os: linux
        remote_port: 22 
        keypair: laptop
        instance_count: 1

      ec2_instance:
        aws_access_key: "{{ aws_access_key }}"
        aws_secret_key: "{{ aws_secret_key }}"
        security_token: "{{ security_token }}"
        name: "{{student}}-ansible-{{os}}"
        security_group: "{{security_group}}"
        network:
          assign_public_ip: true
        image_id: "{{ami_id}}"
        region: "{{region}}"
        tags:
          student: "{{student}}"
      register: ec2_instance

```

## Step 2.2 - Run the Playbook

Let's create the instances!

```bash
$ ansible-playbook aws_ec2_instances.yml --ask-vault-pass
Vault password:
```

The output should resemble this:

```bash
```

## Step 2.3 - Playbook Explanation

Whilst you wait for your instance(s) to be created, let's re-examine the playbook and explain what it's doing.



## Step 3 - Final Solution (optional)

If you hit issues and want to see it working, then run this:
```bash
ansible-playbook aws_security_ec2_instances_solution.yml --ask-vault-pass
```

That completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
