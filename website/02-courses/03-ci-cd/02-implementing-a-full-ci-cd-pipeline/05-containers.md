---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Контейнеры
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Контейнеры
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD, Контейнеры
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/tools/containers/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 06. Контейнеры

<br/>

Устанавливаю <a href="/tools/containers/docker/setup/ubuntu/">Docker</a> на хосте, на котором уже уснановлен Jenkis и на хост, где будет запускаться приложение.

<br/>

### 26. Установка Docker в Jenkins

<br/>

**На хосте, где установлен jenkns**

<br/>

Устанавливаю Jenkins плагин: Docker Pipeline

<br/>

    $ sudo apt-get install -y sshpass

<br/>

    $ sudo usermod -aG docker jenkins
    $ sudo systemctl restart jenkins
    $ sudo systemctl restart docker

<br/>

**На сервере добавил:**

    # sudo usermod -aG docker deploy

<br/>

### 27. Непрерывная доставка с Jenkins Pipelines и докеризованное приложение

<br/>

**Jenkins**

Manage Jenkins -> Configure System

Global properties

> Environment variables

<br/>

```
Name: prod_ip
Value: 192.168.0.12
```

<br/>

**Jenkins**

Manage Jenkins -> Credentials

- webserver_login (был создан ранее)
- docker_hub_login

<br/>

**Импортирую:**

https://github.com/linuxacademy/cicd-pipeline-train-schedule-dockerdeploy

<br/>

Финальная версия Jenkinsfile из демонстрации в ветке example-solution данного проекта:

https://github.com/linuxacademy/cicd-pipeline-train-schedule-dockerdeploy/blob/example-solution/Jenkinsfile

Нужно заменить:

willbla на свой docker login.

Запускать:

http://192.168.0.12:8080/

<br/>

Отработало.  
Приложение запустилось!
