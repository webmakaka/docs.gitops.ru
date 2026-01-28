---
layout: page
title: Logging in Kubernetes with EFK Stack | Подготавливаем образы и выкладываем на hub.docker.com
description: Logging in Kubernetes with EFK Stack | Подготавливаем образы и выкладываем на hub.docker.com
keywords: courses, containers, kubernetes, tools, logging, elastic, fluentd, kibana, Подготавливаем образы и выкладываем на hub.docker.com
permalink: /courses/containers/kubernetes/tools/logging/efk/logging-in-kubernetes-with-efk-stack/build-and-push-docker-images/
---

# [Nana Janashia] Logging in Kubernetes with EFK Stack : Подготавливаем образы и выкладываем на hub.docker.com

<br/>

Делаю:  
2024.03.28

<br/>

### Ссылки

**node app:**  
https://gitlab.com/nanuchi/node-app

<br/>

**java app**
https://gitlab.com/nanuchi/java-app

<br/>

```
$ export DOCKER_HUB_LOGIN=webmakaka
```

<br/>

```
$ docker login ${DOCKER_HUB_LOGIN}
```

<br/>

**node-app публичное репо**

```
$ cd ~/tmp
$ git clone https://gitlab.com/nanuchi/node-app.git
$ cd node-app
$ docker build -t node-app .
$ docker tag node-app ${DOCKER_HUB_LOGIN}/node-1.0:latest
$ docker push ${DOCKER_HUB_LOGIN}/node-1.0
```

<br/>

**java-app приватное репо**

<br/>

Создаю в hub.docker.com приватное репо: webmakaka/java-1.0

<br/>

```
$ cd ~/tmp
$ git clone https://gitlab.com/nanuchi/java-app.git
$ cd java-app
```

<br/>

```
$ vi Dockerfile
```

<br/>

```
### Step 1

FROM gradle:4.10.0-jdk8-alpine AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon

### Step 2

FROM openjdk:8-jre-alpine

EXPOSE 8080

COPY --from=build /home/gradle/src/build/libs/*.jar /usr/app/
WORKDIR /usr/app

ENTRYPOINT ["java", "-jar", "java-app-1.0-SNAPSHOT.jar"]
```

<br/>

```
$ docker build -t java-app .
$ docker tag java-app ${DOCKER_HUB_LOGIN}/java-1.0:latest
$ docker push ${DOCKER_HUB_LOGIN}/java-1.0
```
