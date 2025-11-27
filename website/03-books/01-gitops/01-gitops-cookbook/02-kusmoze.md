---
layout: page
title: GitOps Cookbook - Kustomize
description: GitOps Cookbook - Kustomize
keywords: GitOps Cookbook, Kustomize
permalink: /books/gitops/gitops-cookbook/kustomize/
---

<br/>

# [Book] GitOps Cookbook: 04. Kustomize

<br/>

**Делаю:**  
2025.11.26

<br/>

**Репо проекта:**  
https://github.com/gitops-cookbook/pacman-kikd-manifests

<br/>

```
$ cd ~/tmp/
$ git clone git@github.com:gitops-cookbook/pacman-kikd-manifests.git
```

<br/>

### 4.1 Using Kustomize to Deploy Kubernetes Resources

<br/>

**Задача:**  
Вы хотите задеплоить сразу несколько kubernetes русурсов одной командой.

<br/>

```
$ cd ~/tmp/pacman-kikd-manifests/k8s/
```

<br/>

```
// Prints the result of the kustomization run, without sending the result to the
cluster
$ kubectl apply --dry-run=client -o yaml -k ./

или

$ kustomize build .
```

<br/>

### 4.2 Updating the Container Image in Kustomize

<br/>

**Задача:**  
Вы хотите с помощью kustomize, обновить в deployment container image

<br/>

```
$ cd ~/tmp/pacman-kikd-manifests/k8s/
```

<br/>

```
$ kustomize build . | grep image:
image: quay.io/gitops-cookbook/pacman-kikd:1.0.0
```

<br/>

```yaml
$ cat > ./kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- pacman-deployment.yaml
- pacman-namespace.yaml
- pacman-service.yaml

images:
- name: quay.io/gitops-cookbook/pacman-kikd
  newTag: 1.0.1
EOF
```

<br/>

```
// Поменялся tag
// При этом, если поменять image name, то не поменяется
$ kustomize build . | grep image:
image: quay.io/gitops-cookbook/pacman-kikd:1.0.1
```

<br/>

### 4.3 Updating Any Kubernetes Field in Kustomize

<br/>

**Задача:**  
Вы хотите с помощью kustomize обновить поле с количеством реплик

<br/>

```
$ kubectl apply --dry-run=client -o yaml -k ./ | grep replicas
replicas: 1
```

<br/>

```yaml
$ cat > ./kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- pacman-deployment.yaml
replicas:
- name: pacman-kikd
  count: 3
EOF
```

<br/>

```
$ kubectl apply --dry-run=client -o yaml -k ./ | grep replicas
replicas: 3
```

<br/>

```yaml
$ cat > ./kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- pacman-deployment.yaml
patches:
  - target:
      version: v1
      group: apps
      kind: Deployment
      name: pacman-kikd
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
EOF
```

<br/>

```
$ kubectl apply --dry-run=client -o yaml -k ./ | grep replicas
replicas: 3
```

<br/>

### 4.4 Deploying to Multiple Environments

<br/>

**Задача:**  
Вы хотите с помощью kustomize задеплоить приложение в разные namespace

<br/>

```
$ mkdir base
$ mv * ./base/
```

<br/>

```
$ mkdir staging
$ mkdir production
```

<br/>

```yaml
$ cat > ./staging/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
namespace: staging
images:
- name: quay.io/gitops-cookbook/pacman-kikd
  newTag: 1.2.0-beta
EOF
```

<br/>

```yaml
$ cat > ./production/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
namespace: prod
images:
- name: quay.io/gitops-cookbook/pacman-kikd
  newTag: 1.1.0
EOF
```

<br/>

```
$ kubectl apply --dry-run=client -o yaml -k ./staging
$ kubectl apply --dry-run=client -o yaml -k ./production
```

<br/>

### 4.5 Generating ConfigMaps in Kustomize

<br/>

**Задача:**  
Вы хотите с помощью kustomize задеплоить приложение в разные namespace

<br/>

```
pacman-deployment.yaml
```

<br/>

Добавляю

```yaml
volumes:
  - name: config
    configMap:
      name: pacman-configmap
```

<br/>

```yaml
$ cat > ./staging/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
namespace: staging
configMapGenerator:
- name: pacman-configmap
  literals:
  - db-timeout=2000
  - db-username=Ada
EOF
```

<br/>

```
$ kubectl apply --dry-run=client -o yaml -k ./staging
```

<br/>

Имя configmap создалось с хешем.
При выполнении еще и обновиться должно из-за изменений в deployment.

<br/>

**Пример с заменой свойства**

<br/>

```yaml
$ cat > ./production/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../staging
namespace: prod
configMapGenerator:
- name: pacman-configmap
  behavior: merge
  literals:
  - db-username=Alexandra
EOF
```

<br/>

```
$ kubectl apply --dry-run=client -o yaml -k ./production
```

<br/>

**Пример с добавлением свойств из файла**

<br/>

```yaml
$ cat > ./production/connection.properties << EOF
db-url=prod:4321/db
db-username=ada
EOF
```

<br/>

```yaml
$ cat > ./production/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../staging
namespace: prod
configMapGenerator:
- name: pacman-configmap
  behavior: replace
  files:
  - ./connection.properties
EOF
```

<br/>

```
$ kubectl apply --dry-run=client -o yaml -k ./production
```
