---
layout: page
title: Building CI/CD Systems Using Tekton - Adding when Expressions
description: Building CI/CD Systems Using Tekton - Adding when Expressions
keywords: books, ci-cd, tekton, Adding when Expressions
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/adding-when-expressions/
---

# Chapter 8. Adding when Expressions

<br/>

Делаю:  
2025.12.11

<br/>

### Using when expressions with parameters

<br/>

```
$ vi ~/tmp/logger.yaml
```

```yaml
apiVersion: tekton.dev/v1
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
```

<br/>

```
$ kubectl apply -f ~/tmp/logger.yaml
```

<br/>

```
$ vi ~/tmp/guess.yaml
```

<br/>

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: guess-game
spec:
  params:
    - name: number
      description: Pick a number
      type: string
  tasks:
    - name: win
      params:
        - name: text
          value: You win
      taskRef:
        name: logger
      when:
        - input: $(params.number)
          operator: in
          values: ['3']
```

<br/>

```
$ kubectl create -f ~/tmp/guess.yaml
```

<br/>

```
$ tkn pipeline start guess-game --showlog
```

<br/>

```
? Value for param `number` of type `string`? 3
```

В общем только на 3 выводит лог.

<br/>

### Using the notin operator

<br/>

```
$ vi ~/tmp/guess-notin.yaml
```

<br/>

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: guess-game-notin
spec:
  params:
    - name: number
      description: Pick a number
      type: string
  tasks:
    - name: win
      params:
        - name: text
          value: You win
      taskRef:
        name: logger
      when:
        - input: $(params.number)
          operator: in
          values: ['3']
    - name: lose
      params:
        - name: text
          value: You lose
      taskRef:
        name: logger
      when:
        - input: $(params.number)
          operator: notin
          values: ['3']
```

<br/>

```
$ kubectl create -f ~/tmp/guess-notin.yaml
```

<br/>

```
$ tkn pipeline start guess-game-notin --showlog
```

Теперь 3 и не 3.

<br/>

### Using when expressions with results

<br/>

```
$ vi ~/tmp/guess-result.yaml
```

<br/>

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: random-number-generator
spec:
  results:
    - name: random-number
      description: random number
  steps:
    - name: generate-number
      image: registry.access.redhat.com/ubi8/ubi-minimal
      script: |
        NUMBER=$((1 + $RANDOM % 3))
        echo Random number picked, result is $NUMBER
        echo -n $NUMBER > $(results.random-number.path)
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: guess-result
spec:
  tasks:
    - name: generate
      taskRef:
        name: random-number-generator
    - name: win
      params:
        - name: text
          value: You win
      taskRef:
        name: logger
      when:
        - input: $(tasks.generate.results.random-number)
          operator: in
          values: ['3']
      runAfter:
        - generate
    - name: lose
      params:
        - name: text
          value: You lose
      taskRef:
        name: logger
      when:
        - input: $(tasks.generate.results.random-number)
          operator: notin
          values: ['3']
      runAfter:
        - generate
```

<br/>

```
$ kubectl create -f ~/tmp/guess-result.yaml
```

<br/>

```
$ tkn pipeline start guess-result --showlog
```

<br/>

## Assessments

<br/>

### Hello Admin

<br/>

Build a pipeline that will take a username as a parameter. If the username is admin, log the Hello Admin text. For any other username, output a simple Hello message.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
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
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: hello-admin
spec:
  params:
    - name: username
      type: string
  tasks:
    - name: hello-admin
      taskRef:
        name: logger
      params:
        - name: text
          value: "Hello Admin"
      when:
        - input: $(params.username)
          operator: in
          values: ["admin"]
    - name: hello-other
      taskRef:
        name: logger
      params:
        - name: text
          value: "Hello User"
      when:
        - input: $(params.username)
          operator: notin
          values: ["admin"]
EOF
```

<br/>

```
$ tkn pipeline start hello-admin --showlog
? Value for param `username` of type `string`? marley
PipelineRun started: hello-admin-run-z2fks
Waiting for logs to be available...
[hello-other : log] [12/12/2025 04:35:49] - Hello User
```

<br/>

```
$ tkn pipeline start hello-admin --showlog
? Value for param `username` of type `string`? admin
PipelineRun started: hello-admin-run-7mgm8
Waiting for logs to be available...
[hello-admin : log] [12/12/2025 04:36:29] - Hello Admin
```

<br/>

### Critical Hit

<br/>

In role-playing games using dice, rolling a 20 on a 20-sided dice is sometimes referred to as rolling a critical hit. For this exercise, build a pipeline that would log Critical Hit when the result of a dice roll is 20 . To do so, use a task that will generate a random number between 1 and 20 and produce a result that the when expression of a second task can pick up.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: dice-roll-result
spec:
  params:
    - name: sides
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
        let randomNumber =  Math.floor(Math.random() * Math.floor(max)) + 1;
        fs.writeFile("$(results.dice-roll.path)", randomNumber.toString(), () => {
          console.log("Dice rolled");
        });
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: results
spec:
  params:
    - name: sides
      default: "20"
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
    - name: critical
      taskRef:
        name: logger
      params:
        - name: text
          value: "Critical hit!"
      when:
        - input: $(tasks.roll.results.dice-roll)
          operator: in
          values: ["20"]
      runAfter:
        - roll
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
? Value for param `sides` of type `string`? (Default is `20`) 20
PipelineRun started: results-run-xwnfq
Waiting for logs to be available...
[intro : log] ++ date '+%d/%m/%Y %T'
[intro : log] + DATE='24/10/2021 13:06:42'
[intro : log] + echo '[24/10/2021' '13:06:42]' - Preparing to roll the 20-sided dice
[intro : log] [24/10/2021 13:06:42] - Preparing to roll the 20-sided dice

[roll : generate-random-number] Dice rolled

[critical : log] ++ date '+%d/%m/%Y %T'
[critical : log] + DATE='24/10/2021 13:06:55'
[critical : log] + echo '[24/10/2021' '13:06:55]' - Critical 'hit!'
[critical : log] [24/10/2021 13:06:55] - Critical hit!

[result : log] ++ date '+%d/%m/%Y %T'
[result : log] + DATE='24/10/2021 13:06:56'
[result : log] [24/10/2021 13:06:56] - Result from dice roll was 20
[result : log] + echo '[24/10/2021' '13:06:56]' - Result from dice roll was 20
```

<br/>

### Not working on weekends

<br/>

Even your servers deserve a break. Build a pipeline with a task that Tekton will only execute on weekdays. The task should log a Working message to simulate some work.

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: get-day
spec:
  results:
    - name: daynumber
      description: day of week, 0 is Sunday
  steps:
    - name: get-day
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        date +%w | tr -d '\n' > $(results.daynumber.path)
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: not-on-weekends
spec:
  tasks:
    - name: getday
      taskRef:
        name: get-day
    - name: work
      taskRef:
        name: logger
      params:
        - name: text
          value: Working...
      when:
        - input: $(tasks.getday.results.daynumber)
          operator: in
          values: ["1", "2", "3", "4", "5"]
      runAfter:
        - getday
EOF
```

<br/>

```
$ tkn pipeline start not-on-weekends --showlog
PipelineRun started: not-on-weekends-run-pfjn5
Waiting for logs to be available...

[work : log] [12/12/2025 04:41:49] - Working...
```

<br/>

```
$ tkn pr logs -f not-on-weekends-run-rpblg
```
