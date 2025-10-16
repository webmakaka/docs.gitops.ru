---
layout: page
title: Инсталляция CoreOS на хостовую машину
permalink: /devops/containers/coreos/install/on-host-machine/
---

# Инсталляция CoreOS на хостовую машину

На хосте стартовал ubuntu с USB флешки в режиме для ознакомления.

На рабочей станции, с которой планирую подключаться к серверу сгенерировал публичный ключ. Его потом нужно прописать в конфиге.

    $ ssh-keygen -t rsa

На все вопросы [Enter]

Че там сгенерировалось:

    $ cat ~/.ssh/id_rsa.pub

<br/>

### На Ubuntu

    $ sudo su -
    # cd /tmp

Товарищи из CoreOS подготовили следующий скрипт для инсталляции.

    # wget https://raw.githubusercontent.com/coreos/init/master/bin/coreos-install
    # chmod +x coreos-install

<br/>

### Подготавливю минимальный конфиг

https://bitbucket.org/sysadm-ru/coreos-cloud-config/src/master/cloud-config.yaml

<br/>

С названием сетевых интерфейсов пока не разобрался как они задаются. Поэтому несколько раз переделывал все шаги, пока не нашел подходящий. Если покопаться в интернете, то можно найти совершенно разные варианты задания имен сетевых интерфейсов. В компьютере установлено 2, почему enp4s1, пока хз.

Думаю, что можно узнать mac адрес сетевой карты и прописать что-то похожее на следующее:

    [Match]
    MACAddress=12:34:56:78:9a:bc

    [Link]
    Name=eth0

    [Network]
    Address=192.168.1.220/24
    Gateway=192.168.1.1
    DNS=192.168.1.1

Нужно попробовать, когда будет возможность!

Тем у кого настроен DHCP, имеет смысл выпилить блок с явным указанием настроек сети.

<br/>

### Проверяю его валидность

https://coreos.com/validate/

<br/>

### Поехали ставить уже

// Понадобился следующий пакет

    # apt-get install -y gawk

// Скачиваю конфиг приведенный выше. Разумеется, в него нужно подставить свой rsa ключ.

    # wget https://bitbucket.org/sysadm-ru/coreos-cloud-config/raw/304e0cfe50b8492e7d827ed93527ed326f582959/cloud-config.yaml

// Запускаю инсталляцию

    # ./coreos-install -d /dev/sda -C stable -c ./cloud-config.yaml

// Установка успешно завершается.

    Installing cloud-config...
    Success! CoreOS stable 1298.5.0 is installed on /dev/sda

<br/>

### Подключаюсь по SSH к хосту с CoreOS

    $ ssh core@192.168.1.220
    CoreOS stable (835.11.0)
    core@localhost ~ $

<br/>

    $ docker -v
    Docker version 1.12.6, build d5236f0

<br/>

    $ git --version
    git version 2.7.3

<br/>
<br/>

### Возможно, полезная информация

Сloud config можно отредактировать после установки, внеся правки в файл.

    # vi /var/lib/coreos-install/user_data

<br/>

### Линки на почитать

https://deis.com/blog/2015/coreos-on-virtualbox  
https://coreos.com/os/docs/latest/installing-to-disk.html  
https://coreos.com/os/docs/latest/booting-with-iso.html  
http://www.youtube.com/watch?v=yiWa0KFJDfI

http://www.liberidu.com/blog/2015/04/11/basic-newbie-install-coreos-on-virtualbox-getting-started-with-docker/
