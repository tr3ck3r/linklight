# Exercise 0.0 - Creating the lab environment

To get started, you are going to need four Cisco routers and an Ansible supporting Linux environment.  While this can be done a variety of ways, we are going to cover doing this with GNS3.

## Step 1

Install GNS3.  

You may chose to install it locally or on a remote server such as a VM Ware ESXi server.  Since we are only running five VMs; the requirements are light enough to work on many workstations.  This document will assume a remote GNS3 VM running in VM Ware ESXi environment.

## Step 2

Configure one routers and get the idle time optimized.  Simplest would be to use vIOS from Cisco if you have access to this.  You will need to support four router interfaces that are Gigabit Ethernet. 

Once the first router is working correctly, duplicate it three times.

## Step 4
Configure your Ansible environment.  You may chose to use an existing appliance or create your own from scratch.  It must have Ansible installed.  

For this documentation, Ubuntu will be used but other Linux OSes can be used.

## Step 3

Create a hub which will serve for the Out Of Band (OOB) connection between all devices.  Many of the labs can be done with only the OOB part of the network working; however, the goal is to configure a BGP connection between two data centers which are running OSPF internally.  Connect all Cisco routers up to OOB on the Gig0/3 interface and the Ansible on the single Ethernet interface. Interface selection on the hub does not matter.

## Step 4
Add a NAT cloud and connect it into the HUB.

## Step 5

Con

# Complete

You have completed lab exercise 0.0

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTk4OTYwOTY5Nl19
-->