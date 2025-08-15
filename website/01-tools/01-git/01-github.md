---
layout: page
title: Настройки git для работы с github
description: Настройки git для работы с github
keywords: Настройки git для работы с github
permalink: /tools/git/github/
---

# Настройки git для работы с github

<br/>

### Инсталляция gh в Ubuntu Linux

<br/>

gh - консольная программа для работы с GitHub API в командной строке.

<br/>

```
$ cd ~/tmp
```

<br/>

```
$ vi gh.sh
```

<br/>

```
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable master" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

<br/>

```
$ chmod +x gh.sh
$ ./gh.sh
```

<br/>

```
// Чтобы создавался origin на ssh а не https
$ gh config set git_protocol ssh -h github.com
```

<br/>

```
$ git config --global user.name "<GITHUB_USERNAME>"
$ git config --global user.email "<GITHUB_EMAIL>"
```

<br/>

## Настройка работы с GitHub по SSH ключу

<br/>

### Сгенерировать ключ для GitHub

<br/>

```
$ cd ~/.ssh/
```

<br/>

```
$ ssh-keygen \
-t rsa \
-b 4096 \
-C "example@gmail.com" \
-f webmakaka
```

<br/>

```
$ chmod 0600 webmakaka*
$ eval "$(ssh-agent -s)"
```

<br/>

```
// Добавить ключ
$ ssh-add ~/.ssh/webmakaka

// Проверка, что ключ добавлен
$ ssh-add -l -E md5
```

<br/>

```
// Посмотреть public key
$ cat webmakaka.pub
```

<br/>

В настройка аккаунта github добавить public key

https://github.com/settings/keys

New SSH key

<br/>

```
// Проверка возможности подключиться
$ ssh -T git@github.com

// При необходимости использовать токен
$ GIT_SSH_COMMAND='ssh -i ~/.ssh/webmakaka -o IdentitiesOnly=yes' ssh -T git@github.com
```

<br/>

### Использовать несколько ключей для разных github аккаунтов

<br/>

```
$ GIT_SSH_COMMAND='ssh -i ~/.ssh/webmakaka -o IdentitiesOnly=yes' git push
```

<br/>

<!--

// Страница генерации токена
https://github.com/settings/tokens

-->
