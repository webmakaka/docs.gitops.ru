---
layout: page
title: Инсталляция GitLab в centos 6 из пакетов
description: Инсталляция GitLab в centos 6 из пакетов
keywords: devops, gitops, cvs, gitlab, setup, centos
permalink: /tools/git/gitlab/setup/centos/6/
---

# Инсталляция GitLab в centos 6 из пакетов

Потом зашел на сайт официальной документации: http://doc.gitlab.com/ce/install/installation.html и о чудо нашел такое предложение: " If you want to install on RHEL/CentOS we recommend using the Omnibus packages."

И попал на эту страницу: https://about.gitlab.com/downloads/ выбрал тут CentOS 6.

И легко в несколько команд поставил GitLab сервер:

 <br/>

    # yum install postfix

 <br/>

    # wget https://downloads-packages.s3.amazonaws.com/centos-6.5/gitlab-7.0.0_omnibus-1.el6.x86_64.rpm
    # rpm -i gitlab-7.0.0_omnibus-1.el6.x86_64.rpm

<br/>

    # vi /etc/gitlab/gitlab.rb

<br/>

Тут я указал свой домен: external_url 'http://192.168.56.2'

И запустил реконфиг:

    # gitlab-ctl reconfigure

Данный пакет представляет из себя сценарий Chef'a, который все ставит и настраивает в автоматическом режиме.

После чего я сразу смог попасть в работающий GitLab по адресу: http://asidorov.name/

Первоначальные реквизиты доступа:

Пользователь: root  
Пароль: 5iveL!fe

После чего вам предложат сразу задать пароль для root'a. После изменения данного пароля вы сможете авторизироваться в системе GitLab.

Проблема в таком решении, что ты не выбираешь например какую базу использовать, как будет общаться nginx и unicorn (Unix сокеты или TCP порты).

Оно ставит и настраивает автоматически: nginx, postgresql, redis, unicorn, sidekiq.
Очень удобно и просто. Спасибо огромное разработчикам за такую простоту.

<br/>

**По материалам сайта:**  
http://blog.asidorov.name/2014/07/gitlab.html
