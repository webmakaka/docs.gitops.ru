---
layout: page
title: Пример запуска прилоения в Docker одной командой
description: Отправить docker image на hub.docker.com
keywords: devops, docker, Пример запуска прилоения в Docker одной командой
permalink: /devops/containers/docker/run/
---

# Пример запуска прилоения в Docker одной командой

<br/>

### Запустить приложение с котиками одной командой

**Само приложение:**

https://github.com/webmakaka/voting-game

<br/>

**Команда для запуска:**

Docker должен быть установлен!!!

    $ docker run -it \
    -p 80:8080 \
    --name nodejs-voting-game \
    marley/nodejs-voting-game

<br/>

http://localhost
