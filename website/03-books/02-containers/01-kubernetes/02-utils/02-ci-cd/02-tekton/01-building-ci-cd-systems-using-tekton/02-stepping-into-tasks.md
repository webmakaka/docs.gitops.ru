---
layout: page
title: Building CI/CD Systems Using Tekton - Stepping into Tasks
description: Building CI/CD Systems Using Tekton - Stepping into Tasks
keywords: books, ci-cd, tekton, Stepping into Tasks
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/stepping-into-tasks/
---

# Chapter 4. Stepping into Tasks

<br/>

### [OK!] Task1: Building your first task

<br/>

Делаю:  
2025.12.11

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello
spec:
  steps:
    - image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
        - -c
        - echo "Hello World"
EOF
```

<br/>

```
$ tkn task ls
NAME    DESCRIPTION   AGE
hello                 5 seconds ago
```

<br/>

```
$ kubectl get tasks
NAME    AGE
hello   29s
```

<br/>

```
$ tkn task start hello --showlog
```

<br/>

```
TaskRun started: hello-run-c7fnz
Waiting for logs to be available...

[unnamed-0] Hello World
```

<br/>

### Adding additional Steps

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: multiple-steps
spec:
  steps:
    - name: first
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
        - -c
        - echo "First step running"
    - name: second
      image: alpine
      command:
        - /bin/sh
        - -c
        - echo "Second step running"
EOF
```

<br/>

```
$ tkn task start multiple-steps --showlog

[first] First step running

[second] Second step running
```

<br/>

### Using scripts

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: script
spec:
  steps:
    - name: step-with-script
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        #!/usr/bin/env bash
        echo "Installing necessary tooling"
        dnf install iputils -y
        ping redhat.com -c 5
        echo "All done!"
EOF
```

<br/>

```
$ tkn task start script --showlog

step-with-script] --- redhat.com ping statistics ---
[step-with-script] 5 packets transmitted, 0 received, 100% packet loss, time 4079ms
[step-with-script]
[step-with-script] All done!
```

<br/>

### Using scripts

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: script-node
spec:
  steps:
    - image: node:14
      script: |
        #!/usr/bin/env node
        console.log("This is some JS code");
EOF
```

<br/>

```
$ tkn task start script-node --showlog

[unnamed-0] This is some JS code
```

<br/>

### Adding task parameters

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello-param
spec:
  params:
    - name: who
      type: string
  steps:
    - image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
        - -c
        - echo "Hello $(params.who)"
EOF
```

<br/>

```
$ tkn task start hello-param --showlog
```

<br/>

```
$ tkn task start hello-param --showlog -p who=Marley
```

<br/>

### Using array type parameters

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: groceries
spec:
  params:
    - name: grocery-items
      type: array
  steps:
    - name: grocery-list
      image: node:14
      args:
        - $(params.grocery-items[*])
      script: |
        #!/usr/bin/env node
        const items = process.argv.splice(2);
        console.log("Grocery List");
        items.map(i => console.log(`=> ${i}`));
EOF
```

<br/>

```
$ tkn task start groceries --showlog -p grocery-items='1 2 3 4 5 6 7 8 9 10'
```

<br/>

### Adding a default value

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello-param
spec:
  params:
    - name: who
      type: string
      default: World
  steps:
    - image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
        - -c
        - echo "Hello $(params.who)"
EOF
```

<br/>

```
$ tkn task start hello-param --showlog --use-param-defaults
```

<br/>

### Sharing data

Пример из книги устарел.  
Обновленная версия.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: shared-home
spec:
  volumes:
    - name: shared-volume
      emptyDir: {}
  steps:
    - name: write
      image: registry.access.redhat.com/ubi8/ubi-minimal
      volumeMounts:
        - name: shared-volume
          mountPath: /shared
      script: |
        echo "Writing to /shared/message.txt"
        echo "Secret Message" > /shared/message.txt
        echo "File created successfully"

    - name: read
      image: registry.access.redhat.com/ubi8/ubi-minimal
      volumeMounts:
        - name: shared-volume
          mountPath: /shared
      script: |
        echo "Reading from /shared/message.txt"
        if [ -f /shared/message.txt ]; then
          cat /shared/message.txt
        else
          echo "ERROR: File not found!"
          echo "Available files in /shared:"
          ls -la /shared/
          exit 1
        fi
EOF
```

<br/>

```
$ tkn task start shared-home --showlog
```

<br/>

### Using results

