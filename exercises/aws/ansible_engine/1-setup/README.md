# Exercise 1 - Setup Access

Before we can start to automate using AWS, there are a number of things we need to setup first.

## Step 1 - Login To Your Control Node

We need somewhere to run Ansible Engine from initially, as a kind of control point.

We have prepared a RHEL server for you to use, so go ahead and log in now.

```bash
ssh studentN@public_IP_address
```

## Step 2 - Clone The Repo

```bash
git clone https://github.com/pharriso/linklight.git
```

## Step 3 - AWS SDK
We need to install a few Python features so we can use AWS, as the Ansible modules use these.

```bash
pip install boto boto3 botocore --user
```

## Step 4 - AWS Credentials

In order to access the necessary EC2 services within AWS, we need to have certain privileges.

An IAM user with a role to perform the necessary actions has already been created.

We'll be using time-based STS tokens as well for the duration of the workshop.

We'll store the details in an encrypted ansible-vault file so they are secure.

Please ask your instructor to provide the necessary details to go into the vault file.

```bash
cd linklight/exercises/aws/ansible_engine
ansible-vault create aws_keys.yml
```

Add the credentials supplied by your instructor and save the file.

You'll be asked for a new vault password:

```bash
New Vault password:
Confirm New Vault password:
```

This will be used throughout the following exercises, so make it memorable!

This completes this exercise.

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../../README.md)
