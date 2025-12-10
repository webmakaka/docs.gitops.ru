---
layout: page
title: GitOps Cookbook - Advanced Topics - Trigger the Deployment of an Application Automatically (Argo CD Webhooks)
description: Немедленный деплой приложения при изменении в git
keywords: books, gitops, GitOps Cookbook - Advanced Topics, Trigger the Deployment of an Application Automatically (Argo CD Webhooks)
permalink: /books/gitops/gitops-cookbook/advanced-topics/vault-external-secret/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 08. Advanced Topics: 8.3 Trigger the Deployment of an Application Automatically (Argo CD Webhooks)

<br/>

**Задача:**  
Немедленный деплой приложения при изменении в git

<br/>

**Делаю:**  
2025.12.10

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
// Проверка что прописано
$ kubectl exec -n gitea deployment/gitea -- cat /data/gitea/conf/app.ini | grep -A2 -B2 "webhook"
[webhook]
SKIP_TLS_VERIFY = true
ALLOWED_HOST_LIST = *

```

<br/>

```
// OK!
$ kubectl exec -n gitea deployment/gitea -- curl -v http://argocd-server.argocd.svc.cluster.local
```

<!-- <br/>

```
$ kubectl --namespace default port-forward svc/gitea-http 3000:3000
``` -->

<br/>

```
//    http://gitea.192.168.49.2.nip.io/https://gitea.com/gitea/helm-gitea/src/branch/main/values.yaml#L367
//    username: gitea_admin
//    password: r8sA8CPHD9!bt6d
http://gitea.192.168.49.2.nip.io/
```

<br/>

```
Import the Pac-Man manifests repo into Gitea.

GetTea -> New Migration -> GitHub

https://github.com/gitops-cookbook/pacman-kikd-manifests
```

<br/>

```
$ argocd app create pacman-webhook \
--repo http://gitea.192.168.49.2.nip.io/gitea_admin/pacman-kikd-manifests.git \
--dest-server https://kubernetes.default.svc \
--dest-namespace default \
--path k8s \
--sync-policy auto
```

<br/>

REPO -> Settings -> Webhooks -> Add Webhook -> GitTea

<br/>

```
// В книге опечатка, д.б. webhook
// Обращаюсь по ingress
• Payload URL: http://argocd.192.168.49.2.nip.io/api/webhook
• Content type: application/json
```

<br/>

```
$ kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=50 -f
time="2025-12-10T00:03:55Z" level=info msg="Received push event repo: http://gitea.192.168.49.2.nip.io/gitea_admin/pacman-kikd-manifests, revision: main, touchedHead: true"
time="2025-12-10T00:03:55Z" level=info msg="Requested app 'pacman-webhook' refresh"
failed to create fsnotify watcher: too many open files
```

<br/>

```
// FIX: failed to create fsnotify watcher: too many open files
$ sudo sysctl fs.inotify.max_user_instances=8192
$ sudo sysctl fs.inotify.max_user_watches=524288
```

<br/>

```
$ argocd app get pacman-webhook
Name:               argocd/pacman-webhook
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                https://argocd.example.com/applications/pacman-webhook
Source:
- Repo:             http://gitea.192.168.49.2.nip.io/gitea_admin/pacman-kikd-manifests.git
  Target:
  Path:             k8s
SyncWindow:         Sync Allowed
Sync Policy:        Automated
Sync Status:        Synced to  (298574a)
Health Status:      Healthy

GROUP  KIND        NAMESPACE  NAME         STATUS   HEALTH   HOOK  MESSAGE
       Namespace   default    pacman       Running  Synced         namespace/pacman created
       Service     pacman     pacman-kikd  Synced   Healthy        service/pacman-kikd created
apps   Deployment  default    pacman-kikd  Synced   Healthy        deployment.apps/pacman-kikd created
       Namespace              pacman       Synced
```

<br/>

```
$ argocd app diff pacman-webhook
```

<br/>

```
// Заметил неправильный URL для argocd
$ kubectl patch cm argocd-cm -n argocd --type merge -p '{"data":{"url":"http://argocd.192.168.49.2.nip.io"}}'
```

<br/>

```
$ argocd app get pacman-webhook
Name:               argocd/pacman-webhook
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                http://argocd.192.168.49.2.nip.io/applications/pacman-webhook
Source:
- Repo:             http://gitea.192.168.49.2.nip.io/gitea_admin/pacman-kikd-manifests.git
  Target:
  Path:             k8s
SyncWindow:         Sync Allowed
Sync Policy:        Automated
Sync Status:        Synced to  (298574a)
Health Status:      Healthy

GROUP  KIND        NAMESPACE  NAME         STATUS   HEALTH   HOOK  MESSAGE
       Namespace   default    pacman       Running  Synced         namespace/pacman created
       Service     pacman     pacman-kikd  Synced   Healthy        service/pacman-kikd created
apps   Deployment  default    pacman-kikd  Synced   Healthy        deployment.apps/pacman-kikd created
       Namespace              pacman       Synced
```

<br/>

В репо в k8s/pacman-deployment.yaml меняю на:

```
image: quay.io/gitops-cookbook/pacman-kikd:1.2.0
```

<br/>

И сразу запускается обновление pod.
