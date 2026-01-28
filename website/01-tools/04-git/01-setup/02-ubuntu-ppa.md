---
layout: page
title: Обновление GIT до актуальных версий из ppa в Ubuntu
description: Обновление GIT до актуальных версий из ppa в Ubuntu
keywords: Обновление GIT до актуальных версий из ppa в Ubuntu
permalink: /tools/git/setup/ubuntu/ppa/
---

# Обновление GIT до актуальных версий из ppa в Ubuntu

Делаю:  
27.03.2018

Была версия 1.x git нужна 2.x

    $ sudo add-apt-repository ppa:git-core/ppa -y
    $ sudo apt-get update
    $ sudo apt-get install git -y
    $ git --version
    git version 2.16.2
