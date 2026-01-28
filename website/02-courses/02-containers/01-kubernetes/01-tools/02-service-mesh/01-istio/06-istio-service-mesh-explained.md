---
layout: page
title: Istio Service mesh explained
description: Istio Service mesh explained
keywords: devops, containers, kubernetes, service-mesh, istio
permalink: /courses/containers/kubernetes/service-mesh/istio/istio-service-mesh-explained/
---

# [That DevOps Guy] Istio Service mesh explained

<br/>

Делаю:  
14.02.2021

<br/>

Если сначала поднять ISTIO, а потом попробовать запустить в minikube предустановленный ingress, возможно он не заведется. (Долго пытался установиться, но не судьба. М.б. нужно было ждать дольше).

<br/>

Поднимаю как <a href="//docs.k8s.ru/tools/containers/kubernetes/utils/service-mesh/istio/setup/">здесь</a>

<br/>

**YouTube**  
https://www.youtube.com/watch?v=KUHzxTCe5Uc

<br/>

**GitHub**  
https://github.com/marcel-dempers/docker-development-youtube-series

<br/>

**Дока**  
https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/kubernetes/servicemesh/istio

<br/>

### Запуск приложения

```
$ cd ~/tmp
$ git clone https://github.com/marcel-dempers/docker-development-youtube-series
$ cd docker-development-youtube-series/
```

<br/>

Ingress конфиг лежит вместе с остальными файлами в каталоге videos-web/:

<br/>

**applications**

```
$ kubectl apply -f kubernetes/servicemesh/applications/playlists-api/
$ kubectl apply -f kubernetes/servicemesh/applications/playlists-db/
$ kubectl apply -f kubernetes/servicemesh/applications/videos-api/
$ kubectl apply -f kubernetes/servicemesh/applications/videos-web/
$ kubectl apply -f kubernetes/servicemesh/applications/videos-db/
```

<br/>

```
$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
playlists-api-684fb4c5d7-crvqk   2/2     Running   0          57s
playlists-db-7d68bbf5c4-rvt7z    2/2     Running   0          50s
videos-api-ccc8f5b46-qvqj6       2/2     Running   0          45s
videos-db-85ccd8bc-xbzrr         2/2     Running   0          34s
videos-web-cdbc466f4-nqsm6       2/2     Running   0          39s
```

<br/>

```
$  kubectl get ing
NAME            CLASS    HOSTS              ADDRESS        PORTS   AGE
playlists-api   <none>   servicemesh.demo   192.168.49.2   80      22m
videos-web      <none>   servicemesh.demo   192.168.49.2   80      22m
```

<br/>

```
$ sudo vi /etc/hosts
```

```
192.168.49.2  servicemesh.demo
```

<br/>

http://servicemesh.demo/home/

OK!

<br/>

### Изучаем

```
while :
do
    curl "http://servicemesh.demo/home/";
    curl "http://servicemesh.demo/api/playlists";
    sleep 10;
done
```

<br/>

Попробовали GIT Grafana (istio / Istio Mesh Dashboard) и Kiali.

Поломали контейнер, чтобы он работал неправильно.

<br/>

Создали виртуальный сервис и поделили трафик между этими сервисами.

<br/>

Попробовали Canary Deployment в зависимости от cookies. Если есть на 1 сервис, если нет, на другой.
