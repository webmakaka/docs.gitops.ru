# Исходники сайта [docs.gitops.ru](https://docs.gitops.ru)

<br/>

## Запустить локально с возможностью редактирования

Инсталлируете docker и docker-compose, далее:

```
$ cd ~
$ mkdir -p docs.gitops.ru && cd docs.gitops.ru
$ git clone --depth=1 https://github.com/webmakaka/docs.gitops.ru.git .
$ docker-compose up
```

<br/>

Остается в браузере подключиться к localhost:80

<br/>

## (Устарело!)

<br/>

### Запустить docs.gitops.ru на своем хосте с использованием docker контейнера:

```
$ docker run -i -t -p 80:80 --name docs.gitops.ru marley/docs.gitops.ru
```

<br/>

### Как сервис

```
$ sudo vi /etc/systemd/system/docs.gitops.ru.service
```

вставить содержимое файла docs.gitops.ru.service

```
$ sudo systemctl enable docs.gitops.ru.service
$ sudo systemctl start  docs.gitops.ru.service
$ sudo systemctl status docs.gitops.ru.service
```

http://localhost:4006

<br/><br/>

---

<br/>

**Marley**

Any questions in english: <a href="https://docs.gitops.ru/chat/">Telegram Chat</a>  
Любые вопросы на русском: <a href="https://docs.gitops.ru/chat/">Телеграм чат</a>
