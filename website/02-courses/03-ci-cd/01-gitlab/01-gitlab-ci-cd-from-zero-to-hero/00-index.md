---
layout: page
title: TechWorld with Nana - GitLab CI/CD
description: TechWorld with Nana - GitLab CI/CD
keywords: Видеокурсы по DevOps, TechWorld with Nana, GitLab CI/CD
permalink: /courses/ci-cd/gitlab/gitlab-ci-cd-from-zero-to-hero/
---

# [Video Course][TechWorld with Nana] GitLab CI/CD - From Zero To Hero [ENG, 2025]

<br/>

<div align="center">
    <iframe width="853" height="480" src="https://www.youtube.com/embed/F7WMRXLUQRM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

<br/>

### [Инсталляция и подготовка minikube для работы в ubuntu 22.04](//docs.k8s.ru/tools/containers/kubernetes/minikube/setup/)

<br/>

### [Запуск и останов minikube в ubuntu 22.04](//docs.k8s.ru/tools/containers/kubernetes/minikube/run/)

<br/>

### [Инсталляция локальной версии gitlab в minikube](//docs.gitops.ru/tools/gitops/ci-cd/gitlab/setup/helm/minikube/)

<br/>

**Starting from chapter 2:**

Simple demo Node.js project:
https://gitlab.com/nanuchi/mynodeapp-cicd-project.git

<br/>

### Starting from chapter 7 (Microservices):

Microservice mono-repo:  
https://gitlab.com/nanuchi/mymicroservice-cicd

Microservice poly-repo:  
https://gitlab.com/mymicroservice-cicd

CI-templates (in the poly-repo group):  
https://gitlab.com/mymicroservice-cicd/ci-templates

<br/>

## Выполнение примеров из курса:

<br/>

## 05 Build Docker Image & Push

**5.3 Build Docker Image & Push to Private Registry**

<br/>

Замена docker на kaniko

<br/>

Создал переменную окружения $DOCKER_PASSWORD

<br/>

```yaml
build_and_push:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: ['']
  script:
    # Создаем конфиг с логином и паролем
    - mkdir -p /kaniko/.docker
    - echo "{\"auths\":{\"https://index.docker.io/v1/\":{\"username\":\"webmakaka\",\"password\":\"$DOCKER_PASSWORD\"}}}" > /kaniko/.docker//config.json

    - |
      /kaniko/executor \
        --context . \
        --destination index.docker.io/webmakaka/mynodeapp-cicd-project:1.0
```

<br/>

## 08. Deploy to K8s

<br/>

**Делаю:**  
2026.01.11

https://gitlab.com/mymicroservice-cicd/frontend

<br/>

### Create gitlab user and permissions

<br/>

```
// create namespace
$ kubectl create namespace my-micro-service
```

<br/>

```
// create Service Account
$ kubectl create serviceaccount cicd-sa --namespace=my-micro-service
```

<br/>

```yaml
$ kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cicd-sa-token
  namespace: my-micro-service
  annotations:
    kubernetes.io/service-account.name: cicd-sa
type: kubernetes.io/service-account-token
EOF
```

<br/>

```
$ kubectl describe serviceaccount cicd-sa --namespace=my-micro-service
Name:                cicd-sa
Namespace:           my-micro-service
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              cicd-sa-token
Events:              <none>
```

<br/>

```
$ kubectl get secret --namespace=my-micro-service
NAME            TYPE                                  DATA   AGE
cicd-sa-token   kubernetes.io/service-account-token   3      107s
```

<br/>

```yaml
// create Role for GitLab CI/CD
$ kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: my-micro-service
  name: cicd-role
rules:
- apiGroups: [""] # indicates the core API group
  resources: ["pods", "services", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["extensions", "apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF
```

<br/>

```
// assign cicd role to SA
$ kubectl create rolebinding cicd-sa-rb \
  --role=cicd-role \
  --serviceaccount=my-micro-service:cicd-sa \
  --namespace=my-micro-service
```

<br/>

### Create kubeconfig for cicd service account

<br/>

```
$ cp ~/.kube/config ~/.kube/config_admin
```

