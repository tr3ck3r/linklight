# Exercise 4 - Adding in the Other Job Templates

Let's revise, git commit and sync the rest of the playbooks we wrote so we can consume then in Tower.

## Revise the Playbooks

Let re-factor the playbooks into roles so they can share a common base and reduce duplication.

```bash
mkdir /home/student1/linklight/exercises/aws/ansible_engine/roles
cd /home/student1/linklight/exercises/aws/ansible_engine/roles
mkdir -p instances/tasks loadbalancer/tasks addservices/tasks addservices/templates addservices/vars addservices/handlers
cp -pr ../6-ami/roles/ami .
cp -pr ../6-ami/group_vars ..
```

Edit the following file:

```bash
vi ../groups_vars/all
```

Add your student variable in so it looks like:

```bash
student: student1
region: eu-west-2
security_group: "{{student}}_sg"
elb_name: "{{student}}-elb"
keypair: laptop
```

Now copy the original playbooks we created into the tasks folder for each role:

```bash
cp ../3-instances/aws_ec2_instances.yml instances/tasks/main.yml
cp ../4-loadbalancer/aws_ec2_elb.yml loadbalancer/tasks/main.yml
cp ../5-addservices/aws_ec2_web_servers.yml addservices/tasks/main.yml
cp ../5-addservices/templates/index.html.j2 addservices/templates
cp ../5-addservices/handlers/main.yml addservices/handlers
```

Now remove/modify the redundant parts from each of the above, as follows...

```bash
vi instances/tasks/main.yml
```

Change the contents to this:

```bash
---

- name: Find latest RedHat Linux AMI to use
  ec2_ami_find:
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
    keypair: laptop
    instance_count: 2

  ec2_instance:
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

- name: gather ec2 instance(s)
  ec2_instance_facts:
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

- name: add instance(s) to temp inventory
  add_host:
    hostname: "{{item.public_ip_address}}"
    groups: webservers
    ansible_connection: ssh
    ansible_user: ec2-user
  with_items: "{{instances.instances}}"
```

```bash
vi loadbalancer/tasks/main.yml
```

Change the contents to this:

```bash
---

- name: create load balancer
  ec2_elb_lb:
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
    region: "{{region}}"
    filters:
      instance-state-name: "running"
      "tag:student": "{{student}}"
  register: instances

- name: add instances to elb
  elb_instance:
    region: "{{region}}"
    instance_id: "{{item.instance_id}}"
    ec2_elbs: "{{elb_name}}"
    state: present
  with_items: "{{instances.instances}}"
```

```bash
vi addservices/tasks/main.yml
```

Change the contents to this:

```bash
---

- name: install httpd
  yum:
    name: httpd
    state: latest

- name: start and enable httpd service
  service:
    name: httpd
    state: started
    enabled: yes


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
  notify:
    - restart httpd
```

We now need to create the playbooks that will call the roles just created.

```bash
cd ~/linklight/exercises/aws/ansible_engine
```

The first one is for our load balancer:

```bash
vi ec2_elb.yml
```

Add the following:

```bash
---

- name: create our load balancer for our web servers
  hosts: localhost
  connection: local
  gather_facts: false

  roles:
    - loadbalancer
```

We can create one playbook for our instances creations and web server install/config if we like by calling 2 roles in the one playbook:

```bash
vi ec2_webservers.yml
```

Add the following:

```bash
---

- name: create our ec2 instances
  hosts: localhost
  connection: local
  gather_facts: false

  roles:
    - instances

- name: configure web services
  hosts: webservers
  become: true
  become_method: sudo

  roles:
    - addservices
```

## Git Commit 

```bash
cd ..
git add roles ec2_elb.yml ec2_webservers.yml
git commit -m "More playbooks" -a
git push origin master
```

## Tower Project Sync

Go to PROJECTS in Tower , and re-sync the Student Gitlab repo

![Ansible Tower Project Sync](aws-tower-project-sync.png)

## Create Job Templates

---

[Click Here to return to the Ansible AWS Workshop](../../README.md)
