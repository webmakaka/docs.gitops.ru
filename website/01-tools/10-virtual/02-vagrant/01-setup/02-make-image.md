---
layout: page
title: Создание образа для vagrant
description: Создание образа для vagrant
keywords: linux, ubuntu, vagrant, make
permalink: /tools/virtual/vagrant/setup/ubuntu/make-image/
---


<br/>

# Создание образа для vagrant


<br/>

Делаю  
2025.08.15

<br/>

```
$ sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

$ sudo usermod -aG libvirt $USER

// Обновить группы без перезагрузки
$ newgrp libvirt  
```

<br/>


```
# Создаем временную директорию
$ mkdir ubuntu-jammy-libvirt
$ cd ubuntu-jammy-libvirt

# Скачиваем cloud-образ Ubuntu
$ wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O box.img
```

<br/>


```
# Создаем ОБЯЗАТЕЛЬНЫЙ metadata.json
$ cat > metadata.json <<EOF
{
  "provider": "libvirt",
  "format": "qcow2",
  "virtual_size": 10
}
EOF
```

<br/>


```
# Возвращаемся в родительскую директорию
$ cd ..

# Упаковываем с сохранением относительных путей
$ tar cvzf ubuntu-jammy-libvirt.box -C ubuntu-jammy-libvirt .
```

<br/>

```
$ vagrant box add ubuntu-jammy-libvirt.box --name ubuntu/jammy64-libvirt
$ vagrant box list | grep jammy64-libvirt
```

<br/>


Далее в vagrant файлах указываем


```
  config.vm.box = "ubuntu/jammy64-libvirt"
```