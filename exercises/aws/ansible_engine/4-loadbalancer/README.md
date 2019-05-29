# Exercise 4 - More Playbook Action

## Step 1 - Creating an Elastic Load Balancer (ELB)

We're going to stick a load balancer in front of our newly created instances.


```bash
cd ~/linklight/exercises/aws/ansible_engine/4-loadbalancer
vi aws_ec2_elb.yml
```

Add the following lines, remember Ansible uses YAML to enforce indentation, so watch your spaces and tabs!

```bash
---
- hosts: localhost
  connection: local
  gather_facts: false
  ignore_errors: true
  vars:
    region: "eu-west-2"
    elb_name: "{{student}}-elb"
  vars_files:
    - ../aws_keys.yml

  tasks:

    - name: create load balancer
      ec2_elb_lb:
        aws_access_key: "{{aws_access_key}}"
        aws_secret_key: "{{aws_secret_key}}"
        security_token: "{{security_token}}"
        region: "{{region}}"
        zones:
          - "{{region}}a"
        name: "{{elb_name}}"
        state: present
        listeners:
          - protocol: http
            load_balancer_port: 80
            instance_port: 80
            proxy_protocol: True

    - name: gather ec2 instances
      ec2_instance_facts:
        aws_access_key: "{{aws_access_key}}"
        aws_secret_key: "{{aws_secret_key}}"
        security_token: "{{security_token}}"
        region: "{{region}}"
        filters: 
          instance-state-name: "running"
          "tag:student": "{{student}}"
      register: instances

    - name: add instances to elb
      elb_instance:
        aws_access_key: "{{aws_access_key}}"
        aws_secret_key: "{{aws_secret_key}}"
        security_token: "{{security_token}}"
        region: "{{region}}"
        instance_id: "{{item.instance_id}}"
        ec2_elbs: "{{elb_name}}"
        state: present
      with_items: "{{instances.instances}}"
```

## Step 2 - Run the Playbook

Let's create the instances!

```bash
$ ansible-playbook aws_ec2_elb.yml --ask-vault-pass
Vault password:
```

NOTE: This is going to FAIL! This is by design, as we've yet to setup any web service on our instances which the ELB relates to.
In order for the playbook to 'work', we use 'ignore_errors: true'. The default is false, which would make the playbook stop.

## Step 3 - Playbook Explanation

Whilst you wait for the ELB to be created, let's re-examine the playbook and explain what it's doing.

The first play uses the ec2_elb_lb module to create the ELB for us.

```bash
    - name: create load balancer
      ec2_elb_lb:
        aws_access_key: "{{aws_access_key}}"
        aws_secret_key: "{{aws_secret_key}}"
        security_token: "{{security_token}}"
        region: "{{region}}"
        zones:
          - "{{region}}a"
        name: "{{elb_name}}"
        state: present
        listeners:
          - protocol: http
            load_balancer_port: 80
            instance_port: 80
            proxy_protocol: True
```

Now we use the ec2_instance_facts module to find our instances based on filters for a running state and student number tag.

```bash
    - name: gather ec2 instances
      ec2_instance_facts:
        aws_access_key: "{{aws_access_key}}"
        aws_secret_key: "{{aws_secret_key}}"
        security_token: "{{security_token}}"
        region: "{{region}}"
        filters: 
          instance-state-name: "running"
          "tag:student": "{{student}}"
      register: instances
```

We can then add those instances into the ELB. Neat eh?

```bash
    - name: add instances to elb
      elb_instance:
        aws_access_key: "{{aws_access_key}}"
        aws_secret_key: "{{aws_secret_key}}"
        security_token: "{{security_token}}"
        region: "{{region}}"
        instance_id: "{{item.instance_id}}"
        ec2_elbs: "{{elb_name}}"
        state: present
      with_items: "{{instances.instances}}"
```

## Step 4 - Final Solution (optional)

If you hit issues and want to see it working, then run this:
```bash
ansible-playbook aws_ec2_elb_solution.yml --ask-vault-pass
```

That completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
