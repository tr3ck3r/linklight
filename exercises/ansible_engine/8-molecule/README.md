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

## Section 2: Creating a New Role

Let's use the simple Apache playbook we created earlier and extend it into a molecule based role.

### Step 1 - Prep

```bash
$ cd ~/apache_basic
$ mkdir roles
$ cd roles
```

### Step 2 - Initalise New Role

```bash
$ molecule init role --role-name apache_install --driver-name docker
--> Initializing new role apache_install...
Initialized role in /home/student1/apache_basic/roles/apache_install successfully.
```

Let's have a look at what was created:

```bash
$ tree
.
└── apache_install                            <--- role name as supplied
    ├── defaults                              <--- default values to variables for the role
    │   └── main.yml
    ├── handlers                              <--- specific handlers to notify based on actions
    │   └── main.yml
    ├── meta                                  <---  info for the role if you are uploading this to Ansible-Galaxy
    │   └── main.yml
    ├── molecule                              <--- molecule specific information 
    │   └── default
    │       ├── Dockerfile.j2
    │       ├── INSTALL.rst
    │       ├── molecule.yml
    │       ├── playbook.yml
    │       └── tests
    │           ├── test_default.py
    │           └── test_default.pyc
    ├── README.md                             <--- information about the role
    ├── tasks                                 <--- tasks for the role
    │   └── main.yml
    └── vars                                  <--- other variables for the role
        └── main.yml
```

This command uses ansible-galaxy behind the scenes to generate a new Ansible role. It then injects a molecule directory in the role, and sets it up to run builds and test runs in a docker environment.

The molecule/default directory is probably the most interesting:

#### Dockerfile.j2: 
This is the Dockerfile used to build the Docker container used as a test environment for your role. You can customize it to your heart's content, and you can even use your own Docker image instead of building the container from scratch every time—I'll cover how to do that later though. The key is this makes sure important dependencies like Python, sudo, and Bash are available inside the build/test environment.

#### INSTALL.rst: 
Contains instructions for installing required dependencies for running molecule tests.

#### molecule.yml: 
Tells molecule everything it needs to know about your testing: what OS to use, how to lint your role, how to test your role, etc. We'll cover a little more on this later.

#### playbook.yml:
This is the playbook Molecule uses to test your role. For simpler roles, you can usually leave it as-is (it will just run your role and nothing else). But for more complex roles, you might need to do some additional setup, or run other roles prior to running your role.

#### tests/:
This directory contains a basic Testinfra test, which you can expand on if you want to run additional verification of your build environment state after Ansible's done its thing

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
