---
layout: page
title: Building CI/CD Systems Using Tekton - Sharing Data with Workspaces
description: Building CI/CD Systems Using Tekton - Sharing Data with Workspaces
keywords: books, ci-cd, tekton, Sharing Data with Workspaces
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/sharing-data-with-workspaces/
---

# Chapter 7. Sharing Data with Workspaces

<br/>

Делаю:  
31.08.2023

<br/>

Workspaces are shared volumes used to transfer data between the various steps of a task.

<br/>

**Types of volume sources:**

- emptyDir
- ConfigMap
- Secret

<br/>

### Using your first workspace

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: clone-and-list
spec:
  params:
    - name: repo
      type: string
      description: Git repository to be cloned
      default: https://github.com/joellord/handson-tekton
  workspaces:
    - name: source
  steps:
    - name: clone
      image: alpine/git
      workingDir: $(workspaces.source.path)
      command:
        - /bin/sh
      args:
        - '-c'
        - git clone -v $(params.repo) ./source
    - name: list
      image: alpine
      workingDir: $(workspaces.source.path)
      command:
        - /bin/sh
      args:
        - "-c"
        - ls ./source
EOF
```

<br/>

```
$ tkn task start clone-and-list -w name=source,emptyDir="" --showlog
```

<br/>

```
TaskRun started: clone-and-list-run-6j24m
Waiting for logs to be available...
[clone] Cloning into './source'...
[clone] POST git-upload-pack (175 bytes)
[clone] POST git-upload-pack (667 bytes)

[list] README.md
[list] app
[list] demo
[list] installation

```

<br/>

### Using workspaces with task runs

<br/>

```
$ vi ~/tmp/clone-and-list-tr.yaml
```

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: git-clone-tr-
spec:
  workspaces:
    - name: source
      emptyDir: {}
  taskRef:
    name: clone-and-list
```

<br/>

```
$ kubectl create -f ~/tmp/clone-and-list-tr.yaml
```

<br/>

```
$ tkn taskrun logs git-clone-tr-c22wd
```

<br/>

```
[clone] Cloning into './source'...
[clone] POST git-upload-pack (175 bytes)
[clone] POST git-upload-pack (667 bytes)

[list] README.md
[list] app
[list] demo
[list] installation

```

<br/>

### Adding a workspace to a pipeline

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: clone
spec:
  params:
    - name: repo
      type: string
      description: Git repository to be cloned
      default: https://github.com/joellord/handson-tekton
  workspaces:
    - name: source
  steps:
    - name: clone
      image: alpine/git
      workingDir: $(workspaces.source.path)
      command:
        - /bin/sh
      args:
        - '-c'
        - git clone -v $(params.repo) ./source
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: list
spec:
  workspaces:
    - name: source
  steps:
    - name: list
      image: alpine
      workingDir: $(workspaces.source.path)
      command:
        - /bin/sh
      args:
        - "-c"
        - ls ./source
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: clone-and-list
spec:
  workspaces:
    - name: codebase
  tasks:
    - name: clone
      taskRef:
        name: clone
      workspaces:
        - name: source
          workspace: codebase
    - name: list
      taskRef:
        name: list
      workspaces:
        - name: source
          workspace: codebase
      runAfter:
        - clone
EOF
```

<br/>

```
$ tkn pipeline start clone-and-list --showlog
```

<br/>

```
? Name for the workspace : codebase
? Value of the Sub Path :
? Type of the Workspace : emptyDir
? Type of EmptyDir :
```

<br/>

**result:**

<br/>

```
[clone : clone] Cloning into './source'...
[clone : clone] POST git-upload-pack (175 bytes)
[clone : clone] POST git-upload-pack (667 bytes)

[list : list] ls: ./source: No such file or directory

failed to get logs for task list : container step-list has failed  : [{"key":"StartedAt","value":"2023-07-31T12:05:12.310Z","type":3}]

```

<br/>

To share the content across tasks, you will need to use a persistent volume, which you will do in the next section.

<br/>

### Persisting data within a pipeline

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: tekton-pv
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
    - ReadWriteOnce
    - ReadOnlyMany
  hostPath:
    path: "/mnt/data"
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tekton-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
EOF
```

<br/>

```
$ tkn pipeline start clone-and-list \
  -w name=codebase,claimName=tekton-pvc \
  --showlog
```

<br/>

```
PipelineRun started: clone-and-list-run-m9bf8
Waiting for logs to be available...
[clone : clone] Cloning into './source'...
[clone : clone] POST git-upload-pack (175 bytes)
[clone : clone] POST git-upload-pack (667 bytes)

[list : list] README.md
[list : list] app
[list : list] demo
[list : list] installation
```

<br/>

Если выполнить второй раз - будет ошибка, т.к. данные из pvc не были удалены.

<br/>

