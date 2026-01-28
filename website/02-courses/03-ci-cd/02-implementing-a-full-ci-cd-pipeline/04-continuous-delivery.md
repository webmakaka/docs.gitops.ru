---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Непрерывная доставка
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Непрерывная доставка
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD, Непрерывная доставка
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/continuous-delivery/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 05. Непрерывная доставка

<br/>

### Этапы (stages) и шаги (steps)

<br/>

**Пример:**

https://github.com/linuxacademy/cicd-pipeline-train-schedule-pipelines/blob/example-solution/Jenkinsfile

<br/>

## Подготовка окружения для тестов

<br/>

Стартую Vagrant с 2 виртуалками <a href="https://github.com/webmakaka/cats-app-ansible/">как здесь</a>.

<br/>

Создаю пользователя "deploy". И убеждаюсь, что могу подключиться по SSH данным пользователем с хоста, где установлен Jenkins.

<br/>

### Controller и Node

**Создаю пользователя "deploy"**

<br/>

    $ sudo su  -
    # adduser --disabled-password --gecos "" deploy
    # usermod -aG sudo deploy
    # passwd deploy

<br/>

    # sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    # service sshd reload

<br/>

**Не спрашивать sudo пароль:**

<br/>

    # vi /etc/sudoers

<br/>

    %sudo   ALL=(ALL:ALL) ALL

<br/>

меняю на:

<br/>

```shell
#%sudo   ALL=(ALL:ALL) ALL
%sudo   ALL=(ALL:ALL) NOPASSWD:ALL
```

<br/>

Убеждаюсь, что могу подключиться по SSH

<br/>

    $ ssh deploy@192.168.0.11
    $ ssh deploy@192.168.0.12

<br/>

**Запускаю приложение на серверах**

<br/>

```
$ sudo mkdir -p /opt/train-schedule/
$ cd /opt/train-schedule/
$ sudo git clone https://github.com/linuxacademy/cicd-pipeline-train-schedule-cd .
```

<br/>

**Устанавливаю Node**

<br/>

```
$ sudo apt install -y nodejs npm
$ sudo apt install -y unzip
```

<br/>

```
$ cd /opt/train-schedule/
$ sudo npm install
$ sudo npm start
```

<br/>

Попробовали, что запускается

http://192.168.0.11:3000/

http://192.168.0.12:3000/

<br/>

**OK**

<br/>

### Создаем сервис systemctl

<br/>

    $ sudo vi /etc/systemd/system/train-schedule.service

<br/>

```
[Unit]
Description=nodejs-app
After=network.target

[Service]
Environment=NODE_PORT=3000
Type=simple
User=ubuntu
WorkingDirectory=/opt/train-schedule
ExecStart=/usr/bin/nodejs bin/www
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

<br/>

```
$ sudo systemctl enable train-schedule.service
$ sudo systemctl start train-schedule.service
$ sudo systemctl status train-schedule.service
```

<br/>

```
// Выгрузить если что-то пошло не так
// # systemctl stop train-schedule.service
// # systemctl disable train-schedule.service
```

<br/>

http://192.168.0.11:3000/

OK

<br/>

```
$ sudo chown -R deploy /opt/train-schedule/
```

<!--

<br/>

**Нужно, чтобы отрабатывал команда:**

<br/>

```
$ sudo /usr/bin/systemctl stop train-schedule && rm -rf /opt/train-schedule/* && unzip /tmp/trainSchedule.zip -d /opt/train-schedule && sudo /usr/bin/systemctl start train-schedule
```

-->

<br/>

## Развертывание с Jenkins Pipelines

https://stackoverflow.com/questions/61105368/how-to-use-github-personal-access-token-in-jenkins/61105369#61105369

<br/>

### 20. Развертывание с Jenkins Pipelines - Часть 1

**Jenkins**

Manage Jenkins -> Manage Plugins -> Available

- Publish Over SSH

<br/>

**Jenkins**

Manage Jenkins -> Configure System

Publish over SSH

SSH Servers -> Add

<br/>

**Server1**

```
Name: staging
Nostname: 192.168.0.11

Username:
Remote Directory: /
```

<br/>

**Server2**

```
Name: production
Nostname: 192.168.0.12

Username:
Remote Directory: /
```

<br/>

**SAVE**

<br/>

### Подготовка проекта на GitHub

**Fork:**

https://github.com/linuxacademy/cicd-pipeline-train-schedule-cd

В

https://github.com/wildmakaka/cicd-pipeline-train-schedule-cd

Удалить все бранчи кроме мастер.

<br/>

### Setup Jenkins

Jenkins -> Manage Jenkins -> Manage Credentials

Stores scoped to Jenkins -> Jenkins

Global credentials (unrestricted) -> Add Credentials

<br/>

```
Username: deploy
Password: deploy
ID: webserver_login
Description: Webserver Login
```

<br/>

**OK**

<br/>

### Создание нового задания

<br/>

Jenkins -> New Item

```
Name: train-schedule
Type: Multibranch Pipeline
```

<br/>

Branch Sources -> Github -> Credentials -> Add Jenkins

Kind: Username with password

<br/>

```
Username: <Github-User-Name>
Password: <Github-API-Key>
ID: github_api_key_2
Description: GitHub API Key 2
```

<br/>

**Add**

<br/>

Credentials: GitHub API Key 2

Repostitory HTTPS URL: https://github.com/wildmakaka/cicd-pipeline-train-schedule-cd

<br/>

**Validate**

<br/>

**Save**

<br/>

На этом шаге только сборка. Нет доставки.

<br/>

### 20. Развертывание с Jenkins Pipelines - Часть 2

<br/>

Заменить содержимое Jenkinsfile на

https://github.com/linuxacademy/cicd-pipeline-train-schedule-cd/blob/example-solution/Jenkinsfile

<br/>

**Меняю текст**

https://github.com/wildmakaka/cicd-pipeline-train-schedule-cd/blob/master/views/index.jade

<br/>

Запускаю jenkins job.

<br/>

Все ок.
