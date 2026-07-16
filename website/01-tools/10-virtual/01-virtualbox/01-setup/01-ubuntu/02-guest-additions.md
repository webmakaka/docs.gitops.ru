---
layout: page
title: Инсталляция Guest Additions в командной строке Ubuntu 22.04
description: Инсталляция Guest Additions в командной строке Ubuntu 22.04
keywords: server, linux, virtual, virtualbox, setup, ubuntu,command line
permalink: /tools/virtual/virtualbox/setup/ubuntu/guest-additions/
---

# Инсталляция Guest Additions в командной строке Ubuntu 22.04

**Делаю:**  
2026.07.16

<br/>

**Нужно устанавливать в виртуальной машине!**

Я забыл об этом и долго тупил с ошибкой. **modprobe vboxguest failed**

<br/>

Если черный экран.
Накинуть в настройках VirtualBox видео памяти.
Накидывал 128 MB.

Settings -> Display -> Screen -> 128 MB

<br/>

```
# modprobe vboxguest
modprobe: ERROR: could not insert 'vboxguest': No such device
```

<br/>

Обычно виртуалки использую без GUI.

Пакет Guest Additions как минимум нужен для того, чтобы мышка по экрану нормально перемещалась, работала copy+paste и может быть что-то еще. Нужно ли устанавливать guest additions, если предстоит работать только в командной строке, наверное нет.

Installation guide

http://www.virtualbox.org/manual/ch04.html#idp11277648

<br/>

```
// На хосте смотрю версию
$ vboxmanage --version
7.0.26r168464
```

<br/>

**Пример в Ubuntu:**

<br/>

```
$ sudo apt-get install -y wget
$ sudo apt-get install -y gcc make perl
$ sudo apt-get install -y p7zip-full bzip2 tar

$ mkdir -p ~/tmp
$ cd ~/tmp

$ wget http://download.virtualbox.org/virtualbox/7.0.26/VBoxGuestAdditions_7.0.26.iso

$ 7z x ./VBoxGuestAdditions_7.0.26.iso -o./VBoxGuestAdditions_7.0.26/

$ cd VBoxGuestAdditions_7.0.26/

$ chmod +x ./VBoxLinuxAdditions.run

$ sudo ./VBoxLinuxAdditions.run

$ sudo reboot
```