### Cleaning up with finally

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: cleanup
spec:
  workspaces:
    - name: source
  steps:
    - name: remove-source
      image: registry.access.redhat.com/ubi8/ubi
      command:
        - /bin/bash
      args:
        - "-c"
        - "rm -rf $(workspaces.source.path)/source"
    - name: message
      image: registry.access.redhat.com/ubi8/ubi
      command:
        - /bin/bash
      args:
        - "-c"
        - echo All files were deleted
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: clone-and-list
spec:
  workspaces:
    - name: codebase
  tasks:
    - name: clone
      taskRef:
        name: clone
      workspaces:
        - name: source
          workspace: codebase
    - name: list
      taskRef:
        name: list
      workspaces:
        - name: source
          workspace: codebase
      runAfter:
        - clone
  finally:
    - name: clean
      taskRef:
        name: cleanup
      workspaces:
        - name: source
          workspace: codebase
EOF
```

<br/>

```
$ tkn pipeline start clone-and-list \
  -w name=codebase,claimName=tekton-pvc \
  --showlog
```

```
PipelineRun started: clone-and-list-run-cdbxj
Waiting for logs to be available...
task clone has failed: "step-clone" exited with code 128 (image: "docker-pullable://alpine/git@sha256:7ee4031c1e08fb1646878c53059535b5e88bcf1f0ccb3aad3485362e2039d886"); for logs run: kubectl -n default logs clone-and-list-run-cdbxj-clone-pod -c step-clone

[clone : clone] fatal: destination path './source' already exists and is not an empty directory.


[clean : message] All files were deleted
```

<br/>

### Using workspaces in pipeline runs

<br/>

```
$ vi ~/tmp/pipelinerun.yaml
```

<br/>

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: clone-and-ls-pr-
spec:
  pipelineRef:
    name: clone-and-list
  workspaces:
    - name: codebase
      persistentVolumeClaim:
        claimName: tekton-pvc
```

<br/>

```
$ kubectl create -f ~/tmp/pipelinerun.yaml
```

<br/>

```
$ tkn pr logs -f clone-and-ls-pr-hsqfz
```

```
[clone : clone] Cloning into './source'...
[clone : clone] POST git-upload-pack (175 bytes)
[clone : clone] POST git-upload-pack (667 bytes)

[list : list] README.md
[list : list] app
[list : list] demo
[list : list] installation


[clean : message] All files were deleted
```

<br/>

### Using volume claim templates

Instead of specifying a persistent volume claim directly, you can also ask Tekton to create a temporary one for you. This can be useful when you don't need to persist data outside of your pipelines.

<br/>

```
$ vi ~/tmp/pvc-template.yaml
```

<br/>

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: clone-and-ls-pr-
spec:
  pipelineSpec:
    workspaces:
      - name: codebase
    tasks:
      - name: clone
        taskRef:
          name: clone
        workspaces:
          - name: source
            workspace: codebase
      - name: list
        taskRef:
          name: list
        workspaces:
          - name: source
            workspace: codebase
        runAfter:
          - clone
  workspaces:
    - name: codebase
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
```

<br/>

```
$ kubectl create -f ~/tmp/pvc-template.yaml
```

<br/>

```
$ tkn pr logs -f clone-and-ls-pr-xwsnd
```

```
[clone : clone] Cloning into './source'...
[clone : clone] POST git-upload-pack (175 bytes)
[clone : clone] POST git-upload-pack (667 bytes)

[list : list] README.md
[list : list] app
[list : list] demo
[list : list] installation
```

<br/>

This volume claim template creates a new PVC for each pipeline execution.

<br/>

## Assessments

<br/>

### Write and read

<br/>

Create a task that uses a workspace to share information across its two steps. The first step will write a message, specified in a parameter, to a file in the workspace. The second step will output the content of the file in the logs.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: write-read-workspace
spec:
  workspaces:
    - name: data
  params:
    - name: message
      default: "Hello World"
      type: string
      description: "Message to write in the workspace"
  steps:
    - name: write
      image: registry.access.redhat.com/ubi8/ubi
      command:
        - /bin/bash
      args:
        - -c
        - echo "$(params.message)" > $(workspaces.data.path)/message.txt
    - name: read
      image: registry.access.redhat.com/ubi8/ubi
      command:
        - /bin/bash
      args:
        - -c
        - cat $(workspaces.data.path)/message.txt
EOF
```

<br/>

```
$ tkn task start write-read-workspace --showlog
? Value for param `message` of type `string`? (Default is `Hello World`) Hello World
Please give specifications for the workspace: data
? Name for the workspace : data
? Value of the Sub Path :
? Type of the Workspace : emptyDir
? Type of EmptyDir :
TaskRun started: write-read-workspace-run-sg2b5
Waiting for logs to be available...

[read] Hello World
```

<br/>

### Pick a card

