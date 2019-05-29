# Exercise 5 - More Playbook Action

## Step 5.1 - Adding Web Services To Our Instances

Let's install HTTP web servers on our instances so that the ELB can load balance across them.


```bash
cd ~/linklight/exercises/aws/ansible_engine/5-addservices
vi aws_ec2_web_servers.yml
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

    - name: ensure we have SSH access
      wait_for:
        host: "{{item.public_ip_address}}"
        port: 22
        timeout: 300
      with_items: "{{instances.instances}}"

    - name: add instance to temp inventory
      add_host:
        hostname: "{{item.public_ip_address}}"
        groups: webservers
        ansible_connection: ssh
        ansible_user: ec2-user
      with_items: "{{instances.instances}}"

- hosts: webservers
  become: yes
  become_method: sudo

  vars:
    web_message: "YOUR CUSTOM MESSAGE GOES HERE"

  tasks:

    - name: install httpd
      yum:
        name: httpd
        state: latest

    - name: start and enable httpd service
      service:
        name: httpd
        state: started
        enabled: yes
```

## Step 4.2 - Run the Playbook

Just before running this playbook, let's check what it's doing. 

As before, we're checking for running instances with a certain tag (your student number).

Then we double check that SSH is accessible and add the hosts into a temporary inventory group called 'webservers'. We setup a couple of connection parameters that we'll need to access the ec2 instances.

Before we can successfully run this playbook, we'll need to have access to the private key for the 'laptop' key pair in AWS. 

<how to do this goes here...>

```bash
$ ansible-playbook aws_ec2_web_servers.yml --ask-vault-pass
Vault password:
```

## Step 4.3 - Extending the Playbook

Let's add to the playbook and create some custom web page content, by using a couple of discovered facts and a custome vars message. These will be displayed when you re-run and hit the ELB.

We'll use a Jinja2 template file for this content and also a service 'handler' for restarting httpd.

```bash
$ tree
.
├── aws_ec2_web_servers_solution.yml
├── handlers
│   └── main.yml
├── README.md
└── templates
    └── index.html.j2
```

The template file is stored in the templates directory. Take a look at the index.hmtl.j2 file:

```bash
$ cat templates/index.html.j2
```

Near the bottom you'll notice:

```bash
    <p>{{ inventory_hostname }}</p>
    <p>{{ web_message }}</p>
    <p>{{ ansible_os_family }}</p>
```

inventory_hostname and ansible_os_family are facts that Ansible discovers (using gather_facts) and will get populated into the template when copied over.

web_message is a local variable that we'll change in a minute.


## Step 4 - Final Solution (optional)

If you hit issues and want to see it working, then run this:
```bash
ansible-playbook aws_ec2_web_servers_solution.yml --ask-vault-pass
```

That completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
