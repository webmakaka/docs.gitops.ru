---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Непрерывная интеграция
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Непрерывная интеграция
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD, Непрерывная интеграция
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/continuous-integration/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 04. Непрерывная интеграция

<br/>

### 15. Установка Jenkins

Устанавливаю <a href="/tools/ci-cd/jenkins/">Jenkins в ubuntu</a>

<br/>

Manange Jenkins -> Global Tool Configuration -> JDK -> 1.8

<br/>

### 16. Настройка проектов Jenkins

<br/>

**Jenkins**

New Item

```
Name: train-schedule
Type: Freestyle project
```

OK

<br/>

Source Code Management

Git -> https://github.com/linuxacademy/cicd-pipeline-train-schedule-jenkins

<br/>

Build -> Add build step -> Invoke Gradle script

Use Gradle Wrapper

Tasks -> build

<br/>

Post-build Actions -> Archive the artifacts

Files to archive -> dist/trainSchedule.zip

<br/>

**Build Now**

<br/>

### 17. Запуск сборок с хуками в Git (Не заработало, т.к. Нужен публичный сервер jenkins)

<br/>

**GitHub**

<br/>

GitHub -> Settings -> Developer settings -> Personal access tokens -> Generate new token

<br/>

Token description: jenkins

```
admin:repo_hook
```

<br/>

Generate token

<br/>

Copy Api Key

<br/>

**Jenkins**

<br/>

Manage Jenkins -> Configure System

Github -> GitHub Server

Name: GitHub

<br/>

Credentials -> Add -> Jenkins

Kind: Secret Text

<br/>

```
Secret: <API_KEY>
ID: github_api_key
Description: GitHub API Key
```

<br/>

Add

<br/>

Credentials -> GitHubKey

<br/>

- Manage hooks

<br/>

Save

<br/>

**Выбираем созданные ранее проект train-schedule**

Configure

Source Code Management

<br/>

Git (Форкнутый репо) -> https://github.com/wildmakaka/cicd-pipeline-train-schedule-jenkins

<br/>

Build Trigger

- GitHub hook trigger for GITScm polling

<br/>

**SAVE**

<br/>

**GitHub**

Должен появиться Webhook.

App -> Settings -> Webhooks

Но он появится, только если использовать public ip.

С localhost будет вот такое:

<br/>

```
{"resource":"Hook","code":"custom","message":"Sorry, the URL host localhost is not supported because it isn't reachable over the public Internet"}
```

<br/>

Делаем коммит, изменив файл Readme.md

<br/>

Jenkins должен автоматически пересобрать проект.
