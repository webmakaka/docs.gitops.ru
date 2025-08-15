---
layout: page
title: Инсталляция VirtualBox 7.X в командной строке в Ubuntu 22.04
description: Инсталляция VirtualBox 7.X в командной строке в Ubuntu 22.04
keywords: server, linux, virtual, virtualbox, setup, ubuntu,command line
permalink: /tools/virtual/virtualbox/setup/ubuntu/
---

# Инсталляция VirtualBox 7.X в командной строке в Ubuntu 22.04


<br/>

Делаю:  
2025.08.15

<br/>

```
$ mkdir ~/tmp
$ cd ~/tmp/
$ wget https://www.virtualbox.org/download/oracle_vbox_2016.asc
$ cat oracle_vbox_2016.asc | gpg --dearmor | sudo tee /usr/share/keyrings/virtualbox.gpg > /dev/null 2>&1
```

<br/>

```
$ echo "deb [arch=amd64 signed-by=/usr/share/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
```

<br/>

```
$ sudo apt update -y
```

<br/>

```
$ apt-cache search virtualbox*
```

<br/>

```
// Последняя 7.2 ее и ставлю
$ sudo apt install -y virtualbox-7.2

// P.S. vagrant, что в оф репах убутны, требует версию 6.1
```

<br/>

```
$ vboxmanage --version
7.2.0r170228
```

<br/>

```
$ CTRL^D
```

<br/>

```
// Добавить пользователя в группу vboxusers
$ sudo usermod -aG vboxusers ${USER}
```

<br/>

```
// В группе vboxusers должен появиться этот пользователь
$ cat /etc/group | grep vboxusers
```

<br/>

### Возможные ошибки при инсталляции

```
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
 virtualbox-6.1 : Depends: libvpx5 (>= 1.6.0) but it is not installable
                  Recommends: libsdl-ttf2.0-0 but it is not going to be installed
E: Unable to correct problems, you have held broken packages.
```

<br/>

Скорее всего, вы (как и я) указали неправильную версию дистрибутива.

В файле /etc/apt/sources.list.d/virtualbox.list

```
Для 22.04 jammy
Для 20.04 focal
Для 18.04 bionic
и т.д.
```

<br/>

### Обновить VirtualBox в Ubuntu

<br/>

```
$ sudo apt-get update
$ sudo apt-cache search virtualbox
$ sudo apt-get install -y virtualbox-7.0
$ vboxmanage --version
```

<br/>

### Установка пакетов расширения (USB, Remote Console, etc)

Делаю:  
03.10.2022

Проприетарная, по идее, требует денег за использование в организациях.

Мне иногда нужна для удаленного доступа, поэтому обычно устанавливаю сразу вместе с virtualbox

<br/>

```
-- если нужно удалить старый
$ VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
```

<br/>

```
$ VBoxManage list extpacks
Extension Packs: 0
```

<br/>

Нужно делать от root. Раньше можно было делать от пользователя.

<br/>

**Ошибка при инсталляции от пользователя:**

<br/>

```
Progress state: NS_ERROR_FAILURE
VBoxManage: error: Failed to install "/tmp/Oracle_VM_VirtualBox_Extension_Pack-6.1.20.vbox-extpack"
VBoxManage: error: The installer failed with exit code 127: Error creating textual authentication agent: Error opening current controlling terminal for the process (`/dev/tty'): No such device or address
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component ExtPackManagerWrap, interface IExtPackManager
VBoxManage: error: Context: "RTEXITCODE handleExtPack(HandlerArg*)" at line 1424 of file VBoxManageMisc.cpp
```

<br/>

```
$ sudo su -
# cd /tmp/
# wget http://download.virtualbox.org/virtualbox/6.1.38/Oracle_VM_VirtualBox_Extension_Pack-6.1.38.vbox-extpack
# VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.38.vbox-extpack
```

<br/>

```
$ VBoxManage list extpacks
Extension Packs: 1
Pack no. 0:   Oracle VM VirtualBox Extension Pack
Version:      6.1.38
Revision:     153438
Edition:
Description:  Oracle Cloud Infrastructure integration, USB 2.0 and USB 3.0 Host Controller, Host Webcam, VirtualBox RDP, PXE ROM, Disk Encryption, NVMe.
VRDE Module:  VBoxVRDP
Usable:       true
Why unusable:
```

<br/>

### Инсталляция Guest Additions в командной строке

Делаю:  
2024.10.05

**Нужно устанавливать в виртуальной машине!**

Я забыл об этом и долго тупил с ошибкой. **modprobe vboxguest failed**

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

**Пример в Ubuntu:**

<br/>

```
$ sudo apt install -y wget gcc make perl p7zip-full bzip2 tar

$ mkdir -p ~/tmp
$ cd ~/tmp

$ wget http://download.virtualbox.org/virtualbox/7.0.24/VBoxGuestAdditions_7.0.24.iso

$ 7z x ./VBoxGuestAdditions_7.0.24.iso -o./VBoxGuestAdditions_7.0.24/

$ cd VBoxGuestAdditions_7.0.24/

$ chmod +x ./VBoxLinuxAdditions.run

$ sudo ./VBoxLinuxAdditions.run

$ sudo reboot


Если черный экран.
Накинуть в настройках VirtualBox видео памяти.
Накидывал 128 MB.

Settings -> Display -> Screen -> 128 MB
```

<br/>

### Дополнительные настройки

<br/>

```
$ vi ~/.bashrc
```

<br/>

Добавляю в конец файла (чтобы читался .bash_profile как в redhat)

<br/>

```
###############################
# READ BASH PROFILE

. ~/.bash_profile
###############################
```

Отредактируйте файл ~/.bash_profile

<br/>

```
$ vi ~/.bash_profile
```

<br/>

Добавьте

```shell
### VirtualBox ################
export VM_HOME=$HOME/machines

###############################
```

<br/>

```
// Применить новые параметры:
$ source ~/.bash_profile
```

<br/>

```
$ echo ${VM_HOME}
$ mkdir -p ${VM_HOME}
```

<!--

<br/>

### Работа с Plugin в Vagrant

    $ vagrant plugin list
    $ vagrant plugin update


<br/>

Словил ошибку:

**modprobe vboxguest failed**

 # apt-get install -y virtualbox-dkms
    # apt-get install -y virtualbox-guest-dkms
    # apt-get install -y linux-headers-virtual

Не помогло.

    # /sbin/rcvboxadd quicksetup all

 -->

<!-- <br/>




Еще возможные варианты:

    # modprobe vboxdrv
    # modprobe vboxvideo
    # modprobe vboxsf


    # ./VBoxLinuxAdditions.run -->

<!--


На клиенте, после инсталляции guest additions можно выполнить команды:

    $ VBoxClient

    Options:

      --clipboard            start the shared clipboard service
      --draganddrop          start the drag and drop service
      --display              start the display management service
      --checkhostversion start the host version notifier service
      --seamless             start the seamless windows service
      -d, --nodaemon         continue running as a system service

Буфер обмена постоянно перестает работать.

К сожалению, мне пока не удалось найти решения, которое позволило бы полностью побороть данную проблему.

Как вариант,

// Найти процесс clipboard

    $ ps -Af | grep VBoxClient

// кильнуть его по -9

    $ kill -9

// Стартовать его заново

    $ VBoxClient --clipboard

Или попробовать использовать команды:

    $ killall VBoxClient

    $ VBoxClient-all

Если гостевая машина windows, можно попробовать убить процесс VBoxTray.exe

// Investigating shared clipboard problems on X11 guests or hosts

https://www.virtualbox.org/wiki/X11Clipboard


-->
