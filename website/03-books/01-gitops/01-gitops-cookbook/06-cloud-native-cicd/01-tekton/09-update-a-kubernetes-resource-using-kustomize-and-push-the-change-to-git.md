---
layout: page
title: GitOps Cookbook - Cloud Native CI/CD - Tekton - Update a Kubernetes Resource Using Kustomize and Push the Change to Git
description: GitOps Cookbook - Cloud Native CI/CD - Tekton - Update a Kubernetes Resource Using Kustomize and Push the Change to Git
keywords: books, gitops, cloud-native-cicd, tekton, Update a Kubernetes Resource Using Kustomize and Push the Change to Git
permalink: /books/gitops/gitops-cookbook/cloud-native-cicd/tekton/update-a-kubernetes-resource-using-kustomize-and-push-the-change-to-git/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 06. Cloud Native CI/CD: Tekton: 6.9 Update a Kubernetes Resource Using Kustomize and Push the Change to Git

<br/>

Делаю:  
2025.12.03

<br/>

**Задача:**
Запуск Tekton Pipelines для компиляции, упаковки, деплоя приложения и обновления kustomize манифестов с помощью в kubernetes

<br/>

**Форкаю**:  
https://github.com/gitops-cookbook/pacman-kikd.git

<br/>

В Dockerfile прописываю:

```
# COPY target/*-runner.jar /deployments/
COPY target/pacman-kikd-*.jar /deployments/
```

<br/>

В .dockerignore

```
!target/pacman-kikd-*.jar
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  annotations:
    tekton.dev/pipelines.minVersion: 0.12.1
    tekton.dev/tags: git
  name: git-update-deployment
  labels:
    app.kubernetes.io/version: '0.2'
    operator.tekton.dev/provider-type: community
spec:
  description: >-
    This Task can be used to update image digest in a Git repo using kustomize.
    It requires a secret with credentials for accessing the git repo.
  params:
    - name: GIT_REPOSITORY
      type: string
    - name: GIT_REF
      type: string
    - name: NEW_IMAGE
      type: string
    - name: NEW_DIGEST
      type: string
    - name: KUSTOMIZATION_PATH
      type: string
  results:
    - description: The commit SHA
      name: commit
  steps:

    - name: git-clone
      image: 'docker.io/alpine/git:v2.26.2'
      script: |
        rm -rf git-update-digest-workdir
        git clone $(params.GIT_REPOSITORY) -b $(params.GIT_REF) --depth 1 --single-branch --no-tags git-update-digest-workdir
      workingDir: $(workspaces.workspace.path)

    - name: update-digest
      image: 'quay.io/wpernath/kustomize-ubi:latest'
      script: |
        cd git-update-digest-workdir/$(params.KUSTOMIZATION_PATH)
        kustomize edit set image $(params.NEW_IMAGE)@$(params.NEW_DIGEST)
        echo "##########################"
        echo "### kustomization.yaml ###"
        echo "##########################"
        cat kustomization.yaml
      workingDir: $(workspaces.workspace.path)

    - name: git-commit
      image: 'docker.io/alpine/git:v2.26.2'
      script: |
        cd git-update-digest-workdir
        git config user.email "tektonbot@redhat.com"
        git config user.name "My Tekton Bot"
        git status
        git add $(params.KUSTOMIZATION_PATH)/kustomization.yaml
        git commit -m "[ci] Image digest updated"
        git push
        RESULT_SHA="$(git rev-parse HEAD | tr -d '\n')"
        EXIT_CODE="$?"
        if [ "$EXIT_CODE" != 0 ]
        then
        exit $EXIT_CODE
        fi
        # Make sure we don't add a trailing newline to the result!
        echo -n "$RESULT_SHA" > $(results.commit.path)
      workingDir: $(workspaces.workspace.path)

  workspaces:
  - description: The workspace consisting of maven project.
    name: workspace
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: pacman-pipeline
spec:
  params:
    - default: https://github.com/gitops-cookbook/pacman-kikd.git
      name: GIT_REPO
      type: string
    - default: master
      name: GIT_REVISION
      type: string
    - default: webmakaka/pacman-kikd:latest
      name: DESTINATION_IMAGE
      type: string
    - default: .
      name: CONTEXT_DIR
      type: string
    - default: 'https://github.com/gitops-cookbook/pacman-kikd-manifests.git'
      name: CONFIG_GIT_REPO
      type: string
    - default: main
      name: CONFIG_GIT_REVISION
      type: string
  tasks:

    - name: fetch-repo
      params:
      - name: url
        value: $(params.GIT_REPO)
      - name: revision
        value: $(params.GIT_REVISION)
      - name: deleteExisting
        value: "true"
      taskRef:
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
        value: "$(params.CONTEXT_DIR)"
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
        value: "$(params.DESTINATION_IMAGE)"
      runAfter:
      - build-app
      taskRef:
        kind: Task
        name: buildah
      workspaces:
      - name: source
        workspace: app-source

    - name: git-update-deployment
      params:
        - name: GIT_REPOSITORY
          value: $(params.CONFIG_GIT_REPO)
        - name: NEW_IMAGE
          value: $(params.DESTINATION_IMAGE)
        - name: NEW_DIGEST
          value: $(tasks.build-push-image.results.IMAGE_DIGEST)
        - name: KUSTOMIZATION_PATH
          value: env/dev
        - name: GIT_REF
          value: $(params.CONFIG_GIT_REVISION)
      runAfter:
        - build-push-image
      taskRef:
        kind: Task
        name: git-update-deployment
      workspaces:
        - name: workspace
          workspace: app-source
  workspaces:
    - name: app-source
    - name: maven-settings
EOF
```

