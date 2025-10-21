---
layout: page
title: TOOLBOX
description: TOOLBOX
keywords: TOOLBOX
permalink: /devops/containers/coreos/toolbox/
---

# TOOLBOX

<br/>

### Fedora - по умолчанию

    # toolbox
    # yum install -y htop
    # htop

<br/>

### Если нужно debian

    # vi .toolboxrc

    TOOLBOX_DOCKER_IMAGE=debian
    TOOLBOX_DOCKER_TAG=jessie
    TOOLBOX_DOCKER_USER=root

    # toolbox

    # apt-get update && apt-get install -y htop
    # htop
