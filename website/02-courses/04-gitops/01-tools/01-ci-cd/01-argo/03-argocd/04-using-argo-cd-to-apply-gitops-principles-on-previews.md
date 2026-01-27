---
layout: page
title: Kubernetes ArgoCD
description: Kubernetes ArgoCD
keywords: devops, contaiers, kubernetes, ci-cd, argocd
permalink: /courses/containers/kubernetes/ci-cd/argocd/argocd/using-argo-cd-to-apply-gitops-principles-on-previews/
---

# Kubernetes ArgoCD

### Environments Based On Pull Requests (PRs): Using Argo CD To Apply GitOps Principles On Previews

<br/>

Делаю:  
12.02.2021

<br/>

https://www.youtube.com/watch?v=cpAaI8p4R60

<br/>

**Original Gist**

https://gist.github.com/vfarcic/808108069f709572f1bc372c65f6b5c0

<br/>

```
// Инсталляция kyml
$ curl -Lo kyml https://github.com/frigus02/kyml/releases/download/v20190906/kyml_20190906_linux_amd64 && chmod +x kyml && sudo mv kyml /usr/local/bin/
```

<br/>

```
$ export INGRESS_HOST=$(minikube --profile my-profile ip)
$ echo ${INGRESS_HOST}
192.168.49.2
```

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/vfarcic/argocd-previews
$ cd argocd-previews/
```

```
$ cat preview.yaml

$ export PR_ID=1

$ export REPO=devops-toolkit

$ export APP_ID=pr-$REPO-$PR_ID

$ export IMAGE_TAG=2.6.2

$ export HOSTNAME=$APP_ID.$INGRESS_HOST.nip.io

$ cat preview.yaml \
    | kyml tmpl -e REPO -e APP_ID -e IMAGE_TAG -e HOSTNAME \
    | tee helm/templates/$APP_ID.yaml
```

<br/>

```
$ vi apps.yaml
```

Меняю Repo

```
repoURL:·https://github.com/vfarcic/argocd-previews.git
```

на свой.

<br/>

И создаю repo у себя на github.

<br/>

```
$ kubectl apply --filename project.yaml
$ kubectl apply --filename apps.yaml
```

<br/>

```
$ argocd app sync previews

$ kubectl get namespaces

$ kubectl --namespace $APP_ID \
    get pods

```

<br/>

Открылось по адресу:

http://pr-devops-toolkit-1.192.168.49.2.xip.io/

<br/>

```
$ export PR_ID=1

$ export REPO=devops-paradox

$ export APP_ID=pr-$REPO-$PR_ID

$ export IMAGE_TAG=1.71

$ export HOSTNAME=$APP_ID.$INGRESS_HOST.nip.io

$ cat preview.yaml \
    | kyml tmpl -e REPO -e APP_ID -e IMAGE_TAG -e HOSTNAME \
    | tee helm/templates/$APP_ID.yaml
```

<br/>

```
$ git add .

$ git commit -m "$APP_ID"

$ git push
```

<br/>

```
$ argocd app sync previews

$ kubectl --namespace $APP_ID \
    get pods
```

<br/>

Открыло по адресу:

http://pr-devops-paradox-1.192.168.49.2.xip.io/

<br/>

```
$ export PR_ID=2

$ export REPO=devops-toolkit

$ export APP_ID=pr-$REPO-$PR_ID

$ export IMAGE_TAG=2.9.9

$ export HOSTNAME=$APP_ID.$INGRESS_HOST.nip.io

$ cat preview.yaml \
    | kyml tmpl -e REPO -e APP_ID -e IMAGE_TAG -e HOSTNAME \
    | tee helm/templates/$APP_ID.yaml
```

<br/>

```
$ git add .

$ git commit -m "$APP_ID"

$ git push

$ argocd app sync previews
```

<br/>

http://pr-devops-toolkit-2.192.168.49.2.xip.io/

<br/>

```
$ rm helm/templates/pr-devops-toolkit-1.yaml

$ git add .

$ git commit -m "$APP_ID"

$ git push

```

<br/>

```
$ argocd app sync previews
```

<!--

```
$ watch 'kubectl --namespace production get deployment devops-toolkit-devops-toolkit \
--output jsonpath="{.spec.temlate.spec.containers[0].image}"'
```

-->
