---
layout: page
title: Создание сервера GIT в centos 6 ver2
description: Создание сервера GIT в centos 6 ver2
keywords: Создание сервера GIT в centos 6 ver2
permalink: /tools/git/git-server/centos/6/ver2/
---

# Создание сервера GIT в centos 6

Делаю на 1 виртуальной машите. Исключительно для теста.

### Server

    # yum install -y git

<br/>

    # groupadd developers

<br/>

    # useradd \
    -g developers \
    -d /home/dev1 \
    -m dev1

<br/>

    # useradd \
    -g developers \
    -d /home/dev2 \
    -m dev2

<br/>

    # passwd dev1
    # passwd dev2

<br/>

    # mkdir -p /exports/projects/git
    # cd /exports/projects/

    # chgrp -R developers .
    # chmod -R g+rwX .

    # su - dev1
    $ cd /exports/projects/git

    $ git init --bare --shared my-project.git

<br/>

### Local PC User Dev2:

    $ su - dev1

<br/>

    $ ssh-keygen
    Generating public/private rsa key pair.
    Enter file in which to save the key (/root/.ssh/id_rsa):
    Created directory '/root/.ssh'.
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /root/.ssh/id_rsa.
    Your public key has been saved in /root/.ssh/id_rsa.pub.
    The key fingerprint is:
    c6:53:09:f2:6a:48:89:ab:e3:9c:4d:40:2d:26:c1:b8 root@gitserv.localdomain
    The key's randomart image is:
    +--[ RSA 2048]----+
    |+     . .        |
    |.o.. . o . .     |
    |.=..o   . o      |
    |E .o . o .       |
    | .. . o S        |
    | ..  . . .       |
    |o  .             |
    |o.+              |
    | + .             |
    +-----------------+

<br/>

    $ ls ~/.ssh
    id_rsa  id_rsa.pub

<br/>

    $ chmod 700 ~/.ssh

<br/>

    $ cd .ssh/
    $ cat id_rsa.pub >>authorized_keys

<br/>

    $ scp authorized_keys 192.168.56.2:/home/dev2/.ssh

<br/>

    # su - dev2
    $ mkdir projects
    $ cd projects

<br/>

    $ git config --global user.name "dev2"
    $ git config --global user.email dev2@example.com

<br/>

    $ git init my-project.git
    $ cd my-project.git/
    $ git remote add origin dev2@192.168.56.2:/exports/projects/git/my-project.git

Если понадобится удалить:

    $ git remote rm origin

<br/>

    $ touch myFile.txt
    $ git add --all
    $ git commit -m "file myFile.txt added"

<br/>

    $ git push origin master

<br/>

### Local PC User Dev1:

    # su - dev1
    $ mkdir projects
    $ cd projects

<br/>

    $ git config --global user.name "dev1"
    $ git config --global user.email dev1@example.com

<br/>

    $ git clone dev1@192.168.56.2:/exports/projects/git/my-project.git

<br/>

    $ echo "Edited By Dev1" >> myFile.txt

<br/>

    $ git add --all
    $ git commit -m "file updated by dev1"

    $ git push origin master
