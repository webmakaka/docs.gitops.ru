---
layout: page
title: Building CI/CD Systems Using Tekton - Securing Authentication
description: Building CI/CD Systems Using Tekton - Securing Authentication
keywords: books, ci-cd, tekton, Securing Authentication
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/securing-authentication/
---

# Chapter 9. Securing Authentication

<br/>

Не тестировалось из-за лени.

<br/>

### Authenticating into a Git repository

<br/>

```
$ vi ~/tmp/task.yaml
```

<br/>

```yaml
apiVersion: tekton.dev/v1beta1
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

### Basic authentication

**Вроде уже отключили такую возможность!**

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
  username: joellord
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
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: git-auth-
spec:
  serviceAccountName: git-auth-sa
  params:
    - name: private-repo
      value: https://github.com/joellord/secret-repo.git
  taskRef:
    name: read-file
EOF
```

<br/>

```
$ tkn taskrun logs git-auth-kgp9l
```

<br/>

### SSH authentication

<br/>

```
$ cat ~/.ssh/id_rsa
$ cat ~/.ssh/known_hosts | grep github.com
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
    b3BlbnNzaC...
    NhAAAA...
    -----END OPENSSH PRIVATE KEY-----
  known_hosts: github.com,140.82.112.4 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
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
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
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
        cd /root && mkdir .ssh && cd .ssh
        cp ~/.ssh/* .
        mkdir /temp && cd /temp
        git clone $(params.private-repo) .
        cat README.md
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: git-auth-
spec:
  serviceAccountName: git-auth-sa
  params:
    - name: private-repo
      value: git@github.com:joellord/secret-repo
  taskRef:
    name: read-file
EOF
```

<br/>

```
$ tkn taskrun logs -f git-auth-grzw4
```

<br/>

### Authenticating in a container registry

```
$ kubectl create secret docker-registry registry-creds \
  --docker-server=<server> \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>
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

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: private
spec:
  steps:
    - image: joellord/private
      command:
        - /bin/sh
        - -c
        - echo hello
EOF
```

<br/>

```yaml
$ tkn task start private --showlog -s authenticated
```
