# Create VMWare Hosts

### Requirements

- VMWare Fusion Player or Pro

### Create Base VM Image for VMWare

Download the latest Ubuntu Server ISO image

### Create VMWare Image

In VMWare Fusion create new image by selecting ISO image option

Spec:
```bash
    name: Ubuntu 64-bit Server 22.04.1 - base image 
    hard disk: 30G
    mem: 4G
    network: Bridged (autodetect)
```

##### Install Ubuntu System

Select Ubuntu Server (minimized) option

##### Credentials
```bash
username: ubuntu
password: ubuntu
```

##### Install Vim Editor

```bash
$ sudo apt-get update
$ sudo apt-get install vim
```

##### Sudo Access

Make entries in `/etc/sudoers` file
```bash
ubuntu  ALL=(ALL) NOPASSWD:ALL
%sudo  ALL=(ALL) NOPASSWD:ALL
```

##### Hosts File

Put following entries to `/etc/hosts` file

```bash
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

### Create Host Images

Copy `base image` (Ubuntu 64-bit Server 22.04.1 - base image) to host image

Make sure that Bridged (Autodetect) network adapter is set and in Advanced options generate new MAC address to prevent network conflicts

Start new host image with VMWare Fusion Player

##### Login
```bash
username: ubuntu
password: ubuntu
```

##### Change hostname
```bash
$ sudo tee /etc/hostname <<EOF
[HOSTNAME]
EOF

$ sudo hostname -b [HOSTNAME]
```

##### Reconfigure OpenSSH Keys

```bash
$ sudo /bin/rm -v /etc/ssh/ssh_host_*
$ sudo dpkg-reconfigure openssh-server
```

##### Get IP Address

```bash
$ ip r
```

### Static IP Address

```bash
$ sudo vi /etc/netplan/00-installer-config.yaml
```
```bash
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
     dhcp4: no
     addresses: [192.168.1.31/24]
     gateway4: 192.168.1.1
     nameservers:
       addresses: [8.8.8.8,8.8.4.2]
```
```bash
$ sudo netplan apply
```
