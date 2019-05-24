# Exercise 3 - More Playbooks

So we're off to a good start! Let's create some more playbooks to automate more common EC2 tasks.


## Step 3.1 - Creating ec2 Instances

Let's create a number of ec2 virtual machine instances so we can use them as an application platform.


```bash
cd ~/linklight/exercises/aws/ansible_engine/3-extend
vi aws_ec2_instances.yml
```

Add the following lines, remember Ansible uses YAML to enforce indentation, so watch your spaces and tabs!

```bash
```

## Step 2.2 - Run the Playbook

Let's create some new instances!

```bash
$ ansible-playbook aws_ec2_instances.yml --ask-vault-pass
Vault password:
```

The output should resemble this:

```bash
```

That completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
