---
layout: page
title: FluxCD v2 With GitOps Toolkit - Kubernetes Deployment And Sync Mechanism
description: FluxCD v2 With GitOps Toolkit - Kubernetes Deployment And Sync Mechanism
keywords: linux, kubernetes, FluxCD
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-v2-with-gitops-toolkit/
---

# FluxCD v2 With GitOps Toolkit - Kubernetes Deployment And Sync Mechanism

<br/>

Делаю:  
06.11.2021

<br/>

<div align="center">
    <iframe width="853" height="480" src="https://www.youtube.com/embed/R6OeIgb7lUI" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

<br/>

### Не работает! Нужно обновить конфиги для ingress.

<br/>

https://www.youtube.com/watch?v=R6OeIgb7lUI

<br/>

**Original gist**
https://gist.github.com/vfarcic/0431989df4836eb82bdac0cc53c7f3d6

<br/>

### [Используется беслпатное облако Google](/tools/clouds/google/google-cloud-shell/setup/)

<br/>

1. Инсталляция [MiniKube](//docs.k8s.ru/tools/containers/kubernetes/minikube/setup/)

**Испольновалась версия KUBERNETES_VERSION=v1.22.2**

2. Инсталляция [Kubectl](//docs.k8s.ru/tools/containers/kubernetes/utils/kubectl/)

3. Инсталляция fluxcd

<br/>

```
// Инсталляция fluxcd
$ curl -s https://fluxcd.io/install.sh | sudo bash
```

<br/>

```
$ flux --version
flux version 0.21.1
```

<br/>

```
$ flux install
```

<br/>

```
$ flux check
► checking prerequisites
✔ Kubernetes 1.22.2 >=1.19.0-0
► checking controllers
✔ helm-controller: deployment ready
► ghcr.io/fluxcd/helm-controller:v0.12.1
✔ kustomize-controller: deployment ready
► ghcr.io/fluxcd/kustomize-controller:v0.16.0
✔ notification-controller: deployment ready
► ghcr.io/fluxcd/notification-controller:v0.18.1
✔ source-controller: deployment ready
► ghcr.io/fluxcd/source-controller:v0.17.2
✔ all checks passed
```

<br/>

4. [Инсталляция gh Linux и настройка работы с GitHub по SSH ключу](/github/setup/)

<br/>

```
#########
# Setup
#########
```

<br/>

// Страница генерации тогена  
https://github.com/settings/tokens

<br/>

```
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)

$ echo ${INGRESS_HOST}

$ export GITHUB_USER=<YOUR_GITHUB_USERNAME>

$ export GITHUB_TOKEN=<YOUR_GITHUB_TOKEN>
```

<br/>

```
##############################
# Creating environment repos
##############################
```

<br/>

**flux-production**

```
$ cd ~
$ mkdir -p flux-production/apps/
$ cd flux-production
$ git init

$ gh repo create --public flux-production -y

$ echo "# Production" | tee Readme.md
$ git add --all
$ git commit -m "Initial commit"
$ git push --set-upstream origin master
```

<br/>

**flux-staging**

```
$ cd ~
$ mkdir -p flux-staging/apps/
$ cd flux-staging
$ git init

$ gh repo create --public flux-staging -y

$ echo "# Staging" | tee Readme.md
$ git add --all
$ git commit -m "Initial commit"
$ git push --set-upstream origin master
```

<br/>

```
$ kubectl create namespace staging
$ kubectl create namespace production
```

<br/>

```
#################
# Bootstrapping`
#################
```

<br/>

```
$ cd ~
```

<br/>

```
// Создается приватный репо flux-fleet
$ flux bootstrap github \
    --owner $GITHUB_USER \
    --repository flux-fleet \
    --branch master \
    --path apps \
    --personal
```

<br/>

```
$ kubectl \
    --namespace flux-system \
    get pods
```

<br/>

```
NAME                                       READY   STATUS    RESTARTS   AGE
helm-controller-f7c5b6c56-cktfx            1/1     Running   0          96s
kustomize-controller-759b77975b-qhjnq      1/1     Running   0          96s
notification-controller-77f68bf8f4-n84k2   1/1     Running   0          96s
source-controller-8457664f8f-hfwb5         1/1     Running   0          96s

```

<br/>

```

$ cd ~

$ git clone git@github.com:${GITHUB_USER}/flux-fleet.git

$ cd flux-fleet

$ ls -1 apps

$ ls -1 apps/flux-system
```

<br/>

```
####################
# Creating sources`
####################
```

<br/>

```
$ flux create source git staging \
    --url https://github.com/${GITHUB_USER}/flux-staging \
    --branch master \
    --interval 30s \
    --export \
    | tee apps/staging.yaml
```

<br/>

```
$ flux create source git production \
    --url https://github.com/$GITHUB_USER/flux-production \
    --branch master \
    --interval 30s \
    --export \
    | tee apps/production.yaml
```

<br/>

```
$ flux create source git devops-toolkit \
    --url https://github.com/vfarcic/devops-toolkit \
    --branch master \
    --interval 30s \
    --export \
    | tee apps/devops-toolkit.yaml
```

<br/>

```
$ flux create kustomization staging \
    --source staging \
    --path "./" \
    --prune true \
    --interval 10m \
    --export \
    | tee -a apps/staging.yaml
```

<br/>

```
$ flux create kustomization production \
    --source production \
    --path "./" \
    --prune true \
    --interval 10m \
    --export \
    | tee -a apps/production.yaml
```

<br/>

```
$ git add --all

$ git commit -m "Added environments"

$ git push
```

<br/>

```
$ watch flux get sources git
$ watch flux get kustomizations
```

<br/>

```
###############################
# Deploying the first release
###############################
```

<br/>

```
$ cd ~/flux-staging
```

<br/>

```
$ echo "image:
    tag: 2.9.9
ingress:
    host: staging.devops-toolkit.${INGRESS_HOST}.nip.io" \
    | tee values.yaml
```

<br/>

```
$ flux create helmrelease \
 devops-toolkit-staging \
 --source GitRepository/devops-toolkit \
 --values values.yaml \
 --chart "helm" \
 --target-namespace staging \
 --interval 30s \
 --export \
 | tee apps/devops-toolkit.yaml
```

<br/>

```
$ rm values.yaml

$ git add --all

$ git commit -m "Initial commit"

$ git push
```

<br/>

```
$ watch flux get helmreleases
```

**Нужно подождать**

```
NAME READY MESSAGE
REVISION SUSPENDED
devops-toolkit-staging False HelmChart 'flux-system/flux-system-devops-toolkit-staging' is not ready False
```

<br/>

```
$ flux logs
2021-11-05T21:39:41.581Z error HelmRelease/devops-toolkit-staging.flux-system - Reconciler error Helm install failed: unable to build kubernetes objects from release manifest: unable to recognize &#34;&#34;: no matches for kind &#34;Ingress&#34; in version &#34;extensions/v1beta1&#34;
```

<br/>

```
$ kubectl \
    --namespace staging \
    get pods
```

<br/>

```
NAME READY STATUS RESTARTS AGE
staging-devops-toolkit-staging-devops-toolkit-76b88d8899-j9b8x 1/1 Running 0 3m5s
```

<br/>

```
##########################
# Deploying new releases
##########################
```

<br/>

```
$ cd ~/flux-staging/

$ cat apps/devops-toolkit.yaml \
 | sed -e "s@tag: 2.9.9@tag: 2.9.17@g" \
 | tee apps/devops-toolkit.yaml

$ git add --all

$ git commit -m "Upgrade to 2.9.17"

$ git push

$ watch kubectl --namespace staging \
 get pods

$ watch kubectl --namespace staging \
 get deployment staging-devops-toolkit-devops-toolkit \
 --output jsonpath="{.spec.template.spec.containers[0].image}"
```

<br/>

```
###########################
# Promoting to production
###########################
```

<br/>

```
$ cd ~/flux-production
```

<br/>

```
$ echo "image:
    tag: 2.9.17
ingress:
    host: devops-toolkit.$INGRESS_HOST.nip.io" \
    | tee values.yaml
```

<br/>

```
$ flux create helmrelease \
 devops-toolkit-production \
 --source GitRepository/devops-toolkit \
 --values values.yaml \
 --chart "helm" \
 --target-namespace production \
 --interval 30s \
 --export \
 | tee apps/devops-toolkit.yaml
```

<br/>

```
$ rm values.yaml

$ git add --all

$ git commit -m "Initial commit"

$ git push

$ watch flux get helmreleases

$ kubectl --namespace production \
 get pods
```

<br/>

```
#########################
# Destroying Everything
#########################
```

<br/>

```
$ minikube delete

$ cd ..

$ cd flux-fleet

$ gh repo view --web

$ # Delete the repo

$ cd ..

$ rm -rf flux-fleet

$ cd flux-staging

$ gh repo view --web

$ # Delete the repo

$ cd ..

$ rm -rf flux-staging

$ cd flux-production

$ gh repo view --web

# Delete the repo

$ cd ..

$ rm -rf flux-production
```
