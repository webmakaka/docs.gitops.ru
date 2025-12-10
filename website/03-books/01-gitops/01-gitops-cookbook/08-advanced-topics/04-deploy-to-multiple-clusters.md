---
layout: page
title: GitOps Cookbook - Advanced Topics - Deploy to Multiple Clusters
description: Вы хотите деплоить приложение на разные кластеры
keywords: books, gitops, GitOps Cookbook - Advanced Topics, Deploy to Multiple Clusters
permalink: /books/gitops/gitops-cookbook/advanced-topics/deploy-to-multiple-clusters/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 08. Advanced Topics: 8.4 Deploy to Multiple Clusters

<br/>

**Задача:**  
Вы хотите деплоить приложение на разные кластеры

<br/>

**Делаю:**  
2025.12.10

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: bgd-app
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - cluster: staging
            url: https://kubernetes.default.svc
            location: default
          - cluster: prod
            url: https://kubernetes.default.svc
            location: app
  template:
    metadata:
      name: '{{cluster}}-app'
    spec:
      project: default
      source:
        repoURL: https://github.com/gitops-cookbook/gitops-cookbook-sc.git
        targetRevision: main
        path: ch08/bgd-gen/{{cluster}}
      destination:
        server: '{{url}}'
        namespace: '{{location}}'
      syncPolicy:
        syncOptions:
          - CreateNamespace=true
EOF
```

<br/>

```
$ export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
$ echo ${ARGOCD_PASSWORD}
```

<br/>

```
$ argocd login \
    --insecure \
    --username admin \
    --password $ARGOCD_PASSWORD \
    --grpc-web \
    argocd.${INGRESS_HOST}.nip.io
```

<br/>

```
$ argocd app list
NAME                CLUSTER                         NAMESPACE  PROJECT  STATUS     HEALTH   SYNCPOLICY  CONDITIONS  REPO                                                       PATH                  TARGET
argocd/prod-app     https://kubernetes.default.svc  app        default  OutOfSync  Missing  Manual      <none>      https://github.com/gitops-cookbook/gitops-cookbook-sc.git  ch08/bgd-gen/prod     main
argocd/staging-app  https://kubernetes.default.svc  default    default  OutOfSync  Missing  Manual      <none>      https://github.com/gitops-cookbook/gitops-cookbook-sc.git  ch08/bgd-gen/staging  main
```

<br/>

```
$ kubectl get ApplicationSet -n argocd
NAME      AGE
bgd-app   17m
```

<br/>

```
// Удаляем ранее созданный ApplicationSet
$ kubectl delete ApplicationSet bgd-app -n argocd
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-addons
  namespace: argocd
spec:
  generators:
    - git:
        repoURL: https://github.com/gitops-cookbook/gitops-cookbook-sc.git
        revision: main
        directories:
          - path: ch08/bgd-gen/*
  template:
    metadata:
      name: '{{path[0]}}{{path[2]}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/gitops-cookbook/gitops-cookbook-sc.git
        targetRevision: main
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{path.basename}}'
EOF
```

<br/>

```
$ argocd app list
NAME                CLUSTER                         NAMESPACE  PROJECT  STATUS     HEALTH   SYNCPOLICY  CONDITIONS  REPO                                                       PATH                  TARGET
argocd/ch08prod     https://kubernetes.default.svc  prod       default  OutOfSync  Missing  Manual      <none>      https://github.com/gitops-cookbook/gitops-cookbook-sc.git  ch08/bgd-gen/prod     main
argocd/ch08staging  https://kubernetes.default.svc  staging    default  OutOfSync  Missing  Manual      <none>      https://github.com/gitops-cookbook/gitops-cookbook-sc.git  ch08/bgd-gen/staging  main
```

<br/>

```
$ kubectl get ApplicationSet -n argocd
NAME             AGE
cluster-addons   4m20s
```

<br/>

```
// Удаляем ранее созданный ApplicationSet
$ kubectl delete ApplicationSet cluster-addons -n argocd
```