<br/>

```
// Если нужно удалить
// $ kubectl delete pipeline pacman-pipeline
```

<br/>

// Ранее создавали

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
  name: github-secret
  annotations:
    tekton.dev/git-0: https://github.com
type: kubernetes.io/basic-auth
stringData:
  username: YOUR_USERNAME
  password: YOUR_PASSWORD
EOF
```

<br/>

```
YOUR_USERNAME - github username
YOUR_PASSWORD - GitHub personal access token
```

<br/>

// Ранее создавали

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-bot-sa
secrets:
  - name: github-secret
EOF
```

<br/>

```
$ kubectl patch serviceaccount tekton-bot-sa -p '{"secrets": [{"name": "git-secret"}]}'
$ kubectl patch serviceaccount tekton-bot-sa -p '{"secrets": [{"name": "container-registry-secret"}]}'
```

<br/>

```
+ ранее созавали PVC для Pipeline
```

<br/>

```
$ tkn pipeline start pacman-pipeline \
  --serviceaccount='tekton-bot-sa' \
  --param GIT_REPO='https://github.com/wildmakaka/pacman-kikd.git' \
  --param GIT_REVISION='main' \
  --param DESTINATION_IMAGE='webmakaka/pacman-kikd:latest' \
  --param CONFIG_GIT_REPO='https://github.com/wildmakaka/pacman-kikd-manifests.git' \
  --param CONFIG_GIT_REVISION='main' \
  --workspace name=app-source,claimName=app-source-pvc \
  --workspace name=maven-settings,emptyDir="" \
  --use-param-defaults \
  --showlog
```

<br/>

```
[build-push-image : build-and-push] Error: building at STEP "COPY target/*-runner.jar /deployments/": checking on sources under "/workspace/source": Rel: can't make  relative to /workspace/source; copier: stat: ["/target/*-runner.jar"]: no such file or directory
```

<br/>

### Проверяю содержимое PVC

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: pvc-inspector
spec:
  volumes:
    - name: pvc-volume
      persistentVolumeClaim:
        claimName: app-source-pvc
  containers:
    - name: inspector
      image: alpine:latest
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: pvc-volume
          mountPath: /mnt/pvc
