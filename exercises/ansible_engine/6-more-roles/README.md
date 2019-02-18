# Exercise 6 - More Roles

For this exercise, you are going to add a further 'common' role to your existing work under exercise 5.

That's use Ansible Galaxy again to create a role structure. 

## Section 1: Using Ansible Galaxy to initialize a new role

Ansible Galaxy is a free site for finding, downloading, and sharing roles.  It's also pretty handy for creating them which is what we are about to do here.


### Step 1:

Navigate to your `apache-basic-playbook` roles project.

```bash
cd ~/apache-basic-playbook/roles
```

### Step 2:

Use the `ansible-galaxy` command to initialize a new role called `common/rhel`.

```bash
ansible-galaxy init common/rhel
```

We've created a 'common/rhel' directory so we can always come back and add another directory under 'common' for perhaps other operating systems (really?!) where some differentiation may be required.


## Section 2: Updating Your `site.yml` Playbook With The Newly Created `rhel` Role


### Step 1:

Revise the roles: statements to include and run our common rhel role first based on a conditional - a discovered fact ansible_os_family 

```yml
---
- hosts: web
  name: This is my updated role-based playbook
  become: yes

  roles:
    - { role: common/rhel, when: ansible_os_family == 'RedHat' }
    - apache-simple
```

### Step 2:

Add some default variables to your role in `roles/common/rhel/defaults/main.yml`.

```yml
---
# defaults file for common/rhel
apache_test_message: This is a test message
```

### Step 3:

Add some role-specific variables to your role in `roles/apache-simple/vars/main.yml`.

```yml
---
# vars file for common/rhel
httpd_packages:
  - httpd
  - mod_wsgi
```

### Step 6:

Add tasks to your role in `roles/apache-simple/tasks/main.yml`.

```yml
{% raw %}
{% endraw %}    
```

## Section 3: Running your new role-based playbook

Now that you've successfully updated your role based playbook,
let's run it and see how it works.

### Step 1:

Re-run the playbook.

```bash
ansible-playbook -i ~/lightbulb/lessons/lab_inventory/student##-instances.txt site.yml
```

## Section 4: Review

You should now have a completed playbook, `site.yml` with a couple of roles.


---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../README.md)
