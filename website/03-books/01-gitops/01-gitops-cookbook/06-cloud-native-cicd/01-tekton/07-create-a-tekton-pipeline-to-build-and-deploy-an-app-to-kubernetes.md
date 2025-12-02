---
layout: page
title: GitOps Cookbook - Cloud Native CI/CD - Tekton - Create a Tekton Pipeline to Build and Deploy an App to Kubernetes
description: Создать Pipeline для компиляции, упаковки и деплоя приложения с помощью tekton в kubernetes
keywords: books, gitops, cloud-native-cicd, tekton, Create a Tekton Pipeline to Build and Deploy an App to Kubernetes
permalink: /books/gitops/gitops-cookbook/cloud-native-cicd/tekton/create-a-tekton-pipeline-to-build-and-deploy-an-app-to-kubernetes/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 06. Cloud Native CI/CD: Tekton: 6.7 Create a Tekton Pipeline to Build and Deploy an App to Kubernetes

<br/>

Делаю:  
2025.12.02

<br/>

**Задача:**  
Создать Pipeline для компиляции, упаковки и деплоя приложения с помощью tekton в kubernetes

<br/>

Уже созданы на предыдущем шаге:

- Secret на hub.docker.com
- ServiceAccount
- Role
- RoleBinding

<br/>

```
// Удаляем созданные на прошлом шагу
$ kubectl delete svc tekton-greeter
$ kubectl delete deployment tekton-greeter
```

<br/>

## Пример 1

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

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: kubectl
spec:
  params:
    - name: SCRIPT
      description: The kubectl CLI arguments to run
      type: string
      default: "kubectl help"
  steps:
    - name: oc
      image: quay.io/openshift/origin-cli:latest
      script: |
        #!/usr/bin/env bash
        $(params.SCRIPT)
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: tekton-greeter-pipeline
spec:
  params:
    - name: GIT_REPO
      type: string
    - name: GIT_REF
      type: string
    - name : DESTINATION_IMAGE
      type: string
    - name : SCRIPT
      type: string
  tasks:
    - name: build-push-app
      taskRef:
        name: build-push-app
      params:
        - name: url
          value: "$(params.GIT_REPO)"
        - name: revision
          value: "$(params.GIT_REF)"
        - name: destinationImage
          value: "$(params.DESTINATION_IMAGE)"
      workspaces:
        - name: source
    - name: deploy-app
      taskRef:
        name: kubectl
      params:
        - name: SCRIPT
          value: "$(params.SCRIPT)"
      runAfter:
        - build-push-app
  workspaces:
    - name: source
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: tekton-greeter-pipeline-run-
spec:
  taskRunTemplate:
    serviceAccountName: tekton-deployer-sa
  params:
  - name: GIT_REPO
    value: https://github.com/gitops-cookbook/tekton-tutorial-greeter.git
  - name: GIT_REF
    value: "master"
  - name: DESTINATION_IMAGE
    value: webmakaka/tekton-greeter:latest
  - name: SCRIPT
    value: |
      kubectl create deploy tekton-greeter --image=webmakaka/tekton-greeter:latest
  pipelineRef:
    name: tekton-greeter-pipeline
  workspaces:
    - name: source
      emptyDir: {}
EOF
```

<br/>

```
$ tkn pipelinerun ls
NAME                                STARTED          DURATION   STATUS
tekton-greeter-pipeline-run-psl6s   2 minutes ago    1m59s      Succeeded
```

<br/>

```
$ tkn pipelinerun logs tekton-greeter-pipeline-run-psl6s -f
```

<br/>

```
$ kubectl get deploy
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
tekton-greeter   1/1     1            1           50s
```

<br/>

```
$ kubectl expose deploy/tekton-greeter --port 8080
$ kubectl port-forward svc/tekton-greeter 8080:8080
```

<br/>

```
$ curl localhost:8080
Meeow!! from Tekton 😺🚀⏎
```

<br/>

```
OK!
https://hub.docker.com/r/webmakaka/tekton-greeter
```

<br/>

## Пример 2 с использованием специально созданных task

<br/>

```
// Удаляем созданные на прошлом шагу
$ kubectl delete svc tekton-greeter
$ kubectl delete deployment tekton-greeter
```

<br/>

https://hub.tekton.dev

<br/>

```
$ tkn hub install task git-clone
$ tkn hub install task maven
$ tkn hub install task buildah
$ tkn hub install task kubernetes-actions
```

<br/>

```
$ kubectl get tasks
NAME                 AGE
buildah              66s
git-clone            82s
kubectl              18m
kubernetes-actions   62s
maven                70s
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-source-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

<br/>

```
$ kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
app-source-pvc   Bound    pvc-c675c620-2268-43a3-835d-8a99743edf69   1Gi        RWO            standard       5s
```

<br/>

