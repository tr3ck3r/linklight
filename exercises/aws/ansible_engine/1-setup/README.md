# Exercise 1 - Setup Access

Your custom environment has been prepared for you already. We'll go over some of the things that are in place.

## Step 1 - Login To Your Control Node

We need somewhere to run Ansible Engine from initially, as a kind of control point.

We have prepared a RHEL server for you to use, so go ahead and log in now.

```bash
ssh studentN@public_IP_address
```

## Step 2 - Your Environment

This git repo has been cloned into your home directory already. Have a look under ~/linklight/exercises/aws for details.

In order to automate against AWS the python 'boto' libraries are required. These have been pre-installed for you. You can check out details using:

```bash
pip freeze | grep boto
```

An encrypted ansible vault file has been created for you so you can securely access AWS EC2 resources. Your instructor will go over this with you now. This is just for reference, as you don't need to change anything (and shouldn't!)

Other necessary keys and tokens required throughout the day have also been created.

These include SSH keys for accessing your created instances, and access token for your own personal gitlab SCM.

Your instructor will highlight these as necessary throughout the workshop.

This completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