<br/>

```
// 1. Получаем токен из созданного секрета
$ TOKEN=$(kubectl get secret cicd-sa-token -n my-micro-service -o jsonpath='{.data.token}' | base64 --decode)

// 2. Получаем CA сертификат кластера
$ CA=$(kubectl get secret cicd-sa-token -n my-micro-service -o jsonpath='{.data.ca\.crt}')

// 3. Получаем адрес API-сервера
$ SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
```

<br/>

```yaml
cat <<EOF > kubeconfig-cicd.yaml
apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    certificate-authority-data: $CA
    server: $SERVER
contexts:
- name: cicd-context
  context:
    cluster: kubernetes
    namespace: my-micro-service
    user: cicd-sa
current-context: cicd-context
users:
- name: cicd-sa
  user:
    token: $TOKEN
EOF
```

<br/>

```
$ cp kubeconfig-cicd.yaml config
```

<br/>

```
$ kubectl get namespace
$ kubectl get pod -n kube-system
```

<br/>

Gitlab

```
Создаю группу: microservice-cicd

Settings -> CI/CD

Variables -> Add ->

Type: File

Visible: Visible

Flags: Protect variable

Key: KUBE_CONFIG
```

<br/>

**Форкаю:**

```
https://gitlab.com/mymicroservice-cicd/frontend.git
https://gitlab.com/mymicroservice-cicd/ci-templates.git
https://gitlab.com/mymicroservice-cicd/products.git
https://gitlab.com/mymicroservice-cicd/shopping-cart.git
```

<br/>

Создал переменную окружения $DOCKER_PASSWORD

<br/>

**Ci Templates / build.yml**

<br/>

```yaml
build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: ['']
  before_script:
    - export IMAGE_NAME=microservice-$MICRO_SERVICE
    - export IMAGE_TAG=$SERVICE_VERSION
  script:
    # Создаем конфиг с логином и паролем
    - mkdir -p /kaniko/.docker
    - echo "{\"auths\":{\"https://index.docker.io/v1/\":{\"username\":\"webmakaka\",\"password\":\"$DOCKER_PASSWORD\"}}}" > /kaniko/.docker//config.json

    - |
      /kaniko/executor \
        --context . \
        --destination index.docker.io/webmakaka/$IMAGE_NAME:$IMAGE_TAG
```

<br/>

**Ci Templates / deploy-k8s.yml **

<br/>

```yaml
deploy:
  stage: deploy
  image:
    name: alpine/kubectl:latest

  before_script:
    - export IMAGE_NAME=webmakaka/microservice-$MICRO_SERVICE
    - export IMAGE_TAG=$SERVICE_VERSION
    - export MICRO_SERVICE=$MICRO_SERVICE
    - export SERVICE_PORT=$SERVICE_PORT
    - export REPLICAS=$REPLICAS
    - export KUBECONFIG=$KUBE_CONFIG
  script:
    # Если вы используете alpine/kubectl, команда envsubst устанавливается через пакет gettext
    - apk add --no-cache gettext
    - envsubst < kubernetes/deployment.yaml | kubectl apply -f -
    - envsubst < kubernetes/service.yaml | kubectl apply -f -
```

<br/>

**Frontend / .gitlab-ci.yml**

<br/>

```yaml
include:
  - project: microservice-cicd/ci-templates
    ref: main
    file:
      - build.yml
      - deploy-k8s.yml

variables:
  MICRO_SERVICE: frontend
  SERVICE_VERSION: '1.3'
  SERVICE_PORT: 3000
  REPLICAS: 2

stages:
  - build
  - deploy
```

<br/>

```
$ kubectl expose service frontend \
  --type=NodePort \
  --name=frontend-nodeport \
  --port=3000 \
  --target-port=3000 \
  -n my-micro-service


$ kubectl get svc -n my-micro-service
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
frontend            ClusterIP   10.99.58.44      <none>        3000/TCP         16m
frontend-nodeport   NodePort    10.104.194.132   <none>        3000:32242/TCP   37s


// OK!
http://192.168.49.2.nip.io:32242/
```
