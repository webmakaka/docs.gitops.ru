<br/>

## Gitlab Registry (собственное хранилище docker контейнеров)

Делаю:  
18.05.2019

<br/>

Поднимал на разных хостах gitlab и registry. При добавлении контейнера в registry все время было сообщение no **"container images stored for this project"**. Насколько понял из поисков,чтобы работало, нужно, чтобы gitlab и registry были на одном хосте.

<br/>

Сначала устанавливаем <a href="/devops/tools/containers/docker/setup/ubuntu/">docker</a>

<br/>

Потом поднимаем <a href="/devops/tools/containers/docker/registry/">docker registry</a>. Возможен вариант без TLS и с TLS.

<br/>

И добавляем пользователя gitlab-runner:

    # usermod -aG docker gitlab-runner
    # service docker restart

<br/>

**Обращаю внимание, что на сервере с registry, необходимо сам сервер добавить в список разрешенных работы для клиента.**

<br/>

    # vi /etc/gitlab/gitlab.rb

<br/>

**Вариант без security**

```
registry_external_url 'http://registry.local:5000'

```

<br/>

**Вариант c tls security**

В случае использования версии с TLS, то должено быть соответственно:

registry_external_url 'https://registry.local'

<br/>

А также нужно будет добавить (т.к. в конфиге не нашел) ссылки на сертификаты. См. подробности по ссылке на установку <a href="/devops/tools/containers/docker/registry/self-signed-tls-security/">registry</a>.

<br/>

```
registry_nginx['ssl_certificate'] = "/home/vagrant/certs/selfsigned.crt"
registry_nginx['ssl_certificate_key'] = "/home/vagrant/certs/selfsigned.key"
```

<br/>

**Далее:**

    # gitlab-ctl reconfigure && gitlab-ctl restart

<br/>

    # gitlab-ctl status
    # gitlab-ctl tail nginx

<br/>

http://gitlab.local

<br/>

    // Должен loging проходить.
    # docker login gitlab.local

<br/>

Генерятся конфиги. В том числе для nginx:

    /var/opt/gitlab/nginx/conf/nginx.conf
    /var/opt/gitlab/nginx/conf/gitlab-http.conf
    /var/opt/gitlab/nginx/conf/gitlab-registry.conf

<!-- <br/>

    Если в hosts gitlab.local не 127.0.0.1 пытается коннектиться по https.

<br/>

    # /etc/hosts

    192.168.0.11 registry.local
    127.0.0.1 gitlab.local -->

<br/>

<!--

    $ docker login registry.gitlab.local

-->

<!-- <br/>

    # cp /var/opt/gitlab/gitlab-rails/etc/gitlab.yml /var/opt/gitlab/gitlab-rails/etc/gitlab.yml.orig

    # vi /var/opt/gitlab/gitlab-rails/etc/gitlab.yml

<br/>

```
registry:
  enabled: true
  host: 192.168.1.11
  port: 5000
  api_url: http://localhost:5000/
```

<br/>

Settings --> CI/CD --> Pipelines --> Run Pipeline

<br/>

При сообщении:

**the project doesn't have any runners online assigned to it.**

Можно, как вариант, в настройках runner указать галочку:

Run untagged jobs: Indicates whether this runner can pick jobs without tags

<br/>

### Issue

https://forum.gitlab.com/t/unable-to-enable-gitlab-container-registry-adress-in-use/23198/2
