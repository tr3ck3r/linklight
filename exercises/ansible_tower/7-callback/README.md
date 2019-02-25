# Exercise 7 - Tower API Job Launch

We can call into Ansible Tower via the API to run a job template for us.

We'll use the linux-accounts.yml example we did earlier to demonstate this.

## Adding The Job Template:

### Step 1:

Select TEMPLATES

### Step 2:

Click on ADD ![Add button](at_add.png), and select JOB TEMPLATE

### Step 3:

Complete the form using the following values

NAME |Linux Account Admin Template
-----|-------------------------
DESCRIPTION|Template for the Linux user account admin tasks
JOB TYPE|Run
INVENTORY|Ansible Workshop Inventory
PROJECT|Supplementary Project
PLAYBOOK|tower/linux-accounts.yml
MACHINE CREDENTIAL|Ansible Workshop Credential
LIMIT|web
OPTIONS|- [x] Enable Privilege Escalation

![Job Template Form](at_jt_detail.png)

## Job Launch Settings:

## Launching The Job:
curl example

## End Result
We've explored the Tower API callback facility in order to run a job template.


---

[Click Here to return to the Ansible Lightbulb - Ansible Tower Workshop](../README.md)
