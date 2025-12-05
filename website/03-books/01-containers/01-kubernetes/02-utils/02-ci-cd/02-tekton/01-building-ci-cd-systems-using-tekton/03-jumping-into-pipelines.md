---
layout: page
title: Building CI/CD Systems Using Tekton - Jumping into Pipelines
description: Building CI/CD Systems Using Tekton - Jumping into Pipelines
keywords: books, ci-cd, tekton, Jumping into Pipelines
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/jumping-into-pipelines/
---

# Chapter 5. Jumping into Pipelines

<br/>

Делаю:  
31.08.2023

<br/>

### Building your first pipeline

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: first-task
spec:
  steps:
    - image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args: ['-c', 'echo Hello from first task']
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: hello
spec:
  tasks:
    - name: first
      taskRef:
        name: first-task
EOF
```

<br/>

```
$ tkn pipeline start hello --showlog
```

<br/>

### Примерчик состоящий из 2-х тасок

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: die-roll
spec:
  steps:
    - name: greetings
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args: ['-c', 'echo Rolling 6-sided dice']
    - name: generate-random-number
      image: node:14
      script: |
        #!/usr/bin/env node
        const max = 6
        let randomNumber =  Math.floor(Math.random() * Math.floor(max));
        console.log(randomNumber + 1);
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: hello-dice-roll
spec:
  tasks:
    - name: first
      taskRef:
        name: first-task
    - name: roll
      taskRef:
        name: die-roll
EOF
```

<br/>

```
$ tkn pipeline start hello-dice-roll --showlog
```

<br/>

### Parameterizing pipelines

first-task д.б. создана.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: die-roll-param
spec:
  params:
    - name: sides
      description: Number of sides to the dice
      default: "6"
      type: string
  steps:
    - name: greetings
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args: ['-c', 'echo Rolling $(params.sides)-sided dice']
    - name: generate-random-number
      image: node:14
      script: |
        #!/usr/bin/env node
        const max = $(params.sides)
        let randomNumber =  Math.floor(Math.random() * Math.floor(max));
        console.log(randomNumber + 1);
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: parametrized-dice-roll
spec:
  tasks:
    - name: first
      taskRef:
        name: first-task
    - name: roll
      taskRef:
        name: die-roll-param
EOF
```

<br/>

```
$ tkn pipeline start parametrized-dice-roll --showlog
```

<br/>

```
PipelineRun started: parametrized-dice-roll-run-spgwz
Waiting for logs to be available...
[first : unnamed-0] Hello from first task

[roll : greetings] Rolling 6-sided dice

[roll : generate-random-number] 4
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: parametrized-dice-roll
spec:
  tasks:
    - name: first
      taskRef:
        name: first-task
    - name: roll
      params:
        - name: sides
          value: "8"
      taskRef:
        name: die-roll-param
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: parametrized-dice-roll
spec:
  params:
    - name: dice-sides
      type: "string"
      default: "6"
      description: Number of sides on the dice
  tasks:
    - name: first
      taskRef:
        name: first-task
    - name: roll
      params:
        - name: sides
          value: "$(params.dice-sides)"
      taskRef:
        name: die-roll-param
EOF
```

<br/>

```
$ tkn pipeline start parametrized-dice-roll -p dice-sides=12 --showlog
```

<br/>

```
PipelineRun started: parametrized-dice-roll-run-mqmwp
Waiting for logs to be available...
[first : unnamed-0] Hello from first task

[roll : greetings] Rolling 12-sided dice

[roll : generate-random-number] 7
```

<br/>

```
$ tkn pipeline start parametrized-dice-roll --use-param-defaults --showlog
```

<br/>

### Reusing tasks in the context of a pipeline

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: logger
spec:
  params:
    - name: text
      type: string
  steps:
    - name: log
      image: registry.access.redhat.com/ubi8/ubi-minimal
      script: |
        DATE=$(date +%d/%m/%Y\ %T)
        echo [$DATE] - $(params.text)
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: task-reuse
spec:
  tasks:
    - name: say-hello
      params:
        - name: text
          value: "Hello"
      taskRef:
        name: logger
    - name: log-something
      params:
        - name: text
          value: "Something else being logged"
      taskRef:
        name: logger
EOF
```

