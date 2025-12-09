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
2025.12.09

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > gitea-values.yaml <<EOF
gitea:
  config:
    webhook:
      ALLOWED_HOST_LIST: "*"
      SKIP_TLS_VERIFY: true
EOF
```

<br/>

```
$ helm repo add gitea-charts https://dl.gitea.io/charts/
$ helm install gitea gitea-charts/gitea  --namespace gitea --create-namespace \
-f gitea-values.yaml
```

<!-- <br/>

```
$ helm upgrade -i gitea gitea-charts/gitea --create-namespace \
-f gitea-values.yaml
``` -->

```
$ kubectl exec -n gitea deployment/gitea -- cat /data/gitea/conf/app.ini | grep -A2 -B2 "webhook"
```

```
$ kubectl exec -n gitea deployment/gitea -- curl -v http://argocd-server.argocd.svc.cluster.local
```

<br/>

```
$ kubectl --namespace default port-forward svc/gitea-http 3000:3000
```

<br/>

```
//    username: gitea_admin
//    password: r8sA8CPHD9!bt6d
// https://gitea.com/gitea/helm-gitea/src/branch/main/values.yaml#L367
http://127.0.0.1:3000/
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
--repo http://gitea-http.default.svc:3000/gitea_admin/pacman-kikd-manifests.git \
--dest-server https://kubernetes.default.svc \
--dest-namespace default \
--path k8s \
--sync-policy auto
```

<br/>

```
// В книге опечатка, д.б. webhook
// Обращаюсь по ingress
• Payload URL: http://argocd.192.168.58.2.nip.io/api/webhook
• Content type: application/json
```

<br/>

```
$ kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=100 -f


time="2025-12-09T18:39:00Z" level=info msg="Received push event repo: http://git.example.com/gitea_admin/pacman-kikd-manifests, revision: main, touchedHead: true"
time="2025-12-09T18:41:54Z" level=info msg="invalidated cache for resource in namespace: argocd with the name: argocd-notifications-secret"
time="2025-12-09T18:41:54Z" level=info msg="invalidated cache for resource in namespace: argocd with the name: argocd-notifications-cm"
failed to create fsnotify watcher: too many open files
```
