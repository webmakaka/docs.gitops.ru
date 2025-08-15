---
layout: page
title: Ubuntu Linux Containers (lxd)
description: Ubuntu Linux Containers (lxd)
keywords: DevOps, Ubuntu Linux Containers (lxd)
permalink: /devops/containers/lxd/ubuntu/
---

# Ubuntu: Linux Containers (lxd)

<br/>

Делаю!  
2025.08.15

<br/>

### Инсталляция LXD / LXC

```
$ sudo apt update && sudo apt upgrade -y
$ sudo snap install lxd
$ sudo systemctl enable snap.lxd.daemon && systemctl start snap.lxd.daemon

$ systemctl status snap.lxd.daemon

$ gpasswd -a marley lxd
Adding user marley to group lxd

$ getent group lxd
lxd:x:132:marley

$ logout
```

<br/>

```
$ lxc version
If this is your first time running LXD on this machine, you should also run: lxd init
To start your first container, try: lxc launch ubuntu:24.04
Or for a virtual machine: lxc launch ubuntu:24.04 --vm

Client version: 5.21.3 LTS
Server version: 5.21.3 LTS
```

<br/>

### Конфигурирование LXD

```
// По умолчанию везде, кроме storage backend
$ lxd init
Would you like to use LXD clustering? (yes/no) [default=no]:
Do you want to configure a new storage pool? (yes/no) [default=yes]:
Name of the new storage pool [default=default]:
```

<br/>

```
Name of the storage backend to use (btrfs, dir, lvm) [default=btrfs]: [dir]
```

<br/>

```
Would you like to connect to a MAAS server? (yes/no) [default=no]:
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=lxdbr0]:
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
Would you like LXD to be available over the network? (yes/no) [default=no]:
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```


<br/>

### Jenkins

```
$ lxc launch ubuntu:24.04 jenkins-lxc
```







<br/>

### Запуск экспортированной виртуальной машины

```
$ lxc image list
```

```
$ lxc image import /mnt/dsk1/images/image_location --alias myimage
```

```
$ lxc image list
```

```
$ lxc launch c6b2a0647584 myimage
```

```
$ lxc list
```

```
$ ssh <IP>

$ cat /etc/os-release
```

<br/>

### Некоторые команды для работы с lxc

<br/>

```
$ lxc info | grep driver_version
  driver_version: 4.0.12 | 6.1.1
```

<br/>

```
$ lxc list

$ lxc stop myimage
$ lxc start myimage

$ lxc delete myimage --force

lxc storage list

lxc remote list

lxc image list

lxc image list images:
lxc image list images:centos

lxc launch ubuntu:16:04 myubuntu


lxc exec myubuntu bash

lxc delete myubuntu --force

lxc info myubuntu
lxc config show myubuntu

lxc profile list

lxc profile copy default custom
lxc launch ubuntu:16:04 myubuntu --profile custom
```

<br/>

```
lxc exec myvm bash

lxc profile show default

lxc config set myubuntu limits.memory 512MB
lxc config set myubuntu limits.cpu 2

lxc profile edit custom

lxc launch ubuntu:16.04 myubuntu --profile custom
```

<br/>

```
echo "hello there" > myfile
lxc file push myfile myubuntu/root/

lxc file pull first/etc/hosts .
```

<!-- <br/>

```
// Error: Image with same fingerprint already exists
``` -->

<br/>

**Getting started with LXC containers**  
https://www.youtube.com/watch?v=CWmkSj_B-wo

<br/>

### [Ubuntu: Linux Containers (lxc) (Наверное устарело по большей части)](/devops/containers/lxd/ubuntu/archive/)
