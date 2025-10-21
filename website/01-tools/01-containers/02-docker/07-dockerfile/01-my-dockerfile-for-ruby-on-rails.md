---
layout: page
title: Dockerfile для разработки ruby on rails приложений в centos 6
description: Dockerfile для разработки ruby on rails приложений в centos 6
keywords: devops, docker, Dockerfile для разработки ruby on rails приложений в centos 6
permalink: /devops/containers/docker/dockerfile/my-dockerfile-for-ruby-on-rails/
---

# Dockerfile для разработки ruby on rails приложений в centos 6

**Последний раз делаю:**  
03.12.2017

<br/>

Когда создавался dockerfile, у docker была только версия 1.x их продукта. Много чего не работало. Наверняка, за это время много чего поменялось и много чего добавили / исправили. Буду признателен, если кто-то пожелает обновить.

<br/>

    $ vi Dockerfile

<br/>

{% highlight text %}

### Dockerfile

FROM centos:centos6
MAINTAINER marley (www.marley.org)

RUN yum -y update; yum clean all

# RUN yum -y install epel-release; yum clean all

ENV DOCKER_ROOT_PASSWORD root
ENV DEVELOPER_USERNAME developer
ENV DEVELOPER_PASSWORD developer

ENV RUBY_VERSION 2.4.2
#ENV RAILS_VERSION 5.1.4
ENV RAILS_VERSION 4.2.10

RUN echo "root:\$DOCKER_ROOT_PASSWORD" | chpasswd

RUN yum install -y sudo which unzip tar bzip2 vim wget nc telnet screen tcpdump traceroute bind-utils lsof curl libcurl-devel openssl-devel git make gcc gcc-c++ kernel-devel && \
yum install -y readline-devel && \
yum install -y sqlite-devel mysql-devel postgresql-devel && \
yum clean all

# ==============================================

RUN echo '############################' >> /etc/sudoers
RUN echo '### ADDITIONAL SUDO USER ###' >> /etc/sudoers
RUN echo \$DEVELOPER_USERNAME 'ALL=(ALL:ALL) ALL' >> /etc/sudoers
RUN echo '############################' >> /etc/sudoers

RUN sed -i.gres "s/Defaults requiretty/#Defaults requiretty/g" /etc/sudoers

# ==============================================

# ====== GIT 2.X =========================

RUN yum install -y git tar gcc && \
 yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel && \
 yum install -y perl-ExtUtils-MakeMaker
RUN mkdir -p /opt/git/2.3.0

WORKDIR /tmp
RUN git clone --depth=1 https://github.com/git/git.git
WORKDIR /tmp/git

RUN make prefix=/opt/git/2.3.0 all
RUN make prefix=/opt/git/2.3.0 install

# RUN yum remove -y git

# =======================================

RUN mkdir /project

RUN useradd $DEVELOPER_USERNAME
RUN echo "$DEVELOPER_USERNAME:\$DEVELOPER_PASSWORD" | chpasswd

RUN chown -R \$DEVELOPER_USERNAME /project/

# =================================================

USER \$DEVELOPER_USERNAME

WORKDIR /home/\$DEVELOPER_USERNAME

ENV HOME /home/\$DEVELOPER_USERNAME

RUN git clone git://github.com/sstephenson/rbenv.git $HOME/.rbenv
RUN git clone git://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build

# =======================================

# =========== RUBY ENVIRONMENT ==========

RUN echo '### RUBY ON RAILS ###' >> $HOME/.bash_profile
RUN echo 'umask 011' >> $HOME/.bash_profile
RUN echo '' >> \$HOME/.bash_profile

RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.bash_profile
RUN echo 'export PATH="$HOME/.rbenv/shims:$PATH"' >> $HOME/.bash_profile
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.bash_profile
RUN echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> \$HOME/.bash_profile

RUN echo '### RUBY ON RAILS END ###' >> \$HOME/.bash_profile

# =======================================

ENV PATH $HOME/.rbenv/bin:$PATH
ENV PATH $HOME/.rbenv/shims:$PATH

RUN rbenv install $RUBY_VERSION
RUN rbenv global $RUBY_VERSION

RUN echo "gem: --no-ri --no-rdoc" > \$HOME/.gemrc

RUN gem update --system
RUN gem update

### TEMPORARY SOLUTION

### https://github.com/rubygems/rubygems/issues/2058

RUN rm -rf /home/developer/.rbenv/versions/2.4.2/bin/bundle

### TEMPORARY SOLUTION END

RUN gem install bundler --no-ri --no-rdoc
RUN rbenv rehash

RUN gem install rails -v \$RAILS_VERSION --no-ri --no-rdoc
RUN rbenv rehash

# =======================================

# =========== GIT 2.X ENVIRONMENT ==========

RUN echo '' >> $HOME/.bash_profile
RUN echo '' >> $HOME/.bash_profile
RUN echo '#### GIT ##############################' >> \$HOME/.bash_profile

RUN echo 'export GIT_HOME=/opt/git/2.3.0' >> $HOME/.bash_profile
RUN echo 'export PATH=$PATH:$GIT_HOME/bin' >> $HOME/.bash_profile

RUN echo '#### GIT END ##########################' >> \$HOME/.bash_profile

# =======================================

RUN echo \$DEVELOPER_PASSWORD | sudo -S /usr/bin/yum remove -y git

RUN source ~/.bash_profile

CMD ["/bin/bash"]

{% endhighlight %}

<br/>

Создать image с удалением промежуточных контейнеров в случае успешного билда

    $ docker build --rm -t centos6/rais:v01 .

    -t - tag (название создаваемого image)

<br/>

    Теперь стало возможным указать название docerfile.
    -f myDockerFile

Создать контейнер на базе подготовленного image

    $ docker run -i -t -p 80:8080 --name dev -v /project:/project centos6/rais:v01 /bin/bash

В моем случае, я еще добавлю параметров.

    $ docker run -i -t -p 80:8080 -p 3000:3000 -p 9000:9000 -p 1337:1337 --name dev -v /mnt/dsk0/project:/project -e SECRET_KEY_BASE=test centos6/rais:v01 /bin/bash

<br/>

    -p порт на хост машине, будет соответствовать порту в контейнере.
    -v позволяет смонтировать каталог файловой системы вместе с контейнером docker, чтобы можно было кодить на хост машине а запускать в контейнере.

Можно также открыть:

3306 - для mysql

После подключения к контейнеру, выполнить.

    $ source ~/.bash_profile

На хостовой машине:

    chown -R <username> /project/ && chmod 777 -R  /project/

---

sudo: sorry, you must have a tty to run sudo - ошибка возникает, если вы пытаетесь выполнить команду в скрипте от другого пользователя при помощи sudo. Чтобы исправить, достаточно закомментировать **Default requiretty** в файле /etc/sudoers.

Для запуска команд под привелигированным пользователем, в файл /etc/sudoers добавляем username ALL=(ALL:ALL) ALL.
