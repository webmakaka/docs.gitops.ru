---
layout: page
title: Update CoreOS
description: Update CoreOS
keywords: Update CoreOS
permalink: /devops/containers/coreos/update/
---

# Update CoreOS

// Узнать Какая версия CoreOS установлена

    $ cat /etc/os-release
    NAME=CoreOS
    ID=coreos
    VERSION=899.13.0
    VERSION_ID=899.13.0
    BUILD_ID=2016-03-23-0120
    PRETTY_NAME="CoreOS 899.13.0"
    ANSI_COLOR="1;32"
    HOME_URL="https://coreos.com/"
    BUG_REPORT_URL="https://github.com/coreos/bugs/issues"

<br/>

// Обновление CoreOS

    $ update_engine_client -check_for_update

    $ update_engine_client -update

Компьютер самостоятельно перезагрузился через 5 как закончилось обновление.

<br/>

    $ cat /etc/os-release
    NAME=CoreOS
    ID=coreos
    VERSION=899.15.0
    VERSION_ID=899.15.0
    BUILD_ID=2016-04-05-1035
    PRETTY_NAME="CoreOS 899.15.0"
    ANSI_COLOR="1;32"
    HOME_URL="https://coreos.com/"
    BUG_REPORT_URL="https://github.com/coreos/bugs/issues"
