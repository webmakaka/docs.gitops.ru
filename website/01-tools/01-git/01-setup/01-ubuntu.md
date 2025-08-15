---
layout: page
title: Инсталляция GIT из исходников в Ubuntu
description: Инсталляция GIT из исходников в Ubuntu
keywords: Инсталляция GIT из исходников в Ubuntu
permalink: /tools/git/setup/ubuntu/
---

# Инсталляция GIT из исходников в Ubuntu

<br/>

    # apt-get install -y git
    # git --version
    # cd /tmp
    # git clone --depth=1 https://github.com/git/git.git
    # cd git/
    # less RelNotes
    Git 2.14 Release Notes

<br/>

    # apt-get install -y \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
    libz-dev \
    libssl-dev \
    build-essential

<br/>

    # make prefix=/opt/git/2.14 all
    # make prefix=/opt/git/2.14 install

<br/>

    # /opt/git/2.14/bin/git --version
    git version 2.13.1.516.g05ec6e1

<br/>

    # apt-get remove -y git

<br/>

    # su - <user_name>

<br/>

    # ln -s /opt/git/2.14 /opt/git/current

<br/>

    $ vi ~/.bashrc

<br/>

    #### GIT ##############################

        export GIT_HOME=/opt/git/current
        export PATH=$PATH:$GIT_HOME/bin

    #### GIT ##############################

<br/>

    $ logout

<br/>

    $ git --version
    git version 2.13.1.516.g05ec6e1
