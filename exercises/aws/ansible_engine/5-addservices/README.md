# Exercise 5 - More Playbook Action

## Step 1 - Adding Web Services To Our Instances

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

## Step 2 - Run the Playbook

Just before running this playbook, let's check what it's doing. 

As before, we're checking for running instances with a certain tag (your student number).

Then we double check that SSH is accessible and add the hosts into a temporary inventory group called 'webservers'. We setup a couple of connection parameters that we'll need to access the ec2 instances.

Before we can successfully run this playbook, we'll need to use the correct private key pair in AWS associated with our instances. 

Run the following commands so your SSH client recognises the required private key:

```bash
eval `ssh-agent`
ssh-add ~/.ssh/aws-workshop.pem
ssh-add -l
2048 SHA256:V1bJqxGu1HVqmg/SUGRm20wb3rAdKZ/+zPfiyhtF3+M /home/student2/.ssh/aws-workshop.pem (RSA)
```

Now go ahead and run the playbook:

```bash
ansible-playbook aws_ec2_web_servers.yml --ask-vault-pass
Vault password:
```

## Step 3 - Extending the Playbook

Let's add to the playbook and create some custom web page content, by using a couple of discovered facts and a custom vars message. These will be displayed when you re-run and hit the ELB.

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

Now go ahead and add this further content to the existing  playbook:

```bash
vi aws_ec2_web_servers.yml
```

Change the web_message string in quotes to whatever you want displayed (keep it clean please!)

Now add this at the bottom:

```bash
    - name: Check if firewalld is running
      shell: systemctl is-active firewalld
      register: firewall_status
      ignore_errors: true

    - name: Open firewall ports for httpd
      firewalld:
        port: 80/tcp
        permanent: true
        state: enabled
        immediate: true
      when: firewall_status.stdout == 'active'

    - name: Configure Web Content
      template:
        dest: /var/www/html/index.html
        src: index.html.j2
```

We've added a nifty local firewalld check as well here just for good measure :)

Run the playbook again:

```bash
$ ansible-playbook aws_ec2_web_servers.yml --ask-vault-pass
Vault password:
```

Then go hit your ELB load balancer to check the updates.

If you can't remember the address of your ELB, run this:

```bash
 ansible-playbook $HOME/linklight/exercises/aws/ansible_engine/4-loadbalancer/aws_ec2_elb_facts.yml --ask-vault
Vault password:

PLAY [localhost] ********************************************************************************************************

TASK [discover facts about my ELB] **************************************************************************************
ok: [localhost]

TASK [show me the DNS name of my ELB] ***********************************************************************************
ok: [localhost] =>
  msg: student1-elb-314359906.eu-west-2.elb.amazonaws.com

PLAY RECAP **************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0
```

## Step 4 - Final Solution (optional)

If you hit issues and want to see it working, then run this:
```bash
ansible-playbook aws_ec2_web_servers_solution.yml --ask-vault-pass
```

You should see something similar to this (output truncated)

```bash
PLAY [webservers] *******************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************
ok: [18.130.190.158]
ok: [52.56.81.99]

TASK [install httpd] ****************************************************************************************************
ok: [52.56.81.99]
ok: [18.130.190.158]

TASK [start and enable httpd service] ***********************************************************************************
ok: [18.130.190.158]
ok: [52.56.81.99]

TASK [Check if firewalld is running] ************************************************************************************
fatal: [18.130.190.158]: FAILED! => changed=true
  cmd: systemctl is-active firewalld
  delta: '0:00:00.005732'
  end: '2019-05-29 17:26:52.549549'
  msg: non-zero return code
  rc: 3
  start: '2019-05-29 17:26:52.543817'
  stderr: ''
  stderr_lines: []
  stdout: unknown
  stdout_lines: <omitted>
...ignoring
fatal: [52.56.81.99]: FAILED! => changed=true
  cmd: systemctl is-active firewalld
  delta: '0:00:00.005596'
  end: '2019-05-29 17:26:52.580800'
  msg: non-zero return code
  rc: 3
  start: '2019-05-29 17:26:52.575204'
  stderr: ''
  stderr_lines: []
  stdout: unknown
  stdout_lines: <omitted>
...ignoring

TASK [Open firewall ports for httpd] ************************************************************************************
skipping: [18.130.190.158]
skipping: [52.56.81.99]

TASK [Configure Web Content] ********************************************************************************************
ok: [18.130.190.158]
ok: [52.56.81.99]

PLAY RECAP **************************************************************************************************************
18.130.190.158             : ok=5    changed=1    unreachable=0    failed=0
52.56.81.99                : ok=5    changed=1    unreachable=0    failed=0
localhost                  : ok=3    changed=1    unreachable=0    failed=0
```

That completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
