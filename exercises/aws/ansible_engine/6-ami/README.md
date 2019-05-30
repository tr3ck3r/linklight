# Exercise 6 - Roles

## Step 1 - Creating a custom AMI from an ec2 instance 

Let's create an AMI image from one of our ec2 instances using the ec2_ami module.

We'll also now introduce the concept of an Ansible ROLE 

A role is simply a way of grouping content and allowing it to be shareable with others.

(see https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) 

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

## Step 2 - What's the Difference?

Instead of storing all our playbook content in the same .yml file, we can store it elsewhere in a defined directory structure that Ansible recognises.

Notice the roles: declaration at the bottom. The playbook is looking for an 'ami' role.


## Step 3 - Create the Role Structure

We can use the ansible-galaxy command to create the directory structure for us, but this will create more than we need, and we can just make the necessary folders using:

```bash
mkdir -p roles/ami/tasks group_vars
```

The ami role is stored under the roles directory and inside that, there is a main.yml file within the tasks directory. This is what Ansible will run when calling the ami role.

```bash
$ cat roles/ami/tasks/main.yml

---

- name: discover our filtered instance to clone
  ec2_instance_facts:
    aws_access_key: "{{ aws_access_key }}"
    aws_secret_key: "{{ aws_secret_key }}"
    security_token: "{{ security_token }}"
    region: "{{region}}"
    filters:
      "tag:Name": "{{student}}-ansible-linux-1"
  register: output

- debug:
    msg: "ec2 instance ID is {{output.instances[0].instance_id}}"
    verbosity: 1

- name: create a custom AMI
  ec2_ami:
    aws_access_key: "{{ aws_access_key }}"
    aws_secret_key: "{{ aws_secret_key }}"
    security_token: "{{ security_token }}"
    region: "{{region}}"
    instance_id: "{{output.instances[0].instance_id}}"
    wait: no
    name: "{{student}}_ami"
    tags:
      myami: "{{student}}_ami"
```

What are we doing here?

Using the ec2_instance_facts module to filter out details about the instance we want.

We save the output so it can be re-used in the ec2_ami module as a reference for the image creation.

## Step 4 - Using group_vars

Notice that there is also a group_vars/all file, which is a way to store common config/variables across your roles. 

```bash
$ cat group_vars/all

region: eu-west-2
security_group: "{{student}}_sg"
keypair: laptop
```

To save repeating these common variables we store them here.

## Step 4 - Run the Playbook

Now run this to see it in action:

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
