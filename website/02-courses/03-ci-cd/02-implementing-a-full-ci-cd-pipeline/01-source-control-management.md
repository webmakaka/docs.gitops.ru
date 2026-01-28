---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - 02. Управление версиями исходного кода
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - 02. Управление версиями исходного кода
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/source-control-management/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 02. Управление версиями исходного кода

<br/>

### 05. Установка Git

<br/>

    $ apt install -y git

<br/>

    $ git config user.name "username"
    $ git config user.email "useremail@gmail.com"

<br/>

    $ ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""

<br/>

    $ cat ~/.ssh/id_rsa.pub

<br/>

GitHub -> Settings -> SSH and GPG keys

New SSH key

<br/>

```
Title: <ComputerHostname>
Key: <SSH_PUBLIC_KEY>
```
