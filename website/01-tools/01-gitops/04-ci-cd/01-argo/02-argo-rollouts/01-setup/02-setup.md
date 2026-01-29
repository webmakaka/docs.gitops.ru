---
layout: page
title: Инсталляция Argo Rollouts с помощью Helm
description: Инсталляция Argo Rollouts с помощью Helm
keywords: devops, containers, kubernetes, argo, rollouts, setup, minikube
permalink: /tools/gitops/ci-cd/argo/argo-rollouts/setup/
---

# Инсталляция Argo Rollouts с помощью Helm

<br/>

### [CLI Argo Rollouts](/tools/gitops/ci-cd/argo/argo-rollouts/setup/cli/)

<br/>

## Инсталляция с помощью Helm

<br/>

https://artifacthub.io/packages/helm/argo/argo-rollouts

<br/>

Делаю:  
2026.01.28

<br/>

```
$ helm repo add argo https://argoproj.github.io/argo-helm
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > values-argo-rollouts.yaml <<EOF
dashboard:
  enabled: true
EOF
```

<br/>

```
$ helm upgrade argo-rollouts argo/argo-rollouts \
    --install \
    --namespace argo-rollouts \
    --create-namespace \
    --version 2.40.5 \
    --values values-argo-rollouts.yaml
```

<br/>

```
$ {
    TIMEFORMAT="⏱ Прошло времени: %R сек."
    time {
      kubectl wait --namespace argo-rollouts \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/instance=argo-rollouts \
        --timeout=300s && \
        echo "✅ Успех: Все поды ArgoCD запущены!" || \
        (echo "❌ Ошибка: Тайм-аут!"; exit 1)
      }
}
```

<br/>

```
$ kubectl get pods -n argo-rollouts
NAME                                      READY   STATUS              RESTARTS   AGE
argo-rollouts-6ccc9f6fb5-v4g64            0/1     Completed           0          19s
argo-rollouts-6ccc9f6fb5-xvvkq            1/1     Running             0          10m
argo-rollouts-6d6948675d-45xvn            1/1     Running             0          19s
argo-rollouts-6d6948675d-m8w6k            0/1     ContainerCreating   0          2s
argo-rollouts-dashboard-9996f6666-qpsp5   1/1     Running             0          19s
```

<br/>

```
$ kubectl get crds | grep rollouts
rollouts.argoproj.io                   2026-01-28T17:15:07Z
```

<br/>

```
$ kubectl argo rollouts dashboard
```

<br/>

```
http://localhost:3100/rollouts
```
