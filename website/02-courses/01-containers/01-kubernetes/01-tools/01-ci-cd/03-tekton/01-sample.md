---
layout: page
title: TekTon
description: TekTon
keywords: linux, kubernetes, CI/CD, TekTon
permalink: //docs.k8s.ru/devops/containers/kubernetes/ci-cd/tekton/sample/
---

# TekTon

https://github.com/tektoncd/pipeline/blob/master/docs/install.md#installing-tekton-pipelines-on-kubernetes

<br/>

### TekTon CLI

https://github.com/tektoncd/cli

    # Get the tar.xz
    $ curl -LO https://github.com/tektoncd/cli/releases/download/v0.8.0/tkn_0.8.0_Linux_x86_64.tar.gz

    # Extract tkn to your PATH (e.g. /usr/local/bin)
    $ sudo tar xvzf tkn_0.8.0_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn

<br/>

### Kubernetes Cluster

    $ kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml


    $ kubectl get pods --namespace tekton-pipelines --watch

<br/>

    $ kubectl api-resources | grep tekton

<br/>

### Пробуем

https://github.com/tektoncd/pipeline/blob/master/docs/tutorial.md

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: echo-hello-world
spec:
  steps:
    - name: echo
      image: ubuntu
      command:
        - echo
      args:
        - "Hello World"
EOF
```

<br/>

    $ tkn task describe echo-hello-world

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: echo-hello-world-task-run
spec:
  taskRef:
    name: echo-hello-world
EOF
```

    $ tkn taskrun describe echo-hello-world-task-run

<br/>

    $ kubectl get tr
    NAME                        SUCCEEDED   REASON      STARTTIME   COMPLETIONTIME
    echo-hello-world-task-run   True        Succeeded   3h16m       3h15m

<br/>

    $ tkn taskrun logs echo-hello-world-task-run

<br/>

### Еще примерчик

https://github.com/webmakaka/tekton

<br/>

### Еще примерчик

https://meteatamel.wordpress.com/2019/08/28/migrating-from-knative-build-to-tekton-pipelines/
