---
layout: page
title: Скопировать Docker Images на другой Host
description: Скопировать Docker Images на другой Host
keywords: devops, containers, docker, copy images, move outside
permalink: /devops/containers/docker/basics/copying-images-to-other-hosts/
---

# Скопировать Docker Images на другой Host

Делаю:  
26.04.2021

<br/>

```
$ docker -v
Docker version 20.10.6, build 370c289
```

<br/>

### Host 1:

Если нужно перенести контейнер делаем commit, чтобы получить image

    $ docker commit <container_id> <new_image_name>

Сохраняем image в файл.

    $ docker save -o /tmp/<new_image_name>.tar <new_image_name>

Проверяем, создался ли файл

    $ ls -lh /tmp/<new_image_name>.tar

<br/>

### Host 2:

<!--
    // Посмотреть всяку ерунду в контейнере
    $ tar -tf /tmp/<new_image_name>.tar
-->

    $ docker load -i /tmp/<new_image_name>.tar

    $ docker images | grep <new_image_name>

<br/>

### Как переносить базу в контейнере

Для переноса базы данный вариант не работает. В результате переноса базы mysql, оказалось, что она пустая.

Нужно будет поизучать:

https://question-it.com/questions/184237/sohranit-tekuschee-sostojanie-obraza-dokera-i-eksportirovat-na-drugoj-server

когда в следующий раз понадобится.