```yaml
$ envsubst << 'EOF' | cat | kubectl create -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: tekton-greeter-pipeline-hub
spec:
  params:
  - default: https://github.com/gitops-cookbook/tekton-tutorial-greeter.git
    name: GIT_REPO
    type: string
  - default: master
    name: GIT_REF
    type: string
  - default: webmakaka/tekton-greeter:latest
    name: DESTINATION_IMAGE
    type: string
  - default: kubectl create deploy tekton-greeter --image=webmakaka/tekton-greeter:latest
    name: SCRIPT
    type: string
  - default: ./Dockerfile
    name: CONTEXT_DIR
    type: string
  - default: .
    name: IMAGE_DOCKERFILE
    type: string
  - default: .
    name: IMAGE_CONTEXT_DIR
    type: string
  tasks:
  - name: fetch-repo
    params:
    - name: url
      value: $(params.GIT_REPO)
    - name: revision
      value: $(params.GIT_REF)
    - name: deleteExisting
      value: "true"
    - name: verbose
      value: "true"
    taskRef:
      kind: Task
      name: git-clone
    workspaces:
    - name: output
      workspace: app-source
  - name: build-app
    params:
    - name: GOALS
      value:
      - -DskipTests
      - clean
      - package
    - name: CONTEXT_DIR
      value: $(params.CONTEXT_DIR)
    runAfter:
    - fetch-repo
    taskRef:
      kind: Task
      name: maven
    workspaces:
    - name: maven-settings
      workspace: maven-settings
    - name: source
      workspace: app-source
  - name: build-push-image
    params:
    - name: IMAGE
      value: $(params.DESTINATION_IMAGE)
    - name: DOCKERFILE
      value: $(params.IMAGE_DOCKERFILE)
    - name: CONTEXT
      value: $(params.IMAGE_CONTEXT_DIR)
    runAfter:
    - build-app
    taskRef:
      kind: Task
      name: buildah
    workspaces:
    - name: source
      workspace: app-source
  - name: deploy
    params:
    - name: script
      value: $(params.SCRIPT)
    runAfter:
    - build-push-image
    taskRef:
      kind: Task
      name: kubernetes-actions
  workspaces:
  - name: app-source
  - name: maven-settings
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: tekton-greeter-pipeline-hub-
spec:
  taskRunTemplate:
    serviceAccountName: tekton-deployer-sa
  params:
  - name: GIT_REPO
    value: https://github.com/gitops-cookbook/tekton-tutorial-greeter.git
  - name: GIT_REF
    value: "master"
  - name: DESTINATION_IMAGE
    value: webmakaka/tekton-greeter:latest
  - name: CONTEXT_DIR
    value: "quarkus"
  - name: IMAGE_DOCKERFILE
    value: "quarkus/Dockerfile"
  - name: IMAGE_CONTEXT_DIR
    value: "quarkus"
  - name: SCRIPT
    value: |
      kubectl create deploy tekton-greeter --image=webmakaka/tekton-greeter:latest
  pipelineRef:
    name: tekton-greeter-pipeline-hub
  workspaces:
  - name: app-source
    persistentVolumeClaim:
      claimName: app-source-pvc
  - emptyDir: {}
    name: maven-settings
EOF
```

<br/>

```
// Аналогичный запуск в командной строке
// OK!
$ tkn pipeline start tekton-greeter-pipeline-hub \
    --serviceaccount='tekton-deployer-sa' \
    --param GIT_REPO='https://github.com/gitops-cookbook/tekton-tutorial-greeter.git' \
    --param GIT_REF='master' \
    --param CONTEXT_DIR='quarkus' \
    --param DESTINATION_IMAGE=webmakaka/tekton-greeter:latest \
    --param IMAGE_DOCKERFILE='quarkus/Dockerfile' \
    --param IMAGE_CONTEXT_DIR='quarkus' \
    --param SCRIPT='kubectl create deploy tekton-greeter --image=webmakaka/tekton-greeter:latest' \
    --workspace name=app-source,claimName=app-source-pvc \
    --workspace name=maven-settings,emptyDir="" \
    --use-param-defaults \
    --showlog
```

<br/>

```
$ tkn pipelinerun ls
NAME                                    STARTED        DURATION   STATUS
tekton-greeter-pipeline-hub-run-42pdx   2 minutes ago    1m39s      Succeeded
```

<br/>

```
$ tkn pipelinerun logs tekton-greeter-pipeline-hub-run-42pdx -f
```

<br/>

```
$ kubectl get deploy
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
tekton-greeter   1/1     1            1           73
```

<br/>

```
$ kubectl expose deploy/tekton-greeter --port 8080
$ kubectl port-forward svc/tekton-greeter 8080:8080
```

<br/>

```
$ curl localhost:8080
Meeow!! from Tekton 😺🚀⏎
```

<br/>

**Посмотреть результаты в UI**

```
$ kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 8080:9097
```

<br/>

```
$ localhost:8080 -> PipelineRuns
```
