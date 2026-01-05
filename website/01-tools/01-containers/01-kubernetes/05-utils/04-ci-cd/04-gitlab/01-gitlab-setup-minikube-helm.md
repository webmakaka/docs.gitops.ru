---
layout: page
title: Инсталляция GitLab в ubuntu 22.04
description: Инсталляция GitLab в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, GitLab, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/gitlab/setup/helm/minikube/
---

# Инсталляция GitLab в ubuntu 22.04

<br/>

**Делаю:**  
2026.01.05

<br/>

# Разбираюсь как устанавливать!!!

<br/>

### Инсталляция GitLab с помощью helm

```
$ helm repo add gitlab https://charts.gitlab.io/
$ helm repo update
```

<br/>

```
$ export PROFILE=${USER}-minikube
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo gitlab.$INGRESS_HOST.nip.io
```

<br/>

```
$ helm search repo gitlab
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > gitlab.values.yaml <<EOF
global:
  edition: ce
  hosts:
    domain: $INGRESS_HOST.nip.io
    externalIP: $INGRESS_HOST

  ingress:
    configureCertmanager: false

certmanager-issuer:
  email: skip@example.com

# В этой версии certmanager настраивается по-другому
# Вместо certmanager.install используем это:
cert-manager:
  install: false

gitlab-runner:
  install: false

# Отключаем ненужные компоненты
registry:
  enabled: false

minio:
  enabled: false

# Настройки ingress для локального использования
nginx-ingress:
  enabled: true
  controller:
    service:
      type: NodePort
EOF
```

<!-- <br/>

```
$ helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --create-namespace \
  --set global.edition=ce \
  --set gitlab-runner.install=false \
  --set global.hosts.domain=gitlab.$INGRESS_HOST.nip.io \
  --set global.hosts.externalIP=$INGRESS_HOST \
  --set certmanager-issuer.email=skip@example.com \
  --set global.ingress.configureCertmanager=false \
  --version 9.7.0 \
  --wait \
  --timeout 15m
``` -->

<br/>

```
$ helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --create-namespace \
  --version 9.7.0 \
  --wait \
  --timeout 15m
```

<br/>

```
$ kubectl get ingress -n gitlab
NAME                        CLASS          HOSTS                                 ADDRESS        PORTS     AGE
gitlab-kas                  gitlab-nginx   kas.gitlab.192.168.49.2.nip.io        192.168.49.2   80, 443   12m
gitlab-minio                gitlab-nginx   minio.gitlab.192.168.49.2.nip.io      192.168.49.2   80, 443   12m
gitlab-registry             gitlab-nginx   registry.gitlab.192.168.49.2.nip.io   192.168.49.2   80, 443   12m
gitlab-webservice-default   gitlab-nginx   gitlab.gitlab.192.168.49.2.nip.io     192.168.49.2   80, 443   12m
```

<br/>

```
// Получить root пароль GitLab
$ kubectl get secret -n gitlab gitlab-gitlab-initial-root-password \
  -o jsonpath='{.data.password}' | base64 --decode && echo
```

<br/>

```
// root / <root-password>
gitlab.gitlab.192.168.49.2.nip.io
```

<br/>

# Подключиться к toolbox контейнеру

kubectl exec -n gitlab -it deployment/gitlab-toolbox -- bash

# Запустить rails console

gitlab-rails console

# Включить импорт из GitHub

ApplicationSetting.current.update!(import_sources: ['github'])

# Проверить

ApplicationSetting.current.import_sources