<br/>

```
$ tkn pipeline start task-reuse --showlog
```

<br/>

```
PipelineRun started: task-reuse-run-qtbbv
Waiting for logs to be available...
[say-hello : log] [31/07/2023 10:23:31] - Hello

[log-something : log] [31/07/2023 10:23:32] - Something else being logged
```

<br/>

### Ordering tasks within pipelines

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: sleep-and-log
spec:
  params:
    - name: task-name
      type: string
    - name: time
      type: string
      default: "1"
  steps:
    - name: init
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args:
        - "-c"
        - "echo [$(date '+%d/%m/%Y %T')] - Task $(params.task-name) Started"
    - name: sleep
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args:
        - -c
        - sleep $(params.time)
    - name: log
      image: registry.access.redhat.com/ubi8/ubi-minimal
      command:
        - /bin/bash
      args:
        - "-c"
        - "echo [$(date '+%d/%m/%Y %T')] - Task $(params.task-name) Completed"
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: ordered-tasks
spec:
  tasks:
    - name: first
      params:
        - name: task-name
          value: A
        - name: time
          value: "2"
      taskRef:
        name: sleep-and-log
    - name: second
      params:
        - name: task-name
          value: B
      taskRef:
        name: sleep-and-log
      runAfter:
        - first
    - name: third
      params:
        - name: task-name
          value: C
        - name: time
          value: "3"
      taskRef:
        name: sleep-and-log
      runAfter:
        - first
    - name: fourth
      params:
        - name: task-name
          value: D
      taskRef:
        name: sleep-and-log
      runAfter:
        - second
        - third
EOF
```

<br/>

```
$ tkn pipeline start ordered-tasks --showlog
```

<br/>

```
[first : init] [31/07/2023 10:24:41] - Task A Started


[first : log] [31/07/2023 10:24:44] - Task A Completed

[second : init] [31/07/2023 10:24:51] - Task B Started

[third : init] [31/07/2023 10:24:53] - Task C Started

[second : log] [31/07/2023 10:24:53] - Task B Completed



[third : log] [31/07/2023 10:24:57] - Task C Completed

[fourth : init] [31/07/2023 10:25:03] - Task D Started


[fourth : log] [31/07/2023 10:25:06] - Task D Completed
```

<br/>

### Using task results in pipelines

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: dice-roll-result
spec:
  params:
    - name: sides
      description: Number of sides to the dice
      default: "6"
      type: string
  results:
    - name: dice-roll
      description: Random number generated by the dice roll
  steps:
    - name: generate-random-number
      image: node:14
      script: |
        #!/usr/bin/env node
        const fs = require("fs");
        const max = $(params.sides)
        let randomNumber =  Math.floor(Math.random() * Math.floor(max));
        fs.writeFile("$(results.dice-roll.path)", randomNumber.toString(), () => {
          console.log("Dice rolled");
        });
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: results
spec:
  params:
    - name: sides
      default: "6"
      type: "string"
  tasks:
    - name: intro
      params:
        - name: text
          value: "Preparing to roll the $(params.sides)-sided dice"
      taskRef:
        name: logger
    - name: roll
      params:
        - name: sides
          value: $(params.sides)
      taskRef:
        name: dice-roll-result
      runAfter:
        - intro
    - name: result
      params:
        - name: text
          value: "Result from dice roll was $(tasks.roll.results.dice-roll)"
      taskRef:
        name: logger
      runAfter:
        - roll
EOF
```

<br/>

```
$ tkn pipeline start results --showlog
```

<br/>

```
? Value for param `sides` of type `string`? (Default is `6`) 6
PipelineRun started: results-run-gnxch
Waiting for logs to be available...
[intro : log] [31/07/2023 10:26:00] - Preparing to roll the 6-sided dice

[roll : generate-random-number] Dice rolled

[result : log] [31/07/2023 10:26:13] - Result from dice roll was 5
```

