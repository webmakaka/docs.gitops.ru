---
layout: page
title: Docker Registry Mirroring
description: Docker Registry Mirroring
keywords: devops, docker, Docker Registry Mirroring
permalink: /tools/containers/registry/docker/mirroring/
---

# Docker Registry Mirroring

<br/>

    $ mkdir mirror
    $ cd mirror/
    $ vi docker-compose.yml

https://bitbucket.org/sysadm-ru/self-hosted-docker-registry/raw/a901328b13688d3f9478995e4737cef5237431ea/mirror/docker-compose.yml

<br/>

    $ docker-compose up
    $ curl registry.local:5000/v2/_catalog
    {"repositories":[]}

<br/>

**На клиенте**

    # vi /etc/docker/daemon.json

Возможно, что insecure-registries здесь не нужно.

<br/>

```
{
      "insecure-registries": ["registry.local:5000"],
      "registry-mirrors": ["http://registry.local:5000"]
}
```

<br/>

    $ sudo systemctl daemon-reload
    $ sudo systemctl restart docker

<br/>

    $ docker system info
    ***
    Insecure Registries:
    registry.local:5000
    127.0.0.0/8
    Registry Mirrors:
    http://registry.local:5000/

<br/>

    $ time docker image pull node
    ***
    real	1m17.225s


    $ curl registry.local:5000/v2/_catalog
    {"repositories":["library/node"]}

    $ docker image rm node

    $ time docker image pull node
    ***
    real	0m21.755s