Results can be used in tasks to store the output from a task in a single file. Ultimately, the result is the same as using the home folder directly, but it is a standard way of sharing limited pieces of data across steps or even between tasks.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: using-results
spec:
  results:
    - name: message
      description: Message to be shared
  steps:
    - name: write
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args:
        - "-c"
        - echo "Secret Message" | base64 > $(results.message.path)
    - name: read
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args:
        - "-c"
        - cat $(results.message.path)
EOF
```

<br/>

```
$ tkn task start using-results --showlog
```

<br/>

### Using Kubernetes volumes

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: colors-map
data:
  error: "\e[31m"
  info: "\e[34m"
  debug: "\e[32m"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: configmap
spec:
  volumes:
    - name: colors
      configMap:
        name: colors-map
  steps:
    - name: log-stuff
      image: registry.access.redhat.com/ubi8/ubi-minimal
      volumeMounts:
        - name: colors
          mountPath: /var/colors
      script: |
        echo $(cat /var/colors/info)Logging information
        echo $(cat /var/colors/debug)Debugging statement
        echo $(cat /var/colors/error)Colourized error statement
EOF
```

<br/>

```
$ tkn task start configmap --showlog
```

<br/>

### Digging into TaskRuns

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: failing
spec:
  steps:
    - image: nonexistinguser/notavalidcontainer
      command:
        - echo "Hello World"
EOF
```

<br/>

```
$ tkn task start failing
```

<br/>

```
$ kubectl get tr failing-run-h42fw -o yaml
```

<br/>

## Assessments

<br/>

### More than Hello World

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: more-than-hello
spec:
  params:
    - name: log
      type: string
      default: Done sleeping
    - name: pause-duration
      type: string
      default: "1"
  steps:
    - name: greet
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args: ['-c', 'echo Welcome to this task']
    - name: pause
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args: ['-c', 'sleep $(params.pause-duration)']
    - name: log
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args: ['-c', 'echo $(params.log)']
EOF
```

<br/>

```
$ tkn task start more-than-hello --showlog
```

<br/>

### Build a generic curl task

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: curl
spec:
  results:
    - name: response
      description: Response from cURL
  params:
    - name: url
      description: URL to cURL
      type: string
    - name: args
      description: Additional arguments
      type: array
      default: []
  steps:
    - name: curl
      image: registry.access.redhat.com/ubi8/ubi
      command:
        - curl
      args:
        - $(params.args[*])
        - -o
        - $(results.response.path)
        - --url
        - $(params.url)
    - name: output
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        echo Output from the cURL to $(params.url)
        cat $(results.response.path)
EOF
```

<br/>

```
$ tkn task start curl --showlog
```

<br/>

### Create a random user

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: randomuser
data:
  nationality: gb
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: randomuser
spec:
  volumes:
    - name: nationality
      configMap:
        name: randomuser
    - name: shared-volume
      emptyDir: {}
  results:
    - name: config
      description: Configuration file for cURL
    - name: output
      description: Output from curl
  steps:

    # Шаг 1: Создание конфигурационного файла
    - name: config
      image: registry.access.redhat.com/ubi8/ubi
      volumeMounts:
        - name: nationality
          mountPath: /var/nat
        - name: shared-volume
          mountPath: /shared
      script: |
        #!/bin/bash
        NAT=$(cat /var/nat/nationality)
        echo "Creating config for nationality: ${NAT}"
        echo "url=https://randomuser.me/api/?inc=name,nat&nat=${NAT}" > /shared/config.txt
        echo "Config created at /shared/config.txt"
        cat /shared/config.txt


    # Шаг 2: Выполнение curl запроса
    - name: curl
      image: registry.access.redhat.com/ubi8/ubi
      volumeMounts:
        - name: shared-volume
          mountPath: /shared
      script: |
        #!/bin/bash
        echo "Executing curl with config from /shared/config.txt"
        curl -K /shared/config.txt -o /shared/response.json
        echo "Response saved to /shared/response.json"
        echo "Response content:"
        cat /shared/response.json

    # Шаг 3: Обработка результата
    - name: output
      image: apteno/alpine-jq
      volumeMounts:
        - name: shared-volume
          mountPath: /shared
      script: |
        #!/bin/sh
        echo "Processing response from /shared/response.json"
        cat /shared/response.json

        FIRST=$(jq -r '.results[0].name.first' /shared/response.json)
        LAST=$(jq -r '.results[0].name.last' /shared/response.json)
        NAT=$(jq -r '.results[0].nat' /shared/response.json)

        echo "New random user created with nationality ${NAT}"
        echo "Name: ${FIRST} ${LAST} ${NAT}"

EOF
```

<br/>

```
$ tkn task start randomuser --showlog
```
