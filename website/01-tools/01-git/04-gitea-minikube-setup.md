---
layout: page
title: Установка gitea в minikube
description: Установка gitea в minikube
keywords: Установка gitea в minikube
permalink: /tools/git/gitea/minikube/setup/
---

# Установка gitea в minikube

<br/>

**Делаю:**  
2026.01.27

<br/>

```
$ export PROFILE=${USER}-minikube
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo gitea.$INGRESS_HOST.nip.io
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > gitea-values.yaml <<EOF
gitea:
  config:
    server:
      DOMAIN: gitea.$INGRESS_HOST.nip.io
      ROOT_URL: http://gitea.$INGRESS_HOST.nip.io
    webhook:
      ALLOWED_HOST_LIST: "*"
      SKIP_TLS_VERIFY: true

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: gitea.$INGRESS_HOST.nip.io
      paths:
        - path: /
          pathType: Prefix
EOF
```

<br/>

```
$ helm repo add gitea-charts https://dl.gitea.io/charts/
$ helm repo update
$ helm install gitea gitea-charts/gitea \
  --namespace gitea \
  --create-namespace \
  -f gitea-values.yaml \
  --wait
```

<!-- <br/>

```
$ helm upgrade -i gitea gitea-charts/gitea --create-namespace \
-f gitea-values.yaml
``` -->

```
// Проверка что прописаны параметры для webhook
$ kubectl exec -n gitea deployment/gitea -- cat /data/gitea/conf/app.ini | grep -A2 -B2 "webhook"
[webhook]
SKIP_TLS_VERIFY = true
ALLOWED_HOST_LIST = *

```

<br/>

```
// Если нужно проверить доступ сервиса
// $ kubectl exec -n gitea deployment/gitea -- curl -v http://argocd-server.argocd.svc.cluster.local
```

<br/>

```
//    http://gitea.192.168.49.2.nip.io/https://gitea.com/gitea/helm-gitea/src/branch/main/values.yaml#L367
//    username: gitea_admin
//    password: r8sA8CPHD9!bt6d
http://gitea.192.168.49.2.nip.io/
```
