---
layout: page
title: GitOps Cookbook - Cloud Native CI/CD - Tekton - Containerize an Application Using a Tekton Task and Buildah
description: Скомпилировать, упаковать и контейнеризовать приложение с помощью tekton в kubernetes
keywords: books, gitops, cloud-native-cicd, tekton, Containerize an Application Using a Tekton Task and Buildah
permalink: /books/gitops/gitops-cookbook/cloud-native-cicd/tekton/containerize-an-application-using-a-tekton-task-and-buildah/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 06. Cloud Native CI/CD: Tekton: 6.5 Containerize an Application Using a Tekton Task and Buildah

<br/>

**Задача:**  
Скомпилировать, упаковать и контейнеризовать приложение с помощью tekton в kubernetes

<br/>

Делаю:  
2025.12.02

<br/>

```
// Проверка возможности залогиниться
$ docker login -u webmakaka

***
Login Succeeded
```

<br/>

```
$ {
    export REGISTRY_SERVER=https://index.docker.io/v1/
    export REGISTRY_USER=webmakaka
    export REGISTRY_PASSWORD=webmakaka-password

    echo ${REGISTRY_SERVER}
    echo ${REGISTRY_USER}
    echo ${REGISTRY_PASSWORD}
}
```

<br/>

```
$ kubectl create secret docker-registry container-registry-secret \
    --docker-server=${REGISTRY_SERVER} \
    --docker-username=${REGISTRY_USER} \
    --docker-password=${REGISTRY_PASSWORD}
```

<br/>

```
$ kubectl get secrets

***
container-registry-secret
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-registry-sa
secrets:
  - name: container-registry-secret
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-push-app
spec:
  workspaces:
    - name: source
      description: The git repo will be cloned onto the volume backing this work space
  params:
    - name: contextDir
      description: the context dir within source
      default: quarkus
    - name: tlsVerify
      description: tls verify
      type: string
      default: "false"
    - name: url
      default: https://github.com/gitops-cookbook/tekton-tutorial-greeter.git
    - name: revision
      default: master
    - name: subdirectory
      default: ""
    - name: sslVerify
      description: defines if http.sslVerify should be set to true or false in the global git config
      type: string
      default: "false"
    - name: storageDriver
      type: string
      description: Storage driver
      default: vfs
    - name: destinationImage
      description: the fully qualified image name
      default: ""
  steps:
    - image: 'ghcr.io/tektoncd/github.com/tektoncd/pipeline/cmd/git-init:v0.29.0'
      name: clone
      script: |
          CHECKOUT_DIR="$(workspaces.source.path)/$(params.subdirectory)"
          cleandir() {
          # Delete any existing contents of the repo directory if it exists.
          #
          # We don't just "rm -rf $CHECKOUT_DIR" because $CHECKOUT_DIR might be "/"
          # or the root of a mounted volume.
          if [[ -d "$CHECKOUT_DIR" ]] ; then
          # Delete non-hidden files and directories
          rm -rf "$CHECKOUT_DIR"/*
          # Delete files and directories starting with . but excluding ..
          rm -rf "$CHECKOUT_DIR"/.[!.]*
          # Delete files and directories starting with .. plus any other character
          rm -rf "$CHECKOUT_DIR"/..?*
          fi
          }
          /ko-app/git-init \
          -url "$(params.url)" \
          -revision "$(params.revision)" \
          -path "$CHECKOUT_DIR" \
          -sslVerify="$(params.sslVerify)"
          cd "$CHECKOUT_DIR"
          RESULT_SHA="$(git rev-parse HEAD)"
    - name: build-sources
      image: gcr.io/cloud-builders/mvn
      command:
        - mvn
      args:
        - -DskipTests
        - clean
        - install
      env:
        - name: user.home
          value: /home/tekton
      workingDir: "/workspace/source/$(params.contextDir)"
    - name: build-and-push-image
      image: quay.io/buildah/stable
      script: |
          #!/usr/bin/env bash
          buildah --storage-driver=$STORAGE_DRIVER bud --layers -t $DESTINATION_IMAGE $CONTEXT_DIR
          buildah --storage-driver=$STORAGE_DRIVER push $DESTINATION_IMAGE docker://$DESTINATION_IMAGE
      env:
        - name: DESTINATION_IMAGE
          value: "$(params.destinationImage)"
        - name: CONTEXT_DIR
          value: "/workspace/source/$(params.contextDir)"
        - name: STORAGE_DRIVER
          value: "$(params.storageDriver)"
      workingDir: "/workspace/source/$(params.contextDir)"
      volumeMounts:
        - name: varlibc
          mountPath: /var/lib/containers
  volumes:
    - name: varlibc
      emptyDir: {}
EOF
```

<br/>

```
$ kubectl get tasks
NAME             AGE
***
build-push-app   36s
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: build-push-app-run-
  labels:
    app.kubernetes.io/managed-by: tekton-pipelines
    tekton.dev/task: build-push-app
spec:
  serviceAccountName: tekton-registry-sa
  params:
  - name: contextDir
    value: quarkus
  - name: subdirectory
    value: ""
  - name: tlsVerify
    value: "false"
  - name: url
    value: https://github.com/gitops-cookbook/tekton-tutorial-greeter.git
  - name: destinationImage
    value: webmakaka/tekton-greeter:latest
  taskRef:
    kind: Task
    name: build-push-app
  workspaces:
  - emptyDir: {}
    name: source
EOF
```

<br/>

```
$ tkn taskrun ls
```

<br/>

```
$ tkn taskrun logs build-push-app-run-87n76 -f
[build-and-push-image] Writing manifest to image destination
```

<br/>

```
// Аналогичный запуск в командной строке
// OK!
$ tkn task start build-push-app \
  --serviceaccount='tekton-registry-sa' \
  --param url='https://github.com/gitops-cookbook/tekton-tutorial-greeter.git' \
  --param destinationImage='webmakaka/tekton-greeter:latest' \
  --param contextDir='quarkus' \
  --workspace name=source,emptyDir="" \
  --use-param-defaults \
  --showlog
```

<br/>

```
// Появилась новая версия image
// OK!
https://hub.docker.com/r/webmakaka/tekton-greeter
```