Using the Deck of Cards API available at http://deckofcardsapi.com/, create a pipeline that will generate a new deck of cards and then pick a single card from it. The first call will generate a deck identifier (ID) that you can then use in the next task to pick a card. Output the card value and suit in the second task.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deck-api-create
spec:
  workspaces:
    - name: deck
  steps:
    - name: create-deck
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        curl https://deckofcardsapi.com/api/deck/new/shuffle/ -o $(workspaces.deck.path)/deck-id.txt
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deck-api-draw
spec:
  workspaces:
    - name: deck
  steps:
    - name: draw
      image: node:14
      script: |
        #!/usr/bin/env node
        const fs = require("fs");
        const https = require("https");
        const deck = fs.readFileSync("$(workspaces.deck.path)/deck-id.txt");
        const deckId = JSON.parse(deck).deck_id;
        const URL = `https://deckofcardsapi.com/api/deck/${deckId}/draw/`;
        console.log(URL);
        https.get(URL, response => {
          response.on("data", data => {
            let card = JSON.parse(data).cards[0];
            console.log("Card was drawn from the deck");
            console.log(`${card.value} of ${card.suit}`);
          })
        });
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pick-a-card
spec:
  workspaces:
    - name: api-data
  tasks:
    - name: create-deck
      taskRef:
        name: deck-api-create
      workspaces:
        - name: deck
          workspace: api-data
    - name: pick-card
      taskRef:
        name: deck-api-draw
      workspaces:
        - name: deck
          workspace: api-data
      runAfter:
        - create-deck
EOF
```

<br/>

```
$ tkn pipeline start pick-a-card --showlog
[pick-card : draw] internal/fs/utils.js:332
[pick-card : draw]     throw err;
[pick-card : draw]     ^
[pick-card : draw]
[pick-card : draw] Error: ENOENT: no such file or directory, open '/workspace/deck/deck-id.txt'
[pick-card : draw]     at Object.openSync (fs.js:498:3)
[pick-card : draw]     at Object.readFileSync (fs.js:394:35)
[pick-card : draw]     at Object.<anonymous> (/tekton/scripts/script-0-4wfnl:4:17)
[pick-card : draw]     at Module._compile (internal/modules/cjs/loader.js:1114:14)
[pick-card : draw]     at Object.Module._extensions..js (internal/modules/cjs/loader.js:1143:10)
[pick-card : draw]     at Module.load (internal/modules/cjs/loader.js:979:32)
[pick-card : draw]     at Function.Module._load (internal/modules/cjs/loader.js:819:12)
[pick-card : draw]     at Function.executeUserEntryPoint [as runMain] (internal/modules/run_main.js:75:12)
[pick-card : draw]     at internal/main/run_main_module.js:17:47 {
[pick-card : draw]   errno: -2,
[pick-card : draw]   syscall: 'open',
[pick-card : draw]   code: 'ENOENT',
[pick-card : draw]   path: '/workspace/deck/deck-id.txt'
[pick-card : draw] }

failed to get logs for task pick-card : container step-draw has failed  : [{"key":"StartedAt","value":"2023-07-31T12:12:06.068Z","type":3}]
```

<br/>

```
$ tkn pr logs -f pick-a-card-run-5kmmq
```

<br/>

### Hello admin

Build a pipeline that will return a different greeting, whether the username passed as a parameter is admin or something else. This pipeline should have two tasks. The first task will verify the username and output the role ( admin or user ) in the result. The second task will pick up this role and display the appropriate message from a ConfigMap mounted as a workspace.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: messages
data:
  admin-welcome: Welcome master.
  user-welcome: Hello user.
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: get-role
spec:
  results:
    - name: role
  params:
    - name: user
      type: string
  steps:
    - name: check-username
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        #!/usr/bin/env bash
        if [ "$(params.user)" == "admin" ]; then
          echo "admin" > $(results.role.path)
        else
          echo "user" > $(results.role.path)
        fi
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: role-based-greet
spec:
  params:
    - name: role
      type: string
  workspaces:
    - name: messages
  steps:
    - name: greet
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        ROLE=$(params.role)
        cat $(workspaces.messages.path)/$ROLE-welcome
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: admin-or-not
spec:
  params:
    - name: username
      default: user
      type: string
  workspaces:
    - name: message-map
  tasks:
    - name: validate-admin
      taskRef:
        name: get-role
      params:
        - name: user
          value: $(params.username)
    - name: greetings
      taskRef:
        name: role-based-greet
      params:
        - name: role
          value: $(tasks.validate-admin.results.role)
      workspaces:
        - name: messages
          workspace: message-map
      runAfter:
        - validate-admin
EOF
```

<br/>

```
$ tkn pipeline start admin-or-not --showlog
? Value for param `username` of type `string`? (Default is `user`) [user]
Please give specifications for the workspace: [message-map]
? Name for the workspace : message-map
? Value of the Sub Path :
? Type of the Workspace : emptyDir
? Type of EmptyDir :
PipelineRun started: admin-or-not-run-lknhx
Waiting for logs to be available...

[greetings : greet] cat: /workspace/messages/user-welcome: No such file or directory

failed to get logs for task greetings : container step-greet has failed  : [{"key":"StartedAt","value":"2023-07-31T12:14:06.534Z","type":3}]
```
