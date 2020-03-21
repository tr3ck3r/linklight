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
Connect the routers together as per the diagram.  RTR1 and RTR2 are to be connected on G0/0 to one another, RTR1 should connect to RTR3 on G0/1, and RTR2 should connect to RTR4 on G0/1.
## Step 6

Use the following minimal configuration provided for the Cisco devices (there might be room for improvement but this will get your devices connected to do exercises).  We will be hardening the devices using Ansible later; this just brings the devices up so that Ansible can reach them.

### RTR1
```
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
no aaa new-model
!
hostname rtr1
!
no ip domain lookup
ip domain name domain-name
!
username cisco privilege 15 password 0 cisco
!
interface Loopback0
 ip address 172.16.0.1 255.255.255.255
!
interface GigabitEthernet0/0
 ip address 10.200.200.1 255.255.255.0
 no shutdown
!
interface GigabitEthernet0/1
 ip address 10.100.100.1 255.255.255.0
 no shutdown
!
interface GigabitEthernet0/3
 ip address 192.168.122.101 255.255.255.0
 no shutdown
!
router ospf 1
 redistribute bgp 100 subnets
 network 10.100.100.0 0.0.0.255 area 0
 network 172.16.0.1 0.0.0.0 area 0
!
router bgp 100
 bgp log-neighbor-changes
 bgp redistribute-internal
 network 10.200.200.0 mask 255.255.255.0
 network 172.16.0.1 mask 255.255.255.255
 redistribute ospf 1
 neighbor 10.200.200.2 remote-as 100
!
ip route 0.0.0.0 0.0.0.0 192.168.122.1
ip ssh version 2
!
line con 0
 exec-timeout 0 0
 privilege level 15
 logging synchronous
line vty 0 4
 login local
 transport input ssh
!
! Generate SSH key
crypto key generate rsa modulus 1024
!
end

```

### RTR2
```
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
!
hostname rtr2
!
boot-start-marker
boot-end-marker
!
!
!
no aaa new-model
ethernet lmi ce
!
!
!
no ip domain lookup
ip domain name domain-name
!
username cisco privilege 15 password 0 cisco
!
interface Loopback0
 ip address 172.16.0.2 255.255.255.255
!
interface GigabitEthernet0/0
 ip address 10.200.200.2 255.255.255.0
 no shutdown
!
interface GigabitEthernet0/1
 ip address 10.101.101.1 255.255.255.0
 no shutdown
!
interface GigabitEthernet0/3
 ip address 192.168.122.102 255.255.255.0
 no shutdown
!
router ospf 1
 redistribute bgp 100 subnets
 network 10.101.101.0 0.0.0.255 area 0
 network 172.16.0.2 0.0.0.0 area 0
!
router bgp 100
 bgp log-neighbor-changes
 bgp redistribute-internal
 network 10.200.200.0 mask 255.255.255.0
 network 172.16.0.2 mask 255.255.255.255
 redistribute ospf 1
 neighbor 10.200.200.1 remote-as 100
!
ip route 0.0.0.0 0.0.0.0 192.168.122.1
ip ssh version 2
!
line con 0
 exec-timeout 0 0
 privilege level 15
 logging synchronous
line vty 0 4
 login local
 transport input ssh
!
! Generate SSH key
crypto key generate rsa modulus 1024
!
end
```

### RTR3
```

service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
!
hostname rtr3
!
!
no aaa new-model
!
no ip domain lookup
ip domain name domain-name
!
username cisco privilege 15 password 0 cisco
!
interface Loopback0
 ip address 172.16.0.3 255.255.255.255
!
interface GigabitEthernet0/1
 ip address 10.100.100.3 255.255.255.0
 no shutdown
!
interface GigabitEthernet0/3
 ip address 192.168.122.103 255.255.255.0
 no shutdown
!
router ospf 1
 network 10.100.100.0 0.0.0.255 area 0
 network 172.16.0.3 0.0.0.0 area 0
!
ip route 0.0.0.0 0.0.0.0 192.168.122.1
ip ssh version 2
!
line con 0
 exec-timeout 0 0
 privilege level 15
 logging synchronous
line vty 0 4
 login local
 transport input ssh
! Generate SSH key
crypto key generate rsa modulus 1024
!
end
```
### RTR4
```
hostname rtr4
!
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
no aaa new-model
no ip domain lookup
ip domain name domain-name
username cisco privilege 15 password 0 cisco
!
interface Loopback0
 ip address 172.16.0.4 255.255.255.255
!
interface GigabitEthernet0/1
 ip address 10.101.101.4 255.255.255.0
 no shutdown
!
interface GigabitEthernet0/3
 ip address 192.168.122.104 255.255.255.0
 no shutdown
!
router ospf 1
 network 10.101.101.0 0.0.0.255 area 0
 network 172.16.0.4 0.0.0.0 area 0
!
ip route 0.0.0.0 0.0.0.0 192.168.122.1
ip ssh version 2
!
line con 0
 exec-timeout 0 0
 privilege level 15
 logging synchronous
line vty 0 4
 login local
 transport input ssh
!
crypto key generate rsa modulus 1024
!
end
```
# Complete

You have completed lab exercise 0.0

---
[Click Here to return to the Ansible Li
nklight - Networking Workshop](../../README.md)

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTk1NjE3ODM3Ml19
-->