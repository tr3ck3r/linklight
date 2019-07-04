# Exercise 3 - More Playbook Action

## Step 1 - Creating ec2 Instances

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
        name: "RHEL-7.6_HVM_GA*"
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
        keypair: aws-workshop
        instance_count: 2

      ec2_instance:
        aws_access_key: "{{ aws_access_key }}"
        aws_secret_key: "{{ aws_secret_key }}"
        security_token: "{{ security_token }}"
        name: "{{student}}-ansible-{{os}}-{{item}}"
        security_group: "{{security_group}}"
        key_name: "{{keypair}}"
        network:
          assign_public_ip: true
        image_id: "{{ami_id}}"
        region: "{{region}}"
        tags:
          student: "{{student}}"
      with_sequence: count="{{instance_count}}"
      register: ec2_instances
```

## Step 2 - Run the Playbook

Let's create the instances!

```bash
$ ansible-playbook aws_ec2_instances.yml --ask-vault-pass
Vault password:
```

The output should resemble this:

```bash
Vault password:

PLAY [localhost] ******************************************************************************************************************************

TASK [Find latest RedHat Linux AMI to use] ****************************************************************************************************
ok: [localhost]

TASK [debug] **********************************************************************************************************************************
skipping: [localhost]

TASK [Save the AMI ID so we can re-use] *******************************************************************************************************
ok: [localhost]

TASK [Launch LINUX instance(s)] ***************************************************************************************************************
changed: [localhost]

PLAY RECAP ************************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0
```

## Step 3 - Playbook Explanation

Whilst you wait for your instance(s) to be created, let's re-examine the playbook and explain what it's doing.

The first module we use is ec2_ami_find, which allows us to find the right AMI for the region. AMIs can have different IDs, or not even exist in other regions, so this is a good way to ensure we get what we want!

In this case, we're finding and selecting the latest RHEL7.6 GA image, provided by Red Hat (owner), and saving the output to a variable 'ami_find'

```bash
 - name: Find latest RedHat Linux AMI to use
      ec2_ami_find:
        aws_access_key: "{{ aws_access_key }}"
        aws_secret_key: "{{ aws_secret_key }}"
        security_token: "{{ security_token }}"
        region: "{{region}}"
        name: "RHEL-7.6_HVM_GA*"
        owner: 309956199498
        sort: name
        sort_order: descending
        sort_end: 1
      register: ami_find
```

The next section is a best practice tip, when using debugging. 

We can check what AMI ID got returned, but it'll only fire when we've used a -v with the ansible-playbook run.
This keeps your output cleaner.

```bash
   - debug:
        msg: "This is the AMI ID {{ami_find.results[0].ami_id}}"
        verbosity: 1
```

We use the set_fact module to save the AMI ID to a variable 'ami_id' so we can re-use

```bash
    - name: Save the AMI ID so we can re-use
      set_fact:
        ami_id: "{{ami_find.results[0].ami_id}}"
```

Now for the real work! Creating the instance(s)

We use a combination of variables and tags so each students resources can be easily identified and the ec2_instance module does the work for us. Using the with_sequence plugin allows us to create '$instance_count' instances, where each instance is represented by 'item' in the loop.


```bash
    - name: Launch LINUX instance(s)
      vars:
        security_group: "{{student}}_sg"
        ami_id: "{{ami_id}}"
        ec2_instance_name: ansible-linux
        os: linux
        remote_port: 22
        keypair: aws-workshop
        instance_count: 2


      ec2_instance:
        aws_access_key: "{{ aws_access_key }}"
        aws_secret_key: "{{ aws_secret_key }}"
        security_token: "{{ security_token }}"
        name: "{{student}}-ansible-{{os}}-{{item}}"
        security_group: "{{security_group}}"
        network:
          assign_public_ip: true
        image_id: "{{ami_id}}"
        region: "{{region}}"
        tags:
          student: "{{student}}"
      with_sequence: count="{{instance_count}}"
      register: ec2_instances
```

## Step 4 - Final Solution (optional)

If you hit issues and want to see it working, then run this:
```bash
ansible-playbook aws_ec2_instances_solution.yml --ask-vault-pass
```

That completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
