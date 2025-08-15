---
layout: page
title: Создание сервера GIT в centos 6 ver1
description: Создание сервера GIT в centos 6 ver1
keywords: Создание сервера GIT в centos 6 ver1
permalink: /tools/git/git-server/centos/6/ver1/
---

# Создание сервера GIT в centos 6

<br/>

### Server

    # yum install -y git

<br/>

    # groupadd developers

<br/>

    # useradd \
    -g developers \
    -d /home/git \
    -m git

<br/>

    # passwd git

<br/>

    # su - git
    $ mkdir projects
    $ cd projects/

<br/>

    $ git init --bare --shared my-project.git

Удалённый репозиторий — это обычно голый (чистый, bare) репозиторий — Git-репозиторий, не имеющий рабочего каталога. Поскольку этот репозиторий используется только для обмена, нет причин создавать рабочую копию на диске, и он содержит только данные Git'а. Проще говоря, голый репозиторий содержит только каталог .git вашего проекта и ничего больше.

<br/>

### На клиенте c Windows запускаю Git Bash:

    $ git config --global user.name "dev"
    $ git config --global user.email dev@example.com

<br/>

    $ mkdir projects
    $ cd projects
    $ git clone https://github.com/marley-html/minimal-design
    $ cd minimal-design
    $ rm -rf .git
    $ git init
    $ git add --all
    $ git commit -m "initial commit"

<br/>

    $ git remote add origin git@192.168.56.2:projects/my-project.git

Если понадобится удалить remote origin:

    $ git remote rm origin

<br/>

    $ git push origin master

<br/>

### На каком-либо другом компьютере в сети:

    $ git clone git@192.168.56.2:projects/my-project.git