EOF
```

<br/>

```
$ kubectl exec -it pvc-inspector -- sh
```

<br/>

```
# cd /mnt/pvc/target/
# ls
classes                      pacman-kikd-1.0.0.jar
kubernetes                   quarkus-app
maven-archiver               quarkus-artifact.properties
```

<br/>

```
$ kubectl delete pod pvc-inspector --force
```

<br/>

**Новая ошибка:**

```
Error: pushing image "webmakaka/pacman-kikd:latest" to "docker://webmakaka/pacman-kikd:latest": trying to reuse blob sha256:cb973d48271cfb4bad03e3ef5f9e1513164b6aff04e4180207657d5aa2b3cd6b at destination: checking whether a blob sha256:cb973d48271cfb4bad03e3ef5f9e1513164b6aff04e4180207657d5aa2b3cd6b exists in docker.io/webmakaka/pacman-kikd: requested access to the resource is denied
```

<br/>

**Новая ошибка:**

```
[git-update-deployment : git-clone] failed to create fsnotify watcher: too many open files

[git-update-deployment : update-digest] failed to create fsnotify watcher: too many open files

[git-update-deployment : git-commit] failed to create fsnotify watcher: too many open files
```

<br/>

**На хосте с ubuntu, на которой запускаю с помощью kind kubernetes:**

```
// Помогло!
// После перезагрузки сбрасываеются

$ sysctl fs.inotify.max_user_instances
fs.inotify.max_user_instances = 128

$ sysctl fs.inotify.max_user_watches
fs.inotify.max_user_watches = 65536

$ sudo sysctl fs.inotify.max_user_instances=8192
$ sudo sysctl fs.inotify.max_user_watches=524288
```

<br/>

Запускаю pipeline

```
[git-update-deployment : git-clone] Cloning into 'git-update-digest-workdir'...

[git-update-deployment : update-digest] ##########################
[git-update-deployment : update-digest] ### kustomization.yaml ###
[git-update-deployment : update-digest] ##########################
[git-update-deployment : update-digest] apiVersion: kustomize.config.k8s.io/v1beta1
[git-update-deployment : update-digest] kind: Kustomization
[git-update-deployment : update-digest] resources:
[git-update-deployment : update-digest] - ../../k8s/
[git-update-deployment : update-digest] images:
[git-update-deployment : update-digest] - digest: sha256:850c93d86123e1f284fd81d564c21aa6fa8355f95ff29baec0150dc43cc2372c
[git-update-deployment : update-digest]   name: webmakaka/pacman-kikd
[git-update-deployment : update-digest]   newTag: latest

[git-update-deployment : git-commit] On branch main
[git-update-deployment : git-commit] Your branch is up to date with 'origin/main'.
[git-update-deployment : git-commit]
[git-update-deployment : git-commit] Changes not staged for commit:
[git-update-deployment : git-commit]   (use "git add <file>..." to update what will be committed)
[git-update-deployment : git-commit]   (use "git restore <file>..." to discard changes in working directory)
[git-update-deployment : git-commit] 	modified:   env/dev/kustomization.yaml
[git-update-deployment : git-commit]
[git-update-deployment : git-commit] no changes added to commit (use "git add" and/or "git commit -a")
[git-update-deployment : git-commit] [main 9c50c1f] [ci] Image digest updated
[git-update-deployment : git-commit]  1 file changed, 1 insertion(+), 1 deletion(-)
[git-update-deployment : git-commit] To https://github.com/wildmakaka/pacman-kikd-manifests.git
[git-update-deployment : git-commit]    5b1a2a4..9c50c1f  main -> main
```

<br/>

В репо обновился файл  
https://github.com/wildmakaka/pacman-kikd-manifests/blob/main/env/dev/kustomization.yaml