<br/>

### Introducing pipeline runs

<br/>

```
$ kubectl get pipelineruns
```

<br/>

```
// Delete
$ kubectl delete pipelinerun results-run-s8w2j
```

<br/>

```
$ kubectl get pipelinerun results-run-sb6lk -o yaml
```

<br/>

## Assessments

<br/>

### Back to the basics

<br/>

Task logger должна быть создана.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: back-to-basics
spec:
  params:
    - name: who
      default: "World"
      type: string
      description: Who should we say hello to?
  tasks:
    - name: say-hello
      params:
        - name: text
          value: Hello $(params.who)
      taskRef:
        name: logger
EOF
```

<br/>

```
$ tkn pipeline start back-to-basics --showlog
```

<br/>

```
? Value for param `who` of type `string`? (Default is `World`) World
PipelineRun started: back-to-basics-run-9wfsx
Waiting for logs to be available...
[say-hello : log] [31/07/2023 10:27:22] - Hello World
```

<br/>

### Counting files in a repo

<br/>

Task logger должна быть создана.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: clone-and-count
spec:
  params:
    - name: repo
      type: string
  results:
    - name: file-count
      description: Number of files
  steps:
    - name: clone-and-ls
      image: alpine/git
      script: |
        git clone $(params.repo) .
        ls | wc -l > $(results.file-count.path)
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: count-files
spec:
  params:
    - name: repo-to-analyze
  tasks:
    - name: get-list
      taskRef:
        name: clone-and-count
      params:
        - name: repo
          value: $(params.repo-to-analyze)
    - name: output-count
      taskRef:
        name: logger
      params:
        - name: text
          value: "Number of files in $(params.repo-to-analyze): $(tasks.get-list.results.file-count)"
      runAfter:
        - get-list
EOF
```

<br/>

```
$ tkn pipeline start count-files --showlog
```

<br/>

```
? Value for param `repo-to-analyze` of type `string`? https://github.com/PacktPublishing/Building-CI-CD-systems-using-Tekton
PipelineRun started: count-files-run-k5fnr
Waiting for logs to be available...
[get-list : clone-and-ls] Cloning into '.'...

[output-count : log] [31/07/2023 10:28:25] - Number of files in https://github.com/PacktPublishing/Building-CI-CD-systems-using-Tekton: 11
```

<br/>

### Weather services

<br/>

Task logger должна быть создана.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: weather
spec:
  params:
    - name: city
      type: string
  results:
    - name: weather
      description: JSON object with weather definition
  steps:
    - name: get-weather
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        curl wttr.in/$(params.city)?format=4 -o $(results.weather.path)
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: weather-extract
spec:
  results:
    - name: temperature
      description: Current temperature
  params:
    - name: weather-data
      type: string
  steps:
    - name: extract-data
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        echo "$(params.weather-data)" | awk '{print $3}' > $(results.temperature.path)
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: weather
spec:
  params:
    - name: city
      type: string
      default: Ottawa
  tasks:
    - name: get-weather
      params:
        - name: city
          value: $(params.city)
      taskRef:
        name: weather
    - name: extract-data
      params:
        - name: weather-data
          value: $(tasks.get-weather.results.weather)
      taskRef:
        name: weather-extract
      runAfter:
        - get-weather
    - name: current-temperature
      params:
        - name: text
          value: Current temperature in $(params.city) is $(tasks.extract-data.results.temperature)
      taskRef:
        name: logger
      runAfter:
        - extract-data
EOF
```

<br/>

```
$ tkn pipeline start weather --showlog
```

<br/>

```
? Value for param `city` of type `string`? (Default is `Ottawa`) Ottawa
PipelineRun started: weather-run-cv4sk
Waiting for logs to be available...
[current-temperature : log] [31/07/2023 10:30:02] - Current temperature in Ottawa is 🌡️+14°C
```
