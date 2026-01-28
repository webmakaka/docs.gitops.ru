---
layout: page
title: Introduction to Argo CD Kubernetes DevOps CI CD
description: Introduction to Argo CD Kubernetes DevOps CI CD
keywords: devops, contaiers, kubernetes, ci-cd, argocd
permalink: /courses/containers/kubernetes/ci-cd/argocd/introduction-to-argo-cd-kubernetes-devops-ci-cd/deploying-a-sample-application/
---

# Introduction to Argo CD Kubernetes DevOps CI/CD

<br/>

Делаю:  
09.05.2023

<br/>

## 04 - Argo CD Deep Dive

<br/>

### 12 - Deploying a sample application to Argo CD

<br/>

```
// $ argocd repo add "https://gitlab.com/abohmeed/samplegitopsapp.git" --username " [your username]" --password "[your personal token]"
```

<br/>

```
$ kubectl create ns microservices-demo
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: microservices-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/GoogleCloudPlatform/microservices-demo.git'
    path: kustomize
    targetRevision: main
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: microservices-demo
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
EOF
```

<br/>

```
$ argocd app sync microservices-demo
```

<br/>

```
$ kubectl get svc,pod -o wide -n microservices-demo
```

<br/>

```
$ kubectl -n microservices-demo port-forward svc/frontend-external 31801:80
```

```
// OK!
http://localhost:31801/
```

<br/>

### 13 - Deploying Helm charts to Argo CD

<br/>

```
$ kubectl create ns helm-example
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: httpbin
  namespace: argocd
spec:
  project: default
  source:
    chart: httpbin
    repoURL: https://matheusfm.dev/charts
    targetRevision: 0.1.1
    helm:
      releaseName: httpbin
      values: |
        service:
          type: NodePort
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: helm-example
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
EOF
```

<br/>

```
$ kubectl get svc -n helm-example
NAME      TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
httpbin   NodePort   10.98.5.177   <none>        80:31473/TCP   8m46s
```

<br/>

```
$ helm create httpd
```

<br/>

```
# values.yaml
image:
  repository: httpd
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: latest
```

<br/>

```
$ helm package .
```

<br/>

Get the project ID from Gitlab by going to the project page and clicking on settings. Copy the ID.

<br/>

```
$ curl --request POST --form 'chart=@httpd-0.1.0.tgz' --user "[your username]:[your
token]" https://gitlab.com/api/v4/projects/[your project id]/packages/helm/api/stable/charts
```

<br/>

```
$ argocd repocreds add https://gitlab.com/api/v4/projects/[your project id]/packages/helm/stable --username [your username] --password [your personal token]
```

<br/>

```yaml
$ cat << EOF > busybox.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: httpd
  namespace: argocd
spec:
  project: default
  source:
    chart: httpd
    repoURL: https://gitlab.com/api/v4/projects/[project id]/packages/helm/stable
    targetRevision: 0.1.0
    helm:
      releaseName: httpd
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: helm-example2
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
EOF
```

<br/>

### 14 - Deploying applications to Argo CD using Kustomize

<br/>

### 15 - Managing Secrets in GitOps

<br/>

### [Установка kubeseal](//docs.k8s.ru/tools/containers/kubernetes/utils/security/bitnami-seal/)
