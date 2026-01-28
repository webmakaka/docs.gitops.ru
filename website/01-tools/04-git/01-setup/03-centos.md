---
layout: page
title: Инсталляция GIT из исходников в Centos
description: Инсталляция GIT из исходников в Centos
keywords: Инсталляция GIT из исходников в Centos
permalink: /tools/git/setup/centos/
---

# Инсталляция GIT из исходников в Centos 6.x / 7.x

Если git из стандартных репозиториев не устраивает. Например не пушит на github.

<h3>git 2.x</h3>

    # yum install -y git
    # yum install -y tar gcc

<br/>

    # yum install -y \
    curl-devel \
    expat-devel \
    gettext-devel \
    openssl-devel \
    zlib-devel

<br/>

    # yum install -y perl-ExtUtils-MakeMaker


    # cd /tmp

// Устанавливаем последнюю версию

    # git clone --depth=1 https://github.com/git/git.git

<br/>

    # cd git/


    # head -c 100 GIT-VERSION-FILE
    GIT_VERSION = 2.13.GIT

<br/>

    # mkdir -p /opt/git/2.13.0

<br/>

    # make prefix=/opt/git/2.13.0 all
    # make prefix=/opt/git/2.13.0 install

<br/>

    $ /opt/git/2.13.0/bin/git --version

<br/>

    # yum remove -y git

<br/>

    # su - <username>

<br/>

    # vi ~/.bash_profile

<br/>

    #### GIT ##############################

        export GIT_HOME=/opt/git/2.13.0
        export PATH=$PATH:$GIT_HOME/bin

    #### GIT ##############################

<br/>

    $ source ~/.bash_profile

<br/>

    $ git --version
    git version 2.13.GIT
