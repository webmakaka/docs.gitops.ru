---
layout: page
title: Building CI/CD Systems Using Tekton - Triggering Tekton
description: Building CI/CD Systems Using Tekton - Triggering Tekton
keywords: books, ci-cd, tekton, Triggering Tekton
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/triggering-tekton/
---

# [OK!] Chapter 11. Triggering Tekton

<br/>

Делаю:  
31.08.2023

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
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: something-pushed
spec:
  params:
    - name: repository
      type: string
  tasks:
    - name: log-push
      taskRef:
        name: logger
      params:
        - name: text
          value: A push happened in $(params.repository)
EOF
```

<br/>

```
$ tkn pipeline start something-pushed --showlog
```

<br/>

Просто будет выводить сообщение в консоль.

<br/>

```
? Value for param `repository` of type `string`? [<myrepo>]
```

<br/>

```
[log-push : log] [31/07/2023 12:57:45] - A push happened in https://github.com/wildmakaka/tekton-book-app
```

<br/>

### Creating the trigger

This trigger will listen for GitHub webhooks and automatically start the pipeline you've just built.

<br/>

#### TriggerBinding

**GitHub documentation**  
https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#push

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: event-binding
spec:
  params:
    - name: git-repository-url
      value: $(body.repository.url)
EOF
```

<br/>

#### TriggerTemplate

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: push-trigger-template
spec:
  params:
  - name: git-repository-url
    description: The git repository url
  resourcetemplates:
  - apiVersion: tekton.dev/v1beta1
    kind: PipelineRun
    metadata:
      generateName: something-pushed-
    spec:
      pipelineRef:
        name: something-pushed
      params:
      - name: repository
        value: $(tt.params.git-repository-url)
EOF
```

<br/>

#### EventListener

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: listener
spec:
  serviceAccountName: tekton-triggers-example-sa
  triggers:
    - name: trigger
      bindings:
        - ref: event-binding
      template:
        ref: push-trigger-template
      interceptors:
        - github:
            secretRef:
              secretName: git-secret
              secretKey: secretToken
            eventTypes:
              - push
EOF
```

<br/>

### Configuring the incoming webhooks

<br/>

#### Creating a secret

<br/>

```
$ export TEKTON_SECRET_TOKEN=$(head -c 24 /dev/random | base64)
$ echo ${TEKTON_SECRET_TOKEN}
$ kubectl create secret generic git-secret --from-literal=secretToken=${TEKTON_SECRET_TOKEN}
```

<br/>

#### Exposing a route

<br/>

```
$ kubectl get services
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
el-listener   ClusterIP   10.104.136.189   <none>        8080/TCP,9000/TCP   37s
kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP             9m21s
```

<br/>

You now need to ensure that this service can be reached from outside of your cluster.

<br/>

```
$ kubectl port-forward svc/el-listener 8080
```

<br/>

Any incoming request on port 8080 on your local machine will now be redirected to this service and potentially trigger the pipeline.

```
$ curl localhost:8080
```

<br/>

**Нужный ответ:**

```
{"eventListener":"listener","namespace":"default","eventListenerUID":"","errorMessage":"Invalid event body format format: unexpected end of JSON input"}
```

<br/>

#### Making the route publicly available

Any incoming requests on your computer are redirected to the event listener, but you need to expose this port to the outside world so that GitHub can access this route.

<br/>

```
$ cd ~/tmp
$ ./ngrok http 8080
```

Пробую подключиться по предложенному url с локального хоста.
ОК!

<br/>

### Configuring your GitHub repository

<br/>

Github -> MyProject -> Settings -> Webhooks -> Add webhook

<br/>

• Payload URL: This is your ngrok URL.
• Content type: application/json.
• Secret: Use the secret token you created earlier. You can view your token with the echo ${TEKTON_SECRET_TOKEN} command.

<br/>

Which events would you like to trigger this webhook?

- Just the push event

<br/>

Add Webhook

<br/>

### Triggering the pipeline

Сделать коммит в репо.

<br/>

```
$ tkn pipelinerun ls
NAME                         STARTED          DURATION     STATUS
something-pushed-nsfzl       8 seconds ago    4 seconds    Succeeded
something-pushed-run-6zfvs   10 minutes ago   14 seconds   Succeeded

```

<br/>

```
$ tkn pipelinerun logs something-pushed-9v2fp
[log-push : log] [31/07/2023 13:08:46] - A push happened in https://github.com/wildmakaka/tekton-book-app
```
