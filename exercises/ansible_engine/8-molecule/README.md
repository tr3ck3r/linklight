# Exercise 8 - Using Molecule To Test Your Roles

Molecule is designed to aid in the development and testing of Ansible roles. Molecule provides support for testing with multiple instances, operating systems and distributions, virtualization providers, test frameworks and testing scenarios.

Molecule uses Ansible playbooks to exercise the role and its associated tests. So we eat our own dog food :)

In this exercise, we'll use molecule in association with docker to spin up and test our role.


## Section 1: Installing Components

SSH into your node

### Step 1 - Docker

We need to install and run the docker service. This will fire up our containers for testing images/roles.

```bash
$ sudo yum -y install gcc docker
$ sudo systemctl enable docker && sudo systemctl start docker
$ sudo systemctl status docker
```

### Step 2 - Molecule

We use pip to install molecule, but it needs gcc to compile so:

```bash
$ sudo yum -y install gcc
$ sudo pip install molecule
```

```bash
$ molecule
Usage: molecule [OPTIONS] COMMAND [ARGS]...

   _____     _             _
  |     |___| |___ ___ _ _| |___
  | | | | . | | -_|  _| | | | -_|
  |_|_|_|___|_|___|___|___|_|___|

  Molecule aids in the development and testing of Ansible roles.

  Enable autocomplete issue:

    eval "$(_MOLECULE_COMPLETE=source molecule)"

Options:
  --debug / --no-debug    Enable or disable debug mode. Default is disabled.
  -c, --base-config TEXT  Path to a base config.  If provided Molecule will
                          load this config first, and deep merge each
                          scenario's molecule.yml on top.
                          (/home/student1/.config/molecule/config.yml)
  -e, --env-file TEXT     The file to read variables from when rendering
                          molecule.yml. (.env.yml)
  --version               Show the version and exit.
  --help                  Show this message and exit.

Commands:
  check        Use the provisioner to perform a Dry-Run...
  converge     Use the provisioner to configure instances...
  create       Use the provisioner to start the instances.
  dependency   Manage the role's dependencies.
  destroy      Use the provisioner to destroy the instances.
  idempotence  Use the provisioner to configure the...
  init         Initialize a new role or scenario.
  lint         Lint the role.
  list         Lists status of instances.
  login        Log in to one instance.
  matrix       List matrix of steps used to test instances.
  prepare      Use the provisioner to prepare the instances...
  side-effect  Use the provisioner to perform side-effects...
  syntax       Use the provisioner to syntax check the role.
  test         Test (lint, destroy, dependency, syntax,...
  verify       Run automated tests against instances.
  
$ molecule --version
molecule, version 2.19.0
```

## Section 2: Adding a Block

The first block will enable us to disable a user account. We'll lock the account and set the shell to /bin/false.
Notice we also use the .lower function to ensure the account name is set to lowercase, which Linux expects.

If an error occurs, the rescue section will fire, and the always section will always run regardless.

We'll assign this block the 'disable' tag.

```yml
  tasks:

    - block:

        - name: Disable Local Linux User Account
          user:
            name: '{{ account|lower }}'
            password_lock: yes
            shell: /bin/false
            expires: 0

      rescue:
        - debug: msg='Oops! Something went wrong DISABLING the account - please investigate'

      always:
        - debug: msg='Tasks to disable Linux user account have been run'

      tags:
        - disable
```

## Section 3: Adding A Second Block

Now let's add another block for when we want to delete an account.
This follows the same structure, and we assign it the 'delete' tag


```yml
    - block:

        - name: Delete Local Linux User Account
          user:
            name: '{{ account|lower }}'
            state: absent
            remove: yes

      rescue:
        - debug: msg='Oops! Something went wrong DELETING the account - please investigate'

      always:
        - debug: msg='Tasks to delete Linux user account have been run'

      tags:
        - delete

```

## Section 4: Oh Wait A Minute!

If we were to run this playbook, by default, Ansible will run *all* tags. We don't want this. We need a sanity check as a safety net and a valid tag so we can run the right section only.

So add a line tags: never under the become: line for this. Also modify the name: line to reflect that we need a tag passed.

```yml
---
- name: Linux Account Admin (we do nothing without a valid tag)
  hosts: web
  gather_facts: false
  become: yes
  tags: never
```

## Section 5: Using Extra Vars to Run the Playbook With A Tag


The playbook expects a variable 'account' to be passed. We don't define this anywhere else so need to pass it on the command line.
We can use the --extra_vars or -e option to do this with ansible-playbook.

Notice what happens when we don't pass a tag:

```bash
$ ansible-playbook -i /home/student1/lightbulb/lessons/lab_inventory/student1-instances.txt linux-accounts.yml -e "account=fred"

PLAY [Linux Account Admin (we do nothing without a valid tag)] ******************************************************************************

PLAY RECAP *************
```

Now run the playbook as it should be, with both account variable and a valid tag (disable or delete):

```bash
$ ansible-playbook -i /home/student1/lightbulb/lessons/lab_inventory/student1-instances.txt linux-accounts.yml -e "account=FRed" --tags disable

PLAY [Linux Account Admin (we do nothing without a valid tag)] ******************************************************************************

TASK [Disable Local Linux User Account] *****************************************************************************************************
changed: [node2]
changed: [node3]
changed: [node1]

TASK [debug] ********************************************************************************************************************************
ok: [node1] => {
    "msg": "Tasks to disable Linux user account have been run"
}
ok: [node2] => {
    "msg": "Tasks to disable Linux user account have been run"
}
ok: [node3] => {
    "msg": "Tasks to disable Linux user account have been run"
}

PLAY RECAP **********************************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0
node2                      : ok=2    changed=1    unreachable=0    failed=0
node3                      : ok=2    changed=1    unreachable=0    failed=0
```

## Summary: The Finished Playbook

The final playbook should look like this:

```yml
---
- name: Linux Account Admin (we do nothing without a valid tag)
  hosts: web
  # we don't need any host facts, so disable to make run faster
  gather_facts: false
  become: yes
  tags: never

  tasks:

    - block:

        - name: Disable Local Linux User Account
          user:
            name: '{{ account|lower }}'
            password_lock: yes
            shell: /bin/false
            expires: 0

      rescue:
        - debug: msg='Oops! Something went wrong DISABLING the account - please investigate'

      always:
        - debug: msg='Tasks to disable Linux user account have been run'

      tags:
        - disable

    - block:

        - name: Delete Local Linux User Account
          user:
            name: '{{ account|lower }}'
            state: absent
            remove: yes

      rescue:
        - debug: msg='Oops! Something went wrong DELETING the account - please investigate'

      always:
        - debug: msg='Tasks to delete Linux user account have been run'

      tags:
        - delete
```


---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../README.md)
