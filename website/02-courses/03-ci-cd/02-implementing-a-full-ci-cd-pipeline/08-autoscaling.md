---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Автоматическое масштабирование
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Автоматическое масштабирование
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD, Автоматическое масштабирование
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/autoscaling/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 10. Автоматическое масштабирование

(НЕ ТЕСТИРОВАЛОСЬ!!!)

<br/>

Необходимо установить Horizontal Pod Autoscaler:

```
$ cd ~/
$ git clone https://github.com/kubernetes-incubator/metrics-server.git

$ cd metrics-server/
$ kubectl create -f deploy/1.8+/
$ kubectl get --raw /apis/metrics.k8s.io/

$ cd ~/
$ git clone
$ cd cicd-pipeline-train-schedule-autoscaling/

$ vi train-schedule-kube.yml
$ kubectl apply -f train-schedule-kube.yml
```

<br/>

Далее выполните это в оболочке busybox для создания нагрузки:

    $ kubectl get hpa -w

<br/>

    $ kubectl run -i --tty load-generator --image=busybox /bin/sh

<br/>

    $ while true; do wget -q -O- http://<IP Адрес Ноды Kubernetes>:8080/generate-cpu-load; done

<br/>

https://github.com/linuxacademy/cicd-pipeline-train-schedule-autoscaling

<br/>

**Конфиг для запуска pods:**

https://github.com/linuxacademy/cicd-pipeline-train-schedule-autoscaling/blob/example-solution/train-schedule-kube.yml
