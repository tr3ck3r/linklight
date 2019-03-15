# Exercise 9 - Using Blocks with Tags and Passing Extra Vars

Now we've got a good handle on the basics, let's use some of the more advanced features.

## In this lession, we'll use:

[Blocks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_blocks.html#blocks)

Blocks allow for logical grouping of tasks and in play error handling.

[Tags](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html#tags)

Useful for breaking up large playbooks into specific parts.

[Extra Vars](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#passing-variables-on-the-command-line)

This is a way to pass variables in from the CLI. This can be useful for more dynamic plays and things like Tower callbacks.

Let's create a playbook that uses all these features.


## Section 1: Defining Your Play

Use vi to create the playbook file linux-accounts.yml:

```bash
$ vi linux-accounts.yml
```

We need privilege escalation to do things as root with user accounts, but don't need any facts so we'll disable collecting these to speed things up a little.

```yml
---
- name: Linux Account Admin
  hosts: web
  gather_facts: false
  become: yes
```

## Section 2: Adding a Block

The first block will enable us to disable a user account. We'll lock the account and set the shell to /bin/false.
Notice we also use the .lower function to ensure the account name is set to lowercase, which Linux expects.

If an error occurs, the rescue section will fire, and the always section will always run regardless.

We'll assign this block the 'disable' tag.

```yml
{% raw %}
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
{% endraw %}
```

## Section 3: Adding A Second Block

Now let's add another block for when we want to delete an account.
This follows the same structure, and we assign it the 'delete' tag


```yml
{% raw %}
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
{% endraw %}
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
{% raw %}
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
{% endraw %}
```


---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../README.md)
