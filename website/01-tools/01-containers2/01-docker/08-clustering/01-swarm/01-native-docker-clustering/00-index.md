---
layout: page
title: Docker Swarm > Native Docker Clustering [2016, ENG]
description: Docker Swarm > Native Docker Clustering [2016, ENG]
keywords: devops, containers, docker, clustering, swarm, native docker clustering
permalink: /devops/containers/docker/clustering/swarm/native-docker-clustering/
---

# Docker Swarm: Native Docker Clustering [2016, ENG]

<br/>

Вот такую схему собираем:

<br/>

![Native Docker Clustering](/img/devops/containers/docker/clustering/swarm/native-docker-clustering/pic1.png 'Native Docker Clustering'){: .center-image }

<br/>

В курсе используется consul. Исходники контейнеров можно попытаться восстоздать. В курсе они не приводятся.

<br/>

Я использую vagrant для старта сразу нескольких виртуальных машин virtualbox с coreos внутри.

**Файлы для старта виртуальных машин с coreos**

https://bitbucket.org/sysadm-ru/native-docker-clustering

<br/>

Шаг по настройке security не завершил. Без этого шага ничего не работает. Содрежимое контейнеров и как они работают, пока не разобрался.

<br/>

<ul>
    <li>
        <a href="/devops/containers/docker/clustering/swarm/native-docker-clustering/configs/">Configs</a>
    </li>
    <li>
        <a href="/devops/containers/docker/clustering/swarm/native-docker-clustering/building-your-swarm-infrastructure/">Module 4: Building your Swarm Infrastructure</a>
    </li>
    <li>
        <a href="/devops/containers/docker/clustering/swarm/native-docker-clustering/securing-your-swarm-cluster/">Module 5: Securing your Swarm Cluster</a>
    </li>
</ul>
