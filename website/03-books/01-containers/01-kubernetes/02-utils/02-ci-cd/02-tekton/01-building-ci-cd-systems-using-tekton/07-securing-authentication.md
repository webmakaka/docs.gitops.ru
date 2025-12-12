---
layout: page
title: Building CI/CD Systems Using Tekton - Securing Authentication
description: Building CI/CD Systems Using Tekton - Securing Authentication
keywords: books, ci-cd, tekton, Securing Authentication
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/securing-authentication/
---

# Chapter 9. Securing Authentication

<br/>

Делаю:  
2025.12.11

<br/>

### Authenticating into a Git repository

<br/>

```
$ vi ~/tmp/task.yaml
```

<br/>

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: read-file
spec:
  params:
    - name: private-repo
      type: string
  steps:
    - name: clone
      image: alpine/git
      script: |
        mkdir /temp && cd /temp
        git clone $(params.private-repo) .
        cat README.md
```

<br/>

```
$ kubectl create -f ~/tmp/task.yaml
```

<br/>

### [OK!] Basic authentication

GitHub won't let you authenticate using your username and password directly. Instead, you will need to create a token that can then be used as your password. This token can be easily revoked if you accidentally publish it somewhere.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: git-basic-auth
  annotations:
    tekton.dev/git-0: https://github.com
type: kubernetes.io/basic-auth
stringData:
  username: wildmakaka
  password: ghp_token
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: git-auth-sa
secrets:
  - name: git-basic-auth
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: git-auth-
spec:
  serviceAccountName: git-auth-sa
  params:
    - name: private-repo
      value: https://github.com/wildmakaka/wildmakaka-tekton-greeter-private.git
  taskRef:
    name: read-file
EOF
```

<br/>

```
$ tkn taskrun logs git-auth-5p2bb
[clone] Cloning into '.'...
[clone] # Tekton Greeter
[clone]
[clone] Project used as part of [Tekton Tutorial](https://dn.dev/tekton-tutorial) execersies.
[clone]
[clone] The application has one simple REST api at URI `/` that says "Meeow from Tekton 😺 !! 🚀".
[clone]
[clone] ## Quarkus
[clone]
[clone] [Quarkus](./quarkus)

```

<br/>

### [OK!] SSH authentication

<br/>

```
// Получить приватный ключ
$ cat ~/.ssh/wildmakaka

// Получить данные для github.com ssh-rsa
$ ssh-keyscan github.com
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: git-ssh-auth
  annotations:
    tekton.dev/git-0: github.com
type: kubernetes.io/ssh-auth
stringData:
  ssh-privatekey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAACFwAAAAdzc2gtcn
    *****
    pdKLrkhN81cAAAAebWFybGV5LnJ1Ynkub24ucmFpbHNAZ21haWwuY29tAQIDBAU=
    -----END OPENSSH PRIVATE KEY-----
  known_hosts: github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt
    *****
  +EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: git-auth-sa
secrets:
  - name: git-ssh-auth
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: read-file
spec:
  params:
    - name: private-repo
      type: string
  steps:
    - name: clone
      image: alpine/git
      script: |
        # Проверить и создать директорию .ssh если её нет
        if [ ! -d /root/.ssh ]; then
          mkdir -p /root/.ssh
        fi

        # Установить правильные права доступа
        chmod 700 /root/.ssh

        # Скопировать SSH файлы с правильными правами
        if [ -f /tekton/creds-secrets/git-ssh-auth/ssh-privatekey ]; then
          cp /tekton/creds-secrets/git-ssh-auth/ssh-privatekey /root/.ssh/id_rsa
          chmod 600 /root/.ssh/id_rsa
        fi

        # Обновить known_hosts (перезаписать существующий)
        if [ -f /tekton/creds-secrets/git-ssh-auth/known_hosts ]; then
          cp /tekton/creds-secrets/git-ssh-auth/known_hosts /root/.ssh/known_hosts
          chmod 644 /root/.ssh/known_hosts
        fi

        # Клонировать репозиторий
        mkdir -p /temp && cd /temp
        git clone $(params.private-repo) .
        cat README.md
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: git-auth-
spec:
  serviceAccountName: git-auth-sa
  params:
    - name: private-repo
      value: git@github.com:wildmakaka/wildmakaka-tekton-greeter-private.git
  taskRef:
    name: read-file
EOF
```

<br/>

```
$ tkn taskrun logs -f git-auth-4qfcc
[clone] Cloning into '.'...
[clone] # Tekton Greeter
[clone]
[clone] Project used as part of [Tekton Tutorial](https://dn.dev/tekton-tutorial) execersies.
[clone]
[clone] The application has one simple REST api at URI `/` that says "Meeow from Tekton 😺 !! 🚀".
```

<br/>

### [OK!] Authenticating in a container registry

<br/>

```
$ {
    export REGISTRY_SERVER=https://index.docker.io/v1/
    export REGISTRY_USER=webmakaka
    export REGISTRY_PASSWORD=webmakaka-password
    export EMAIL=webmakaka-email@mail.ru

    echo ${REGISTRY_SERVER}
    echo ${REGISTRY_USER}
    echo ${REGISTRY_PASSWORD}
    echo ${EMAIL}
}
```

<br/>

```
// Создаем секрет с пародлями для hub.docker.com
$ kubectl create secret docker-registry registry-creds \
    --docker-server=${REGISTRY_SERVER} \
    --docker-username=${REGISTRY_USER} \
    --docker-password=${REGISTRY_PASSWORD} \
    --docker-email=${EMAIL}
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: authenticated
secrets:
  - name: registry-creds
imagePullSecrets:
  - name: registry-creds
EOF
```

<br/>

// Image должен быть private по задумке

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: private
spec:
  steps:
    - image: webmakaka/tekton-greeter
      command:
        - /bin/sh
        - -c
        - echo hello
EOF
```

<br/>

```
$ tkn task start private --showlog -s authenticated
[unnamed-0] hello
```
