---
layout: page
title: GitOps Cookbook - Cloud Native CI/CD - Tekton - Containerize an Application Using a Tekton Task and Buildah
description: GitOps Cookbook - Cloud Native CI/CD - Tekton - Containerize an Application Using a Tekton Task and Buildah
keywords: books, gitops, cloud-native-cicd, tekton, Containerize an Application Using a Tekton Task and Buildah
permalink: /books/gitops/gitops-cookbook/cloud-native-cicd/tekton/containerize-an-application-using-a-tekton-task-and-buildah/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 06. Cloud Native CI/CD: Tekton: 6.5 Containerize an Application Using a Tekton Task and Buildah

<br/>

Собираем и отправляем docker image в registry

<br/>

Делаю:  
2024.03.08

<br/>

```
$ docker login

***
Login Succeeded
```

<br/>

```
REGISTRY_USER= <your own docker login>
REGISTRY_PASSWORD= <your own docker password>
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
apiVersion: tekton.dev/v1beta1
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
      resources: {}
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

```
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
[build-sources] [INFO] ------------------------------------------------------------------------
[build-sources] [INFO] BUILD SUCCESS
[build-sources] [INFO] ------------------------------------------------------------------------
[build-sources] [INFO] Total time:  44.860 s
[build-sources] [INFO] Finished at: 2024-03-08T11:14:16Z
[build-sources] [INFO] ------------------------------------------------------------------------

[build-and-push-image] STEP 1/2: FROM registry.access.redhat.com/ubi8/openjdk-11
[build-and-push-image] Trying to pull registry.access.redhat.com/ubi8/openjdk-11:latest...
[build-and-push-image] Getting image source signatures
[build-and-push-image] Checking if image destination supports signatures
[build-and-push-image] Copying blob sha256:0bb48edf8994fcf133c612f92171d68f572091fb0b1113715eab5f3e5e7f54e5
[build-and-push-image] Copying blob sha256:74e0c06e5eac269967e6970582b9b25168177df26dffed37ccde09369302a87a
[build-and-push-image] Copying config sha256:a6b53e10c7678edc1d2e8090ed0a0b40d147f8e110ac2277931828ef11276f96
[build-and-push-image] Writing manifest to image destination
[build-and-push-image] Storing signatures
[build-and-push-image] STEP 2/2: COPY target/quarkus-app /deployments/
[build-and-push-image] COMMIT webmakaka/tekton-greeter:latest
[build-and-push-image] --> 8c78b1bd65c9
[build-and-push-image] Successfully tagged localhost/webmakaka/tekton-greeter:latest
[build-and-push-image] 8c78b1bd65c9c547a574e12c5e57344740915dced67ca6b1e11117c04250273a
[build-and-push-image] Getting image source signatures
[build-and-push-image] Copying blob sha256:00a9cea1d198bc0374806979feb9b0ec58e2d38b036ecb4e522f21b953b987de
[build-and-push-image] Copying blob sha256:6344c4480048e2ab532a9015ac326b4b24ed43b1fed6756848b81b40a49075d9
[build-and-push-image] Copying blob sha256:f61c43e793f68bde6557f1f0662ea7c8c9078c66a1b69840d48b14a6ea79d724
[build-and-push-image] Copying config sha256:8c78b1bd65c9c547a574e12c5e57344740915dced67ca6b1e11117c04250273a
[build-and-push-image] Writing manifest to image destination
```

<br/>

```
OK!
https://hub.docker.com/r/webmakaka/tekton-greeter
```
