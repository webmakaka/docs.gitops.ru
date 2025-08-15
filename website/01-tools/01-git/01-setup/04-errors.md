---
layout: page
title: Ошибки при работе с GIT
description: Ошибки при работе с GIT
keywords: Ошибки при работе с GIT
permalink: /tools/git/errors/
---

# Ошибки при работе с GIT

<br/>

### fatal: unable to access SSL connect error

    $ git pull
    fatal: unable to access 'https://sysadm-ru@bitbucket.org/sysadm-ru/sysadm.ru.git/': SSL connect error

<br/>

Попробовал выполнить команду, написанную ниже. Получил тоже сообщение об ошибке.

<br/>

### fatal: HTTP request failed

    # git clone --depth=1 https://github.com/git/git.git
    Initialized empty Git repository in /tmp/git/.git/
    error:  while accessing https://github.com/git/git.git/info/refs

    fatal: HTTP request failed

<br/>

### Исправилась выполнением команды:

    # yum update -y nss curl
