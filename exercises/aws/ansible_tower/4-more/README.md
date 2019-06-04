# Exercise 4 - Adding in the Other Job Templates

Let's revise, git commit and sync the rest of the playbooks we wrote so we can consume then in Tower.

## Revise the Playbooks

Makes the mods to the other playbooks as per exercise 2:

```bash
cd ~/linklight/exercises/aws/ansible_engine
```

In turn, edit the following files, namely:

```bash
3-instances/aws_ec2_instances.yml
4-loadbalancer/aws_ec2_elb.yml
5-addservices/aws_ec2_web_servers.yml
6-ami/aws_ec2_ami.yml
```

As a reminder, remove/modify the following:

Remove the vars_files lines near the top:

```bash
  vars_files:
    - ../aws_keys.yml
```

Also remove ALL occurences of these lines, as Tower will use the AWS credentials in its place:

```bash
        aws_access_key: "{{ aws_access_key }}"
        aws_secret_key: "{{ aws_secret_key }}"
        security_token: "{{ security_token }}"
```

Finally add in your student number variable as this was stored in the vault file, which we've removed.

Your vars section should now look like:

```bash
  vars:
    student: student2
    security_group: "{{student}}_sg"
    region: eu-west-2
```

## Git Commit 

```bash
git add 3-instances/aws_ec2_instances.yml
git add 4-loadbalancer/aws_ec2_elb.yml
git add 5-addservices/aws_ec2_web_servers.yml
git add 6-ami/aws_ec2_ami.yml
git commit -m "More playbooks" -a
git push origin master
```

## Tower Project Sync


## Create Job Templates

---

[Click Here to return to the Ansible AWS Workshop](../../README.md)
