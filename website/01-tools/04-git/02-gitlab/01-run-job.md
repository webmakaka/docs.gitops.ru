---
layout: page
title: Попытка запустить Job в ранее установленном GitLab
description: Попытка запустить Job в ранее установленном GitLab
keywords: devops, gitops, cvs, gitlab, run job
permalink: /tools/git/gitlab/run-job/
---

# Попытка запустить Job в ранее установленном <a href="/tools/cvs/gitlab/setup/ubuntu/">GitLab</a>

<br/>

    $ su - gitlab

<br/>

Для начала, установлю <a href="/devops/tools/containers/docker/setup/ubuntu/">docker</a>

    $ sudo usermod -aG docker gitlab
    $ sudo usermod -aG docker vagrant
    $ sudo usermod -aG docker gitlab-runner

<br/>

```
$ gitlab-runner verify
```

<br/>

Создать нового пользователя и залогиниться им.

(Root в админке (Admin area) должен разрешить работу с gitlab созданным юзером.)

<br/>

Генерю rsa ключи:

    $ ssh-keygen -t rsa -N ''
    $ cat ~/.ssh/id_rsa.pub

<br/>

Settings --> SSH Keys

Добавить ключ с хост машины.

<br/>

Импортирую репо (New Project -> Import -> Repo Url):  
https://bitbucket.org/marley-golang/continuous-integration-on-gitlab/

<br/>

Войти как root --> Admin area --> Runners --> Скопировать registration token

<br/>

```
$ sudo gitlab-runner register
```

<br/>

```
Please enter the gitlab-ci coordinator URL: [http://gitlab.local]
Please enter the gitlab-ci token for this runner: [<myToken>]
Please enter the gitlab-ci description for this runner: [local-docker-runner]
Please enter the gitlab-ci tags for this runner (comma separated): [go-runner]
Please enter the executor: [docker]
Default docker image: [golang:1.7]
```

<br/>

```
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

<br/>

    $ sudo vi /etc/gitlab-runner/config.toml

В конец блока:

    [runner.docker]

добавить

    extra_hosts = ["gitlab.local:192.168.0.5"]

<br/>

    $ sudo gitlab-runner restart

<br/>

Изменить в файле проекта, например, в файле main.go текст World на что-нибудь.

CI/CD -> Pipelines

Все OK.

<!--
<br/>
    $ sudo gitlab-runner run
-->

<br/>

### Ошибки

Была ошибка:

```
ERRO[0000] Docker executor: prebuilt image helpers will be loaded from /var/lib/gitlab-runner.
Running in system-mode.
```

<br/>

Пришлось переустановить runner. Ранее у меня был установлен из репозитория ubuntu.
Установил из оф.репо. Заработало.

<br/>

### Полезные команды:

<br/>

    // Получить информацию по установленной версии gitlab
    $ sudo gitlab-rake gitlab:env:info

<br/>

    // логи nginx
    # gitlab-ctl tail nginx

<!--

```
$ sudo gitlab-runner register -n \
  --url http://gitlab.local/ \
  --registration-token bCZh-V_zyksxUPipzYoB \
  --executor shell \
  --description "shell-builder"
```

```
sudo gitlab-runner register -n \
  --url http://gitlab.local/ \
  --registration-token bCZh-V_zyksxUPipzYoB \
  --executor docker \
  --description "docker-builder" \
  --docker-image "docker:latest" \
  --docker-privileged
```

-->

<br/>

### Может быть полезно

**Install GitLab Runner using the official GitLab repositories**  
https://docs.gitlab.com/runner/install/linux-repository.html
