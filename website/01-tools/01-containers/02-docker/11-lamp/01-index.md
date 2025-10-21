---
layout: page
title: Docker Lamp Server
description: Docker Lamp Server
keywords: devops, docker, Docker Lamp Server
permalink: /devops/containers/docker/lamp/
---

# Docker Lamp Server

<div align="center">

    <iframe width="853" height="480" src="https://www.youtube.com/embed/zcCEA0aG3aU" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

</div>

**Делаю 19.01.2019**

    $ cd ~
    $ mkdir linuxcommunity.ru
    $ cd linuxcommunity.ru

    $ git clone https://github.com/tkyk/docker-compose-lamp.git .


    -- Наверное имеет смысл заменить в файле Dockerfile timezone

        $ vi Dockerfile

        date.timezone = Europe/Moscow

<br/>

    $ vi docker-compose.yml

    Указать нужные port:

      ports:
    - "5001:80"

    Указать нужные пароли:

    MYSQL_ROOT_PASSWORD: phpapptest
    MYSQL_DATABASE: phpapp

<br/>

Впринципе, можно запустить и попробовать. Может вам не нужно устанавливать форум.

<br/>

## Устанавливаю форум punbb

<br/>

### Скачиваю punbb

https://punbb.info/

Копирую все скрипты из архива в каталог webroot. Также добавляю русский язык.

    $ chmod 0777 ./webroot/img/avatars/
    $ chmod 0777 ./webroot/cache/

<br/>

### Добавляю phpmyadmin

Копирую phpmyadmin в webroot. Разумеется переименовываю каталог на phpmyadmin.

    # cd ./phpmyadmin/
    $ cp config.sample.inc.php config.inc.php
    # chmod 644 -R config.inc.php

    -- Прописать в качестве хоста db
    $ vi config.inc.php

    $cfg['Servers'][$i]['host'] = 'db';

<br/>

### Запуск

    $ docker-compose build
    $ docker-compose up -d

    -- если потом нужно будет остановить
    $ docker-compose stop

    -- или даже удалить
    $ docker-compose rm

<br/>

Я сразу привязал домен и настроил его на хост. В ином случае, требуется подключаться к хосту по ip или dns имени.

<br/>

![lamp server inside docker](/img/devops/containers/docker/lamp/docker-lamp-1.png 'lamp server inside docker'){: .center-image }

<br/>

![lamp server inside docker](/img/devops/containers/docker/lamp/docker-lamp-2.png 'lamp server inside docker'){: .center-image }

<br/>

### Улучшения

linuxcommunity.ru/webroot/style/Oxygen/oxygen.min.css

```css
.brd {
    padding: 1em 2em;
    margin: 0 auto;
    max-width: 1100px;
    min-width: 700px;
    width: 90%;
}
```

Меняю max-width

```css
.brd {
    padding: 1em 2em;
    margin: 0 auto;
    max-width: 2460px;
    min-width: 700px;
    width: 96%;
}
```

<br/>

### Борьба со спамом

Копирую fancy_stop_spam в каталог linuxcommunity.ru/webroot/extensions

Administratoin --> Extensins --> Install
