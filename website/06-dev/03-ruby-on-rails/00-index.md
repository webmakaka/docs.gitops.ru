---
layout: page
title: Программирование в Linux на Ruby on Rails
description: Программирование в Linux на Ruby on Rails
keywords: dev, ruby on rails, Программирование в Linux на Ruby on Rails
permalink: /dev/ruby-on-rails/
---

# Программирование в Linux на Ruby on Rails

Я активно использую контейрены docker. Думаю, лучше всего инсталляцию всего что нужно для разработки, можно посмотреть в файле для создания <a href="/tools/containers/docker/dockerfile/my-dockerfile-for-ruby-on-rails/">контейнера</a>.

<br/>

### Скрипт установки ruby в ubuntu bionic

```bash

#!/bin/bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io > /tmp/install.sh && chmod +x /tmp/install.sh
bash /tmp/install.sh
source /usr/local/rvm/scripts/rvm
rvm requirements
rvm install 2.4.1
rvm use 2.4.1 --default
gem install bundler -V --no-ri --no-rdoc
ruby -v
bundle -v

```

<br/>

### [Инсталляция Ruby on Rails в Centos 6.X](/dev/ruby-on-rails/installation/centos/6.X/)

<br/>

### [Сервера приложений для Ruby on Rails проектов](/dev/ruby-on-rails/app-servers/)
