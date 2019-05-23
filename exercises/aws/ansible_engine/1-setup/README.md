# Exercise 1 - Setup Access

Before we can start to automate using AWS, there are a number of things we need to setup first.

## Step 1.1 - AWS Credentials

In order to access the necessary EC2 services within AWS, we need to setup privileges.
To do this, we'll store them in an encrypted ansible-vault file so they are secure.
Please ask your instructor to provide the necessary details to go into the vault file.

```bash
ansible-vault create aws_keys.yml
```

Add the credentials supplied by your instructor.

## Step 1.2 - Test Access - how?

Can we use a dynamic inventory pull for this?

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../README.md)
