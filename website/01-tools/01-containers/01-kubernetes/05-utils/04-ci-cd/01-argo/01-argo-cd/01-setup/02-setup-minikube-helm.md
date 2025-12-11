---
layout: page
title: Инсталляция ArgoCD с помощью Helm на Minikube
description: Инсталляция ArgoCD с помощью Helm на Minikube
keywords: devops, containers, kubernetes, ci-cd, argocd, setup, minikube, helm
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argo-cd/setup/minikube/minikube/helm/
---

# Инсталляция ArgoCD с помощью Helm на Minikube

<br/>

Делаю:  
2025.12.10

<br/>

### [Install HELM](//docs.k8s.ru/tools/containers/kubernetes/utils/helm/setup/)

### [Install Argo CD CLI](/tools/containers/kubernetes/utils/ci-cd/argo/argo-cd/setup/minikube/cli/)

<br/>

```
$ export PROFILE=${USER}-minikube
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo argocd.$INGRESS_HOST.nip.io
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > argocd-values.yaml <<EOF
---
server:
  ingress:
    enabled: true
    hosts:
      - argocd.$INGRESS_HOST.nip.io
  extraArgs:
    - --insecure
installCRDs: false
EOF
```

<!-- <br/>

```yaml
$ cat > argocd-values.yaml <<EOF
---
server:
  ingress:
    enabled: true
  extraArgs:
    - --insecure
installCRDs: false
EOF
``` -->

<br/>

```
$ helm repo add argo \
    https://argoproj.github.io/argo-helm
```

<br/>

```
$ helm search repo argo/argo-cd
NAME        	CHART VERSION	APP VERSION	DESCRIPTION
argo/argo-cd	9.1.5        	v3.2.1     	A Helm chart for Argo CD, a declarative, GitOps...
```

<br/>

```
$ helm upgrade --install \
    argocd argo/argo-cd \
    --version 9.1.5 \
    --namespace argocd \
    --create-namespace \
    --set "server.ingress.hosts={argocd.$INGRESS_HOST.nip.io}" \
    --values argocd-values.yaml \
    --wait
```

<br/>

```
$ kubectl get ingress -n argocd
NAME            CLASS   HOSTS                        ADDRESS        PORTS   AGE
argocd-server   nginx   argocd.192.168.49.2.nip.io   192.168.49.2   80      75s
```

<br/>

```
// Патчим ingress, если что-то не то прописано
$ kubectl patch ingress argocd-server -n argocd --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/rules/0/host",
    "value": "argocd.'"$INGRESS_HOST"'.nip.io"
  }
]'
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
// admin / ABCDEFGH123
// OK!
http://argocd.192.168.58.2.nip.io
```

<br/>

```
$ argocd version
argocd: v3.2.1+8c4ab63
  BuildDate: 2025-11-30T12:12:42Z
  GitCommit: 8c4ab63a9c72b31d96c6360514cda6254e7e6629
  GitTreeState: clean
  GoVersion: go1.25.0
  Compiler: gc
  Platform: linux/amd64
argocd-server: v2.0.0+f5119c0
  BuildDate: 2021-04-07T06:00:33Z
  GitCommit: f5119c06686399134b3f296d44445bcdbc778d42
  GitTreeState: clean
  GoVersion: go1.16
  Compiler: gc
  Platform: linux/amd64
  Kustomize Version: v3.9.4 2021-02-09T19:22:10Z
  Helm Version: v3.5.1+g32c2223
  Kubectl Version: v0.20.4
  Jsonnet Version: v0.17.0
```

<br/>

```
// Uninstall
// $ helm uninstall argocd -n argocd
```
