---
layout: page
title: Инсталляция CoreOS в virtualBox
permalink: /devops/containers/coreos/install/virtualbox-coreos/
---

# Подготовка виртуального жесткого диска virtualbox с coreos

Создаю каталог, где будет все это добро храниться.

    $ mkdir -p /mnt/dsk0/machines/coreos/

    $ cd /mnt/dsk0/machines/coreos/

Следующий скрипт поможет нам скачать последнюю стабильную версию coreos

    $ wget $ https://raw.github.com/coreos/scripts/master/contrib/create-coreos-vdi

    $ chmod +x create-coreos-vdi

    $ ./create-coreos-vdi -V stable -d .

Лучше сразу расширить место на диске, чтобы можно было побольше всяких имиджей накачать. По умолчанию диск на 698M.

    $ VBoxManage modifyhd coreos_production_835.9.0.vdi --resize 20480

Далее, если стартовать, операционная система попросит пароль.

Но здесь все несколько хитрее.

Можно сделать подключение по SSH, но нужно как-то скопировать ключ с хостовой машины на гостевую. Для этого придется подготвить дополнительно диск с конфигом.

<br/>

### Создаем Config-Drive

Для начала, нужно сгенерировать rsa ключ на хосте (если он не был создан ранее).

    $ ssh-keygen -t rsa

На все вопросы [Enter]

    $ wget https://raw.github.com/coreos/scripts/master/contrib/create-basic-configdrive

Далее я добавляю настройки для сети. Имеет смысл, если нет DHCP сервера, который выдаст виртуальной машине какой-нибудь IP адрес. Если такой сервер есть, то можно и не далать этого. Или даже лучше не делать.

Главное правильно задать в конфиге имя сетевого адаптера enp0s3.

    $ vi create-basic-configdrive

После:

    - name: fleet.service
        command: start

Добавляю:

    - name: 00-eth0.network
      runtime: true
      content: |
        [Match]
        Name=enp0s3

        [Network]
        DNS=192.168.1.1
        Address=192.168.1.11/24
        Gateway=192.168.1.1

<br/>

    $ chmod +x create-basic-configdrive

<br/>

    $ ./create-basic-configdrive -H my_vm01 -S ~/.ssh/id_rsa.pub
    Success! The config-drive image was created on /mnt/dsk0/my_vm01.iso

<br/>

### Запускаем виртуальную машину VirtualBox с CoreOS

Vdi диск подключаю как жесткий диск. ISO как CD-ROM.

Добавляю 1 сетевой адаптер типа Bridge и сообщаю, что он должен работать с локальным eh0.

Запускаю виртуальную машину.

Далее появилось приглашение ввести логин/пароль.

Остается с хостовой машины подключиться по SSH к гостевой.

**Внимание!!! Чтобы узнать по какому IP подключаться. Нужно в окне приглашения (где нужно ввести login) несколько раз нажать на [Enter]. Появится окно, в котором будет написано, к какому IP подлючаться**

    $ ssh core@192.168.1.11
    Last login: Sat Jan 16 12:12:40 2016 from 192.168.1.5
    CoreOS stable (835.9.0)

Docker уже установлен.
Мне пока больше ничего и не нужно.

    $ docker -v
    Docker version 1.8.3, build cedd534-dirty


