---
layout: page
title: Инсталляция ArgoCD с помощью Helm на Minikube
description: Инсталляция ArgoCD с помощью Helm на Minikube
keywords: devops, containers, kubernetes, ci-cd, argocd, setup, minikube, helm
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argocd/setup-argocd-using-helm/
---

# Инсталляция ArgoCD с помощью Helm на Minikube

<br/>

Делаю:  
2023.05.09

<br/>

### [Install HELM](/tools/containers/kubernetes/utils/helm/setup/)

### [Install Argo CD CLI](/tools/containers/kubernetes/utils/ci-cd/argo/argocd/setup/cli/)

<br/>

```
$ export PROFILE=${USER}-minikube
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo ${INGRESS_HOST}
```

<br/>

```
$ cd ~/tmp
$ vi argo/argocd-values.yaml
```

<br/>

**argo/argocd-values.yaml**

<br/>

```yaml
server:
  ingress:
    enabled: true
  extraArgs:
    - --insecure
installCRDs: false
```

<br/>

```
$ helm repo add argo \
    https://argoproj.github.io/argo-helm
```

<br/>

```
$ helm search repo argo/argo-cd
NAME        	CHART VERSION	APP VERSION	DESCRIPTION
argo/argo-cd	5.32.1       	v2.7.1     	A Helm chart for Argo CD, a declarative, GitOps...
```

<br/>

```
$ helm upgrade --install \
    argocd argo/argo-cd \
    --namespace argocd \
    --create-namespace \
    --set server.ingress.hosts="{argocd.$INGRESS_HOST.nip.io}" \
    --values argo/argocd-values.yaml \
    --wait
```

<br/>

```
// Можно добавить при желании версию
--version 2.8.0 \
```

<br/>

```
$ kubectl get ingress -n argocd
NAME            CLASS   HOSTS                        ADDRESS        PORTS   AGE
argocd-server   nginx   argocd.192.168.49.2.nip.io   192.168.49.2   80      8m25s
```

<!-- <br/>

```
// Если понадобится обновить
// $ helm upgrade argocd --set server.ingress.hosts="{argocd.$INGRESS_HOST.nip.io}" --namespace argocd argo/argo-cd
``` -->

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
$ argocd repo list
```

<br/>

```
$ ARGOCD_PASSWORD_NEW_PASSWORD=ABCDEFGH123
$ argocd account update-password \
    --current-password ${ARGOCD_PASSWORD} \
    --new-password ${ARGOCD_PASSWORD_NEW_PASSWORD}
$ ARGOCD_PASSWORD=${ARGOCD_PASSWORD_NEW_PASSWORD}
$ echo ${ARGOCD_PASSWORD}
```

<br/>

```
$ echo argocd.$INGRESS_HOST.nip.io
```

```
// OK!
http://argocd.192.168.49.2.nip.io
```
