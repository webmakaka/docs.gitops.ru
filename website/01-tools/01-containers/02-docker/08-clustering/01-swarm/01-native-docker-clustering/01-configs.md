---
layout: page
title: Docker Swarm > Native Docker Clustering > Configs
description: Docker Swarm > Native Docker Clustering > Configs
keywords: devops, containers, docker, clustering, swarm, native docker configs
permalink: /devops/containers/docker/clustering/swarm/native-docker-clustering/configs/
---

# Docker Swarm > Native Docker Clustering [2016, ENG] > Configs

<br/>

**Dockerfile (gliderlabs/registrator)**

https://github.com/gliderlabs/registrator

<br/>

**Dockerfile (progrium/busybox)**

https://github.com/progrium/busybox

<br/>

**Dockerfile (progrium/consul)**

Возможно, тоже обновленный вариант:  
https://github.com/gliderlabs/docker-consul

Походу вот такой dockerfile используется, но у меня он не собрался.

    FROM 		progrium/busybox
    MAINTAINER 	Jeff Lindsay <progrium@gmail.com>

    ADD https://dl.bintray.com/mitchellh/consul/0.4.0_linux_amd64.zip /tmp/consul.zip
    RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul && rm /tmp/consul.zip

    ADD https://dl.bintray.com/mitchellh/consul/0.4.0_web_ui.zip /tmp/webui.zip
    RUN cd /tmp && unzip /tmp/webui.zip && mv dist /ui && rm /tmp/webui.zip

    ADD https://get.docker.io/builds/Linux/x86_64/docker-1.2.0 /bin/docker
    RUN chmod +x /bin/docker

    RUN opkg-install curl bash

    ADD ./config /config/
    ONBUILD ADD ./config /config/

    ADD ./start /bin/start
    ADD ./check-http /bin/check-http
    ADD ./check-cmd /bin/check-cmd

    EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53/udp
    VOLUME ["/data"]

    ENV SHELL /bin/bash

    ENTRYPOINT ["/bin/start"]
    CMD []

<br/>

**Можно заменить:**

    https://releases.hashicorp.com/consul/0.7.3/consul_0.7.3_linux_amd64.zip

    https://releases.hashicorp.com/consul/0.7.3/consul_0.7.3_web_ui.zip

    RUN cd /tmp && mkdir dist && unzip /tmp/webui.zip -d dist && mv dist /ui && rm /tmp/webui.zip

    https://get.docker.com/builds/Linux/x86_64/docker-1.10.3

    Но вот, что за config, start, check-http, heck-cmd можно посмотреть внутри контейнера progrium/consul.
